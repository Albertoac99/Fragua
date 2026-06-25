import json
import sqlite3
from pathlib import Path

import build_exercise_db as b

FIXTURE = Path(__file__).parent / "fixtures" / "sample_exercises.json"


def test_map_equipment():
    assert b.map_equipment("body only") == "bodyweight"
    assert b.map_equipment(None) == "bodyweight"
    assert b.map_equipment("barbell") == "barbell"
    assert b.map_equipment("e-z curl bar") == "barbell"
    assert b.map_equipment("kettlebells") == "kettlebell"
    assert b.map_equipment("medicine ball") == "other"


def test_infer_modality():
    assert b.infer_modality("barbell") == "strength"
    assert b.infer_modality("dumbbell") == "strength"
    assert b.infer_modality("bodyweight") == "both"
    assert b.infer_modality("bands") == "both"


def test_normalize_exercise_shape():
    raw = json.loads(FIXTURE.read_text())[0]  # Barbell_Squat
    row = b.normalize_exercise(raw)
    assert row["id"] == "Barbell_Squat"
    assert row["equipment"] == "barbell"
    assert row["modality"] == "strength"
    assert row["difficulty"] == "intermediate"
    assert json.loads(row["primary_muscles"]) == ["quadriceps"]
    assert json.loads(row["static_images"]) == [
        "Barbell_Squat/0.jpg",
        "Barbell_Squat/1.jpg",
    ]
    assert row["gif_key"] is None
    assert row["variation_rank"] == 0
    # 15 columnas exactas del esquema drift
    assert set(row.keys()) == {
        "id", "name", "category", "force", "difficulty", "mechanic",
        "equipment", "primary_muscles", "secondary_muscles", "instructions",
        "static_images", "gif_key", "modality", "variation_group",
        "variation_rank",
    }


def test_normalize_handles_nulls():
    raw = json.loads(FIXTURE.read_text())[1]  # Plank
    row = b.normalize_exercise(raw)
    assert row["mechanic"] is None
    assert row["equipment"] == "bodyweight"
    assert row["modality"] == "both"
    assert json.loads(row["secondary_muscles"]) == []


def test_build_db_creates_queryable_file(tmp_path):
    raws = json.loads(FIXTURE.read_text())
    rows = [b.normalize_exercise(r) for r in raws]
    out = b.build_db(rows, tmp_path / "exercise_db.sqlite")

    con = sqlite3.connect(out)
    try:
        count = con.execute("SELECT COUNT(*) FROM exercises").fetchone()[0]
        names = {r[0] for r in con.execute("SELECT name FROM exercises")}
        cols = [c[1] for c in con.execute("PRAGMA table_info(exercises)")]
    finally:
        con.close()

    assert count == 3
    assert "Barbell Squat" in names
    assert cols == b.COLUMNS  # mismo orden y nombres que el esquema drift
