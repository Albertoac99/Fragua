"""Construye assets/exercise_db.sqlite a partir de free-exercise-db.

Uso: python build_exercise_db.py [--out ../assets/exercise_db.sqlite]
"""
import argparse
import json
import sqlite3
from pathlib import Path

DATA_URL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"

_EQUIPMENT_MAP = {
    None: "bodyweight",
    "": "bodyweight",
    "body only": "bodyweight",
    "dumbbell": "dumbbell",
    "barbell": "barbell",
    "e-z curl bar": "barbell",
    "machine": "machine",
    "cable": "cable",
    "kettlebells": "kettlebell",
    "bands": "bands",
}

# Equipo cargado => trabajo de fuerza; peso corporal/bandas => sirve para ambas.
_STRENGTH_EQUIPMENT = {"dumbbell", "barbell", "machine", "cable", "kettlebell"}

COLUMNS = [
    "id", "name", "category", "force", "difficulty", "mechanic", "equipment",
    "primary_muscles", "secondary_muscles", "instructions", "static_images",
    "gif_key", "modality", "variation_group", "variation_rank",
]


def map_equipment(raw):
    if raw is not None:
        raw = raw.lower().strip()
    return _EQUIPMENT_MAP.get(raw, "other")


def infer_modality(equipment):
    return "strength" if equipment in _STRENGTH_EQUIPMENT else "both"


def normalize_exercise(raw):
    equipment = map_equipment(raw.get("equipment"))
    return {
        "id": raw["id"],
        "name": raw["name"],
        "category": raw.get("category"),
        "force": raw.get("force"),
        "difficulty": raw.get("level") or "beginner",
        "mechanic": raw.get("mechanic"),
        "equipment": equipment,
        "primary_muscles": json.dumps(raw.get("primaryMuscles", [])),
        "secondary_muscles": json.dumps(raw.get("secondaryMuscles", [])),
        "instructions": json.dumps(raw.get("instructions", [])),
        "static_images": json.dumps(raw.get("images", [])),
        "gif_key": None,
        "modality": infer_modality(equipment),
        "variation_group": None,
        "variation_rank": 0,
    }


def build_db(rows, out_path):
    out = Path(out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()
    con = sqlite3.connect(out)
    try:
        con.execute(
            """
            CREATE TABLE exercises (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              category TEXT,
              force TEXT,
              difficulty TEXT NOT NULL,
              mechanic TEXT,
              equipment TEXT NOT NULL,
              primary_muscles TEXT NOT NULL,
              secondary_muscles TEXT NOT NULL,
              instructions TEXT NOT NULL,
              static_images TEXT NOT NULL,
              gif_key TEXT,
              modality TEXT NOT NULL,
              variation_group TEXT,
              variation_rank INTEGER NOT NULL DEFAULT 0
            )
            """
        )
        placeholders = ", ".join(["?"] * len(COLUMNS))
        con.executemany(
            f"INSERT INTO exercises ({', '.join(COLUMNS)}) VALUES ({placeholders})",
            [tuple(r[c] for c in COLUMNS) for r in rows],
        )
        con.commit()
    finally:
        con.close()
    return out


def _load_remote():
    import requests
    resp = requests.get(DATA_URL, timeout=60)
    resp.raise_for_status()
    return resp.json()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--out",
        default=str(Path(__file__).parent.parent / "assets" / "exercise_db.sqlite"),
    )
    args = ap.parse_args()
    raw = _load_remote()
    rows = [normalize_exercise(r) for r in raw]
    out = build_db(rows, args.out)
    print(f"Escritos {len(rows)} ejercicios en {out}")


if __name__ == "__main__":
    main()
