* 06_publish.do: publish a figure, a table, models, and documents to a local
* folder.
*
* The destination comes from settings.yml: publish.default is local-site, a
* folder destination at local-site/ in this project, with visibility private.
* Nothing leaves this computer. After this step, open local-site/index.html in
* a browser: one entry per artifact, each with an offline reader and its
* versions under v/1, v/2, and so on.

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* ---------------------------------------------------------------------------
* A figure
* ---------------------------------------------------------------------------

* Without to(), fw_publish uses publish.default. The slug (the artifact's
* name in its link) comes from the file name: bp-by-visit. Look for
* "Published to local-site (version 1): .../local-site/bp-by-visit".
fw_publish `"$outputs_figures/bp_by_visit.png"', ///
    title("Systolic blood pressure by visit") ///
    description("Means and 95% confidence intervals by treatment arm.")
return list

* Publishing the same slug again adds a version and keeps the earlier one.
* r(version) goes up by one each run; look in local-site/bp-by-visit/v/.
fw_publish `"$outputs_figures/bp_by_visit.png"', ///
    title("Systolic blood pressure by visit") ///
    description("Means and 95% confidence intervals by treatment arm.")
display as text "This publish made version " as result "`r(version)'"

* ---------------------------------------------------------------------------
* A table
* ---------------------------------------------------------------------------

* A CSV publishes as kind "file". slug() sets the name; kind() would override
* the detected kind, for example kind(table), if you want to compare how the
* reader shows it.
fw_publish `"$outputs_tables/bp_by_visit.csv"', slug(bp-by-visit-table) ///
    title("Systolic blood pressure by visit: table")

* ---------------------------------------------------------------------------
* Models
* ---------------------------------------------------------------------------

* fw_publish, estimates publishes the current estimation results as a
* model.json, the same document R and Python publish. estimates use restores
* the results 05_analysis.do saved. saving() keeps a copy of the model JSON;
* r(file) names it.
estimates use `"$scratch/bp_ols"'
fw_publish, estimates slug(bp-ols) ///
    title("Systolic blood pressure: linear model") ///
    description("regress with SEs clustered by participant.") ///
    saving(`"$outputs_tables/bp_ols_model.json"', replace)
return list

* With no title() or slug(), both come from the command and the outcome:
* the title is "mixed: systolic_bp" and the slug mixed-systolic-bp. The
* reader shows a fixed-effects table and a random-effects table.
estimates use `"$scratch/bp_mixed"'
fw_publish, estimates

* A logit: the reader offers an odds-ratio view. level(90) gives 90%
* intervals; fw_publish does not read the level the model was fit with.
estimates use `"$scratch/bp_logit"'
fw_publish, estimates slug(bp-logit) level(90) ///
    title("High blood pressure at the last visit (90% CIs)")

* ---------------------------------------------------------------------------
* Documents
* ---------------------------------------------------------------------------

* An HTML report from dyndoc (Stata 15 or newer). It runs the Stata code in
* docs/bp_report.md and writes docs/bp_report.html. The figure goes in
* docs/bp_report_files/, and fw_publish takes that folder along with the
* HTML. Look for kind html in local-site/bp-report/artifact.json.
capture mkdir `"$docs/bp_report_files"'
copy `"$outputs_figures/bp_by_visit.png"' `"$docs/bp_report_files/bp_by_visit.png"', replace
dyndoc `"$docs/bp_report.md"', saving(`"$docs/bp_report.html"') replace
fw_publish `"$docs/bp_report.html"', slug(bp-report) ///
    title("Blood pressure report")

* A Word document from putdocx (Stata 15 or newer). Any file can be
* published; a .docx is kind "file" and the reader offers it for download.
putdocx clear
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("Blood pressure by treatment arm")
putdocx paragraph
putdocx text ("Mean systolic blood pressure by visit, with 95% confidence intervals.")
putdocx paragraph, halign(center)
putdocx image `"$outputs_figures/bp_by_visit.png"', width(6)
putdocx save `"$docs/bp_brief.docx"', replace
fw_publish `"$docs/bp_brief.docx"', slug(bp-brief) title("Blood pressure brief")

* ---------------------------------------------------------------------------
* Destinations and visibility
* ---------------------------------------------------------------------------

* to() names a destination from settings.yml. This is the same as the default.
fw_publish `"$outputs_figures/bp_by_visit.png"', to(local-site) ///
    title("Systolic blood pressure by visit")

* visibility() must match the folder destination's visibility (private).
* private is short for visibility(private), so both of these work.
fw_publish `"$outputs_tables/bp_by_visit.csv"', slug(bp-by-visit-table) ///
    visibility(private) title("Systolic blood pressure by visit: table")
fw_publish `"$outputs_tables/bp_by_visit.csv"', slug(bp-by-visit-table) ///
    private title("Systolic blood pressure by visit: table")

* A visibility that does not match stops with error 198 and says why.
capture noisily fw_publish `"$outputs_figures/bp_by_visit.png"', visibility(public)
display as text "visibility(public) returned " as result _rc

* to(folder) alone has no path, so it stops with error 198.
capture noisily fw_publish `"$outputs_figures/bp_by_visit.png"', to(folder)
display as text "to(folder) returned " as result _rc

* An unknown destination name stops with error 198. The message names the
* drivers (cloud, github, folder, s3) and the destinations in settings.yml
* (here, local-site).
capture noisily fw_publish `"$outputs_figures/bp_by_visit.png"', to(nowhere)
display as text "to(nowhere) returned " as result _rc

* Two common mistakes: a file and estimates together, and no file at all.
capture noisily fw_publish `"$outputs_figures/bp_by_visit.png"', estimates
display as text "A file with estimates returned " as result _rc
capture noisily fw_publish
display as text "No file returned " as result _rc

* ---------------------------------------------------------------------------
* The same publish through the fw CLI backend
* ---------------------------------------------------------------------------

* Folders are normally handled by Stata itself. With FW_BACKEND cli for this
* session, fw_publish hands the file to fw (the path set in 01_setup.do with
* fw_set fw_path), which reads the same settings.yml and writes the same
* bundle format. Look for r(backend) = cli. If fw is not found, this stops
* with the steps to fix it and the tour goes on.
global FW_BACKEND cli
capture noisily fw_publish `"$outputs_figures/bp_by_visit.png"', ///
    slug(bp-by-visit-via-fw) title("Systolic blood pressure by visit (via fw)")
if _rc == 0 display as text "Backend: " as result "`r(backend)'" as text ", version " as result "`r(version)'"
global FW_BACKEND

* ---------------------------------------------------------------------------
* Look at the result
* ---------------------------------------------------------------------------

display as text "Open this in a browser: " as result `"$root/local-site/index.html"'
* To open it from Stata, run:
*   view browse `"file://$root/local-site/index.html"'
