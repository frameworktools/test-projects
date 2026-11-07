* settings.do: paths for stata-project
*
* fw wrote this file from the project spec. Every do-file refers to folders
* through these globals, so the project runs on any machine without edits.
* Stata cannot read the project's YAML settings, so the paths live here.
*
* Run Stata from the project folder: cd to it first, or open master.do from
* there. The root is set from the current folder every time, because globals
* from another project in the same Stata session would otherwise linger.

global root `"`c(pwd)'"'
capture confirm file `"$root/settings.do"'
if _rc {
    display as error `"settings.do: $root is not the project folder. In Stata, cd to the folder that holds settings.do and master.do, then run the do-file again."'
    exit 601
}

* Folders
global do `"$root/do"'
global docs `"$root/docs"'
global inputs_final `"$root/inputs/final"'
global inputs_intermediate `"$root/inputs/intermediate"'
global inputs_raw `"$root/inputs/raw"'
global logs `"$root/logs"'
global outputs_figures `"$root/outputs/figures"'
global outputs_tables `"$root/outputs/tables"'
global scratch `"$root/scratch"'

* Shared study data, outside this project. Read it; never write to it.
global shared_csv `"$root/../../shared/csv"'

* Create folders that git does not keep (private data, logs, and outputs)
capture mkdir `"$root/do"'
capture mkdir `"$root/docs"'
capture mkdir `"$root/inputs"'
capture mkdir `"$root/inputs/final"'
capture mkdir `"$root/inputs/intermediate"'
capture mkdir `"$root/inputs/raw"'
capture mkdir `"$root/logs"'
capture mkdir `"$root/outputs"'
capture mkdir `"$root/outputs/figures"'
capture mkdir `"$root/outputs/tables"'
capture mkdir `"$root/scratch"'

