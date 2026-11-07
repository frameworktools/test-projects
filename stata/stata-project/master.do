* master.do: runs every step of stata-project in order
*
* Open Stata in the project folder, then run:  do master.do
* Each step is its own do-file. To add a step, write the do-file and add a
* line below.

version 16
clear all
set more off

do "settings.do"

capture log close master
local stamp = subinstr("`c(current_date)'", " ", "", .) + "_" + subinstr("`c(current_time)'", ":", "", .)
log using `"$logs/master_`stamp'.log"', name(master) text replace

* A guided tour of Framework for Stata. Each step's comments say what to
* look for in the Results window.
do `"$do/01_setup.do"'        // fw_setup, fw_set, fw_project
do `"$do/02_import.do"'       // fw_use and fw_save: shared CSVs to inputs/raw
do `"$do/03_clean.do"'        // merges and labels; final analysis datasets
do `"$do/04_integrity.do"'    // a changed file stops fw_use; warn, accept, off
do `"$do/05_analysis.do"'     // table, figure, and three models
do `"$do/06_publish.do"'      // fw_publish to the local-site folder
do `"$do/07_cloud.do"'        // fw_login and Cloud, shown offline

log close master
