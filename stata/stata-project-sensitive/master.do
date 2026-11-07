* master.do: runs every step of stata-project-sensitive in order
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

* The private/public split: record-level data stays in private folders, a
* checked aggregate goes to public folders, and only public files publish.
do `"$do/01_import_private.do"'    // shared CSVs to inputs/private/raw
do `"$do/02_clean_private.do"'     // record-level analysis file, private
do `"$do/03_aggregate_public.do"'  // small-cell check, then public aggregate
do `"$do/04_publish_public.do"'    // publish public results; the private guard

log close master
