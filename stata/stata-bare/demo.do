* demo.do: Framework for Stata in a bare project.
*
* A bare project has only settings.do and .framework/: no folders, no
* master.do, no settings.yml. This shows what works with nothing configured.
* Open Stata in this folder and run:  do demo.do

version 16
clear all
set more off
do "settings.do"

* fw_project finds the project by its .framework/ folder. Look for the
* project name and root, and no Folders list: settings.do defines none.
fw_project
return list

* File paths work without any setup. This reads a shared CSV directly. It is
* not tracked: r(sha256) is empty because only named datasets are recorded.
fw_use `"$root/../../shared/csv/visits.csv"', clear
return list

* Mean systolic blood pressure by visit.
collapse (mean) mean_sbp = systolic_bp (count) n = systolic_bp, by(visit_number)
format mean_sbp %6.1f
list, noobs

* fw_save by path creates the folder it needs, here demo_output/.
fw_save "demo_output/bp_by_visit.csv", replace

* graph export does not create folders, but fw_save just made this one.
twoway connected mean_sbp visit_number, xlabel(1(1)4) ///
    xtitle("Visit") ytitle("Mean systolic blood pressure (mmHg)") ///
    graphregion(color(white)) plotregion(color(white))
graph export "demo_output/bp_by_visit.png", replace width(1200)

* Dot names need project folders. With none, fw_save stops with error 601
* and says "Available folders: none". Adding a line such as
*   global outputs `"$root/outputs"'
* to settings.do would make outputs.bp_by_visit mean outputs/bp_by_visit.dta.
capture noisily fw_save demo.bp_by_visit, replace
display as text "A dot name in a bare project returned " as result _rc

* With no publish.default, fw_publish goes to Framework Cloud. This project
* has no project token, so it stops before sending anything, with error 677
* and the steps to set one up. A settings.yml with a folder destination, as
* in stata-project, would publish locally instead.
capture noisily fw_publish "demo_output/bp_by_visit.png"
display as text "fw_publish with no destination returned " as result _rc
