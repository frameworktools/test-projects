* 01_setup.do: check the installation, set package options, and load the project.
*
* A guided tour of fw_setup, fw_set, and fw_project. Run it on its own from the
* project folder (do do/01_setup.do) or through master.do.

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* ---------------------------------------------------------------------------
* fw_setup: what works and what is missing
* ---------------------------------------------------------------------------

* fw_setup checks Stata, curl, the SHA-256 tool, the keyring, the Cloud login,
* fw, and Stata's Python. Look for "ok" next to curl and sha256, and for the
* project root and folder list under Project. Not being connected to Cloud is
* expected here and shows up as an optional next step.
* nonetwork skips the request that confirms a Cloud login. Checking Python
* starts Stata's Python for the session; add nopython to skip that.
fw_setup, nonetwork
display as text "fw_setup listed " as result r(steps) as text " next step(s)."
* r(steps) is the number of next steps it printed.

* ---------------------------------------------------------------------------
* fw_set: package options, stored for every project on this computer
* ---------------------------------------------------------------------------

* With no arguments, fw_set shows the stored options and the file that holds
* them (stata.conf in ~/.config/framework). Look for backend "auto (default)".
fw_set

* The Stata application on macOS starts with a short PATH, so it may not find
* fw. Point it at the fw built for these test projects. This setting applies
* to every project on this computer; undo it with: fw_set fw_path clear
fw_set fw_path "$root/../../bin/fw"

* Force the Stata-only backend, look at it, then go back to auto. With core,
* GitHub and S3 publishing stop with an error; folders and Cloud still work.
fw_set backend core
fw_set
fw_set backend auto

* The global FW_BACKEND overrides the stored backend for this session only.
* fw_set says so. Clear the global to go back to the stored setting.
global FW_BACKEND cli
fw_set
global FW_BACKEND

* fw_setup again: under "CLI backend (fw)" it should now find fw at the path
* above and show its version.
fw_setup, nonetwork nopython

* ---------------------------------------------------------------------------
* fw_project: find the project and set the $fw_* globals
* ---------------------------------------------------------------------------

* fw_project walks up from the current folder to the first folder with
* .framework/, settings.yml, or settings.do. It reads the folders from
* settings.do and the catalog and destinations from settings.yml. Look at the
* Folders list: one $fw_ global per folder, including $fw_shared_csv.
fw_project
return list

* The project's own globals from settings.do are left alone, so both point to
* the same folder. The do-files in this project use the settings.do globals
* for paths, as the project convention says, and dataset names for data.
display as text "settings.do:  " as result `"$inputs_raw"'
display as text "fw_project:   " as result `"$fw_inputs_raw"'
display as text "fw_data:      " as result `"$fw_data"' as text "  (alias for inputs/final)"
display as text "project name: " as result `"$fw_project_name"'

* root() starts the search somewhere else. Starting in do/ walks up one level
* to the same project. quietly skips the summary.
fw_project, root(`"$do"') quietly
display as text "Found from do/: " as result `"`r(root)'"'
