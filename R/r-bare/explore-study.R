#!/usr/bin/env Rscript
# explore-study
# Created: 2026-11-07
#
# A bare project is just settings.yml (plus .gitignore and .framework/). There
# are no directories, notebooks, or Quarto config, but scaffold(), packages,
# connections, the data catalog, and caching all work. Run it from this folder:
#
#   Rscript explore-study.R
#
# or step through it line by line in the console.

# Load project environment: attaches dplyr, ggplot2, and friends, and creates
# framework.db on the first run
library(framework)
scaffold()

# What a bare project has: a type, and no configured directories
project_info()

# The study connection was added to settings.yml by hand
connections_list()

# Average systolic pressure by arm, straight from the shared database
sbp_by_arm <- db_query(
  "SELECT p.treatment, COUNT(v.systolic_bp) AS n, ROUND(AVG(v.systolic_bp), 1) AS mean_systolic
   FROM visits v
   JOIN participants p ON p.participant_id = v.participant_id
   GROUP BY p.treatment",
  "study"
)
print(sbp_by_arm)

# With no output folders configured, save_table() falls back to a default
# location; this prints where it went
save_table(sbp_by_arm, "sbp_by_arm")

# Data saved by path gets a hash in framework.db, and the path starts at the
# project root wherever you run from. With no directories configured there
# are no dot names, so read and verify it by path
data_save(sbp_by_arm, "data/sbp_by_arm.csv", force = TRUE)
data_verify("data/sbp_by_arm.csv")

# Caching works without a cache directory in settings
site_counts <- cache_remember("site_counts", db_query(
  "SELECT s.site_name, COUNT(*) AS n FROM participants p JOIN sites s ON s.site_id = p.site_id GROUP BY s.site_name",
  "study"
))
print(site_counts)
print(cache_list())

# A bare project can grow: make_notebook() and make_script() work here too
# (Quarto is off in this project, so make_notebook() makes an .Rmd)
# make_notebook("first-look")
