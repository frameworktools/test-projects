#!/usr/bin/env Rscript
# build-analysis-data
# Created: 2026-11-07
#
# Builds the analysis dataset used by notebooks 04 to 06: one row per visit,
# with the participant's arm, site, and change in systolic pressure from their
# first visit. Run it from the project root or any subfolder:
#
#   Rscript scripts/build-analysis-data.R
#
# Notebook 02 runs this script too, so you can watch each step there.

# Load project environment
library(framework)
scaffold()

# Visits come from the raw extract registered in notebook 02; participant and
# site details come straight from the shared study database.
visits <- data_read("inputs.raw.visits")

participants <- db_query(
  "SELECT p.participant_id, p.age, p.sex, p.bmi, p.smoker, p.treatment,
          s.site_name, s.setting
   FROM participants p
   JOIN sites s ON s.site_id = p.site_id",
  "study"
)

bp_long <- visits |>
  dplyr::inner_join(participants, by = "participant_id") |>
  dplyr::arrange(participant_id, visit_number) |>
  dplyr::group_by(participant_id) |>
  # Change from the first visit with a recorded pressure, so a missing
  # baseline doesn't drop the whole participant
  dplyr::mutate(
    baseline_systolic = dplyr::first(systolic_bp, na_rm = TRUE),
    systolic_change = systolic_bp - baseline_systolic
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(
    treatment = factor(treatment, levels = c("control", "intervention")),
    bp_category = classify_bp(systolic_bp, diastolic_bp)
  )

stopifnot(nrow(bp_long) == nrow(visits))

# Dot notation: inputs.final.bp_long -> inputs/final/bp_long.rds, registered
# in the data catalog with a hash.
data_save(bp_long, "inputs.final.bp_long")
