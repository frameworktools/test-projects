"""Build shared/study.sqlite and its CSV exports.

A small fictional cohort study used by every test project in this repo.
Deterministic: running it again produces the same data.

    python3 shared/scripts/build_database.py
"""

import csv
import random
import sqlite3
from datetime import date, timedelta
from pathlib import Path

SHARED = Path(__file__).resolve().parent.parent
DB_PATH = SHARED / "study.sqlite"
CSV_DIR = SHARED / "csv"

rng = random.Random(20261107)

SITES = [
    (1, "North Clinic", "Minneapolis", "MN", "urban"),
    (2, "Lakeside Health", "Duluth", "MN", "rural"),
    (3, "River Valley", "Madison", "WI", "urban"),
    (4, "Prairie Medical", "Fargo", "ND", "rural"),
]

SCHEMA = """
CREATE TABLE sites (
    site_id INTEGER PRIMARY KEY,
    site_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    setting TEXT NOT NULL CHECK (setting IN ('urban', 'rural'))
);
CREATE TABLE participants (
    participant_id INTEGER PRIMARY KEY,
    site_id INTEGER NOT NULL REFERENCES sites(site_id),
    enrolled_on TEXT NOT NULL,
    age INTEGER NOT NULL,
    sex TEXT NOT NULL,
    bmi REAL,
    smoker INTEGER NOT NULL,
    treatment TEXT NOT NULL CHECK (treatment IN ('control', 'intervention'))
);
CREATE TABLE visits (
    visit_id INTEGER PRIMARY KEY,
    participant_id INTEGER NOT NULL REFERENCES participants(participant_id),
    visit_number INTEGER NOT NULL,
    visit_date TEXT NOT NULL,
    systolic_bp INTEGER,
    diastolic_bp INTEGER,
    weight_kg REAL
);
CREATE TABLE labs (
    lab_id INTEGER PRIMARY KEY,
    visit_id INTEGER NOT NULL REFERENCES visits(visit_id),
    test TEXT NOT NULL,
    value REAL,
    unit TEXT NOT NULL
);
CREATE TABLE survey (
    participant_id INTEGER PRIMARY KEY REFERENCES participants(participant_id),
    completed_on TEXT NOT NULL,
    sleep_hours REAL,
    exercise_days INTEGER,
    stress_score INTEGER,
    satisfaction TEXT
);
CREATE INDEX idx_participants_site ON participants(site_id);
CREATE INDEX idx_visits_participant ON visits(participant_id);
CREATE INDEX idx_labs_visit ON labs(visit_id);
CREATE VIEW participant_summary AS
SELECT p.participant_id, s.site_name, s.setting, p.age, p.sex, p.bmi,
       p.smoker, p.treatment,
       COUNT(v.visit_id) AS n_visits,
       ROUND(AVG(v.systolic_bp), 1) AS mean_systolic_bp,
       MIN(v.weight_kg) AS min_weight_kg,
       MAX(v.weight_kg) AS max_weight_kg
FROM participants p
JOIN sites s ON s.site_id = p.site_id
LEFT JOIN visits v ON v.participant_id = p.participant_id
GROUP BY p.participant_id;
"""


def maybe_missing(value, rate=0.04):
    return None if rng.random() < rate else value


def build():
    participants, visits, labs, survey = [], [], [], []
    visit_id = lab_id = 0
    start = date(2024, 1, 8)
    for pid in range(1, 301):
        site_id = rng.choice([1, 1, 2, 3, 3, 4])
        enrolled = start + timedelta(days=rng.randint(0, 330))
        age = max(18, min(85, int(rng.gauss(52, 13))))
        sex = rng.choice(["female", "male"])
        bmi = round(rng.gauss(28.5, 5), 1)
        smoker = int(rng.random() < 0.18)
        treatment = rng.choice(["control", "intervention"])
        participants.append(
            (pid, site_id, enrolled.isoformat(), age, sex, maybe_missing(bmi), smoker, treatment)
        )

        base_sbp = 118 + 0.45 * (age - 50) + 0.8 * (bmi - 28) + 6 * smoker + rng.gauss(0, 9)
        base_wt = bmi * (1.75 if sex == "male" else 1.63) ** 2
        effect = -2.5 if treatment == "intervention" else -0.4
        n_visits = rng.choice([2, 3, 4, 4, 4])
        for k in range(n_visits):
            visit_id += 1
            vdate = enrolled + timedelta(days=90 * k + rng.randint(-7, 7))
            sbp = round(base_sbp + effect * k * 1.6 + rng.gauss(0, 5))
            dbp = round(sbp * 0.62 + rng.gauss(4, 4))
            wt = round(base_wt + effect * k * 0.7 + rng.gauss(0, 1.2), 1)
            visits.append(
                (visit_id, pid, k + 1, vdate.isoformat(), maybe_missing(sbp), maybe_missing(dbp), maybe_missing(wt))
            )
            for test, mean, sd, unit in [
                ("hba1c", 5.8 + 0.02 * (bmi - 28), 0.6, "%"),
                ("ldl", 118 + effect * k * 2, 28, "mg/dL"),
                ("crp", 2.4, 1.5, "mg/L"),
            ]:
                lab_id += 1
                labs.append((lab_id, visit_id, test, maybe_missing(round(max(0.1, rng.gauss(mean, sd)), 2)), unit))

        if rng.random() < 0.85:
            survey.append(
                (
                    pid,
                    (enrolled + timedelta(days=rng.randint(1, 30))).isoformat(),
                    maybe_missing(round(rng.gauss(6.9, 1.1), 1)),
                    maybe_missing(rng.randint(0, 7)),
                    maybe_missing(rng.randint(0, 40)),
                    rng.choice(["very low", "low", "neutral", "high", "very high"]),
                )
            )

    DB_PATH.unlink(missing_ok=True)
    con = sqlite3.connect(DB_PATH)
    con.executescript(SCHEMA)
    con.executemany("INSERT INTO sites VALUES (?,?,?,?,?)", SITES)
    con.executemany("INSERT INTO participants VALUES (?,?,?,?,?,?,?,?)", participants)
    con.executemany("INSERT INTO visits VALUES (?,?,?,?,?,?,?)", visits)
    con.executemany("INSERT INTO labs VALUES (?,?,?,?,?)", labs)
    con.executemany("INSERT INTO survey VALUES (?,?,?,?,?,?)", survey)
    con.commit()

    CSV_DIR.mkdir(exist_ok=True)
    for table in ["sites", "participants", "visits", "labs", "survey", "participant_summary"]:
        cur = con.execute(f"SELECT * FROM {table}")
        with open(CSV_DIR / f"{table}.csv", "w", newline="") as fh:
            writer = csv.writer(fh, lineterminator="\n")
            writer.writerow([d[0] for d in cur.description])
            writer.writerows(cur.fetchall())
    con.execute("VACUUM")
    con.close()

    print(f"{DB_PATH}: {len(participants)} participants, {len(visits)} visits, {len(labs)} labs, {len(survey)} surveys")


if __name__ == "__main__":
    build()
