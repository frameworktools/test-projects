-- Tables for the local demo database, used by notebooks/03-databases.qmd.
-- db_execute_file() runs every statement in order, in one transaction.

DROP TABLE IF EXISTS sites;
DROP TABLE IF EXISTS visit_flags;

CREATE TABLE sites (
    site_id   INTEGER PRIMARY KEY,
    site_name TEXT NOT NULL,
    city      TEXT,
    state     TEXT,
    setting   TEXT
);

-- Visits at or above 140 mmHg systolic, filled by the notebook.
CREATE TABLE visit_flags (
    participant_id INTEGER,
    visit_number   INTEGER,
    systolic_bp    REAL,
    flag           TEXT DEFAULT 'high; review'
);
