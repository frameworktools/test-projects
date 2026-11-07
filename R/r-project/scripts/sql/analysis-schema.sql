-- Schema for the local analysis database (connection: analysis).
-- Run from R with db_execute_file(); safe to rerun.

DROP TABLE IF EXISTS sites;

CREATE TABLE sites (
  site_id   INTEGER PRIMARY KEY,
  site_name TEXT NOT NULL,
  city      TEXT NOT NULL,
  state     TEXT NOT NULL,
  setting   TEXT NOT NULL
);

DROP VIEW IF EXISTS site_bp_with_setting;

-- site_bp is created in notebook 03 before this file runs
CREATE VIEW site_bp_with_setting AS
SELECT b.*, s.setting, s.state
FROM site_bp b
JOIN sites s ON s.site_name = b.site_name;
