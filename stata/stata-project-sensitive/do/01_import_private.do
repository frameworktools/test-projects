* 01_import_private.do: bring the record-level study data into private folders.
*
* This project treats the study data as restricted. Record-level files live
* only under inputs/private/ and outputs/private/, which are gitignored. Only
* reviewed aggregates go in public/ folders, and only those are published.
*
* Following the project's restricted-data rules, these do-files describe
* record-level data but never list or browse it.

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* fw_project lists both sides of the split. Look for $fw_inputs_private_raw
* and $fw_inputs_public_final, and note that $fw_data points to the public
* final folder: the short alias is the shareable one.
fw_project
display as text "fw_data: " as result `"$fw_data"'

* Dot names follow the folders: inputs.private.raw.visits is
* $inputs_private_raw/visits.dta. Each file is saved locked.
foreach table in sites participants visits {
    fw_use study.`table', clear
    fw_save inputs.private.raw.`table', replace
}

* Structure only: variable names and types, no values.
describe, short
describe, simple

* The integrity record holds names, paths, and checksums, never data values.
type `"$root/.framework/stata-integrity.tsv"'
