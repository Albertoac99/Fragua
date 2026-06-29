"""Traduce al español assets/exercise_db.sqlite.

- Nombres: desde `exercise_names_es.tsv` (traducción manual revisada).
- Instrucciones: traducción automática offline con el modelo Argos en->es
  ejecutado directamente con CTranslate2 + SentencePiece (sin torch/stanza).

Flujo: ejecutar SOBRE una BD en inglés recién construida por
`build_exercise_db.py`. Para poder re-ejecutarse, hace una copia de seguridad
`.en.bak` la primera vez y, si ya existe, restaura desde ella antes de traducir.

El modelo (~84 MB) se descarga a `.argos_model/` la primera vez (no se versiona).

Uso:
    python translate_db_es.py [--db ../assets/exercise_db.sqlite] [--names-only]
"""
import argparse
import json
import re
import shutil
import sqlite3
import sys
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).parent
DEFAULT_DB = ROOT.parent / "assets" / "exercise_db.sqlite"
NAMES_TSV = ROOT / "exercise_names_es.tsv"
MODEL_URL = "https://argos-net.com/v1/translate-en_es-1_0.argosmodel"
MODEL_DIR = ROOT / ".argos_model"
MODEL_INNER = MODEL_DIR / "en_es"

# Corta un texto en frases conservando el signo de puntuación final.
_SENT = re.compile(r"[^.!?]+[.!?]*\s*")

# Términos en inglés que el modelo deja sin traducir con frecuencia. Solo
# palabras inequívocamente inglesas (no colisionan con español) para que el
# reemplazo por límite de palabra sea seguro sobre texto ya traducido.
_GLOSSARY = {
    "barbells": "barras", "barbell": "barra",
    "dumbbells": "mancuernas", "dumbbell": "mancuerna",
    "kettlebells": "pesas rusas", "kettlebell": "pesa rusa",
    "deadlifts": "pesos muertos", "deadlift": "peso muerto",
}
_GLOSSARY_RE = re.compile(
    r"\b(" + "|".join(sorted(_GLOSSARY, key=len, reverse=True)) + r")\b",
    re.IGNORECASE,
)


def apply_glossary(text):
    """Sustituye términos ingleses sueltos respetando mayúscula inicial."""
    def repl(m):
        es = _GLOSSARY[m.group(0).lower()]
        return es.capitalize() if m.group(0)[0].isupper() else es
    return _GLOSSARY_RE.sub(repl, text)


def load_names(path=NAMES_TSV):
    """id -> nombre en español. Falla si hay líneas mal formadas."""
    names = {}
    for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        if "\t" not in line:
            raise ValueError(f"{path}:{n}: falta el tabulador separador")
        id_, es = line.split("\t", 1)
        names[id_.strip()] = es.strip()
    return names


def ensure_model():
    """Descarga y extrae el modelo Argos en->es si no está presente."""
    if (MODEL_INNER / "model" / "model.bin").exists():
        return
    MODEL_DIR.mkdir(exist_ok=True)
    archive = MODEL_DIR / "model.argosmodel"
    print("Descargando modelo Argos en->es (~84 MB)…", flush=True)
    urllib.request.urlretrieve(MODEL_URL, archive)
    with zipfile.ZipFile(archive) as z:
        z.extractall(MODEL_DIR)
    if not (MODEL_INNER / "model" / "model.bin").exists():
        raise RuntimeError("El modelo no se extrajo como se esperaba")


class Translator:
    """Traductor en->es con CTranslate2 + SentencePiece, frase a frase."""

    def __init__(self):
        import ctranslate2
        import sentencepiece as spm
        ensure_model()
        self._sp = spm.SentencePieceProcessor(
            model_file=str(MODEL_INNER / "sentencepiece.model"))
        self._ct = ctranslate2.Translator(
            str(MODEL_INNER / "model"), device="cpu")
        self._cache = {}

    def _one(self, sentence):
        s = sentence.strip()
        if not s:
            return ""
        if s not in self._cache:
            toks = self._sp.encode(s, out_type=str)
            res = self._ct.translate_batch([toks])
            self._cache[s] = self._sp.decode(res[0].hypotheses[0])
        return self._cache[s]

    def translate(self, text):
        """Trocea en frases, traduce cada una y reúne (mejor fidelidad)."""
        parts = _SENT.findall(text)
        out = self._one(text) if not parts \
            else " ".join(self._one(p) for p in parts).strip()
        return apply_glossary(out)

    @property
    def unique_count(self):
        return len(self._cache)


def translate_instructions(con, translator):
    rows = con.execute("SELECT id, instructions FROM exercises").fetchall()
    total = len(rows)
    for i, (id_, raw) in enumerate(rows, 1):
        sentences = json.loads(raw)
        es = [translator.translate(s) for s in sentences]
        con.execute(
            "UPDATE exercises SET instructions = ? WHERE id = ?",
            (json.dumps(es, ensure_ascii=False), id_),
        )
        if i % 50 == 0 or i == total:
            print(f"  instrucciones {i}/{total}", flush=True)
    print(f"  frases únicas traducidas: {translator.unique_count}", flush=True)


def apply_names(con, names):
    missing, updated = [], 0
    for id_, es in names.items():
        cur = con.execute(
            "UPDATE exercises SET name = ? WHERE id = ?", (es, id_))
        if cur.rowcount == 0:
            missing.append(id_)
        else:
            updated += cur.rowcount
    return updated, missing


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=str(DEFAULT_DB))
    ap.add_argument("--names-only", action="store_true",
                    help="No traducir instrucciones (solo nombres).")
    ap.add_argument("--glossary-only", action="store_true",
                    help="Aplica solo el glosario sobre instrucciones ya "
                         "traducidas (no re-traduce, no usa backup).")
    args = ap.parse_args()

    db = Path(args.db)
    if not db.exists():
        sys.exit(f"No existe la BD: {db}")

    if args.glossary_only:
        con = sqlite3.connect(db)
        try:
            rows = con.execute("SELECT id, instructions FROM exercises").fetchall()
            for id_, raw in rows:
                es = [apply_glossary(s) for s in json.loads(raw)]
                con.execute("UPDATE exercises SET instructions = ? WHERE id = ?",
                            (json.dumps(es, ensure_ascii=False), id_))
            con.commit()
        finally:
            con.close()
        print(f"Glosario aplicado a {len(rows)} ejercicios.", flush=True)
        return

    # Copia de seguridad en inglés (re-ejecutable): si existe, restaurar.
    bak = db.with_suffix(db.suffix + ".en.bak")
    if bak.exists():
        print(f"Restaurando BD en inglés desde {bak.name}", flush=True)
        shutil.copy2(bak, db)
    else:
        shutil.copy2(db, bak)
        print(f"Copia de seguridad creada: {bak.name}", flush=True)

    names = load_names()
    con = sqlite3.connect(db)
    try:
        updated, missing = apply_names(con, names)
        print(f"Nombres aplicados: {updated} (sin coincidencia: {len(missing)})",
              flush=True)
        if missing:
            print("  IDs sin fila:", ", ".join(missing[:10]), flush=True)
        if not args.names_only:
            print("Traduciendo instrucciones (CTranslate2 en->es)…", flush=True)
            translate_instructions(con, Translator())
        con.commit()
    finally:
        con.close()
    print("Hecho.", flush=True)


if __name__ == "__main__":
    main()
