* 02_import.do: read the shared study CSVs and save them as raw .dta files.
*
* A tour of fw_use and fw_save with the three kinds of dataset name:
*   - catalog names, such as study.visits, from the data section of settings.yml
*   - dot names, such as inputs.raw.visits, which mean $inputs_raw/visits.dta
*   - plain file paths, which Framework reads and writes but does not track

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* ---------------------------------------------------------------------------
* A catalog name: a shared CSV, checked against its recorded checksum
* ---------------------------------------------------------------------------

* study.participants is in the data catalog in settings.yml, so fw_use finds
* the CSV in shared/csv and reads it with import delimited. The first read
* records the file's SHA-256 and datasignature; later reads compare against
* them. Look for "Loaded study.participants from ... (300 observations)".
fw_use study.participants, clear

* r(locked) is 1 because the catalog entry says locked: true. r(type) is csv,
* and r(sha256) is the checksum of the shared file.
return list

* ---------------------------------------------------------------------------
* Import every table into inputs/raw as a locked .dta file
* ---------------------------------------------------------------------------

* fw_save inputs.raw.<name> writes $inputs_raw/<name>.dta and records its
* checksum. fw_save locks a dataset unless you add unlocked, so a later change
* to these files stops fw_use. replace lets this step run again.
foreach table in sites participants visits labs survey {
    fw_use study.`table', clear
    fw_save inputs.raw.`table', replace
}

* fw_save without replace refuses to overwrite an existing file (error 602).
capture noisily fw_save inputs.raw.survey
display as text "fw_save without replace returned " as result _rc as text " (602 means: file exists)."

* Every tracked name has a row here: name, path, sha256, datasignature, locked,
* bytes, and time. Look for five study.* rows (the CSVs) and five inputs.raw.*
* rows (the .dta files), all with locked = 1.
type `"$root/.framework/stata-integrity.tsv"'

* ---------------------------------------------------------------------------
* A plain file path: read, but not tracked
* ---------------------------------------------------------------------------

* participant_summary.csv is not in the catalog. A file path works, and
* options() passes options to import delimited. Look at r(sha256): it is empty,
* because plain paths are not recorded or checked.
fw_use `"$shared_csv/participant_summary.csv"', clear options(varnames(1) case(preserve))
return list
describe, short

* A dot name always means a .dta file in a project folder. This one has no
* file yet, so fw_use stops with error 601 and names the file it looked for.
capture noisily fw_use inputs.raw.participant_summary, clear
display as text "fw_use of a missing dataset returned " as result _rc

* A dot name that matches no project folder lists the folders that exist.
capture noisily fw_use nowhere.participants, clear
display as text "fw_use of an unknown folder returned " as result _rc

* fw_save protects source data. study.visits is a locked catalog entry that
* points at the shared CSV, so writing to it stops with error 608 and leaves
* shared/csv/visits.csv untouched.
capture noisily fw_save study.visits, replace
display as text "fw_save to a locked catalog entry returned " as result _rc

* A path outside the project root stops with error 198 unless you add the
* outside option. Here the global points at the shared folder.
capture noisily fw_save `"$shared_csv/visits_copy.dta"'
display as text "fw_save outside the project returned " as result _rc
