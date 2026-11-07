* 04_publish_public.do: publish public results, and see the private-path guard.
*
* The destination is public-site, a folder at local-site/ with visibility
* public (settings.yml). Only files from public/ folders are published here.
* Open local-site/index.html in a browser afterwards.

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* ---------------------------------------------------------------------------
* Public results
* ---------------------------------------------------------------------------

* The checked aggregate table and the figure made from it.
fw_publish `"$outputs_public_tables/bp_aggregate.csv"', slug(bp-aggregate) ///
    title("Systolic blood pressure by site, arm, and visit") ///
    description("Site-level means. Cells under 11 participants suppressed.")
fw_publish `"$outputs_public_figures/bp_by_visit.png"', ///
    title("Systolic blood pressure by visit and treatment arm")

* A model fit on the public aggregate only: site-level means weighted by the
* number of participants behind them. fw_use reads it from the public folder
* and checks it against its record first.
fw_use inputs.public.final.bp_aggregate, clear
regress mean_sbp i.arm##c.visit_number [aweight = n]
fw_publish, estimates slug(bp-aggregate-model) ///
    title("Systolic blood pressure trend by arm (aggregate model)")

* fw_publish, estimates checks the file the data came from (the last fw_use
* or fw_save). This model was fit on inputs/public/final, so it publishes
* without a prompt. A model fit on private data would need includeprivate.

* The destination's visibility is public, so visibility(private) or the
* private option stops with error 198.
capture noisily fw_publish `"$outputs_public_figures/bp_by_visit.png"', private
display as text "private on a public destination returned " as result _rc

* ---------------------------------------------------------------------------
* The private-path guard
* ---------------------------------------------------------------------------

* A file whose path contains "private" needs confirmation. In interactive
* Stata, fw_publish lists the file and asks "Publish them anyway? Type y and
* press Enter". Type n: it prints "Cancelled. Nothing was published." and
* returns 1. In batch mode (stata -b) it stops with error 198 instead and
* says to add includeprivate.
capture noisily fw_publish `"$outputs_private_figures/bp_individual.png"', ///
    title("Each participant's blood pressure")
display as text "Publishing a private file returned " as result _rc ///
    as text " (1 = you declined, 198 = batch mode, 0 = you typed y)"

* includeprivate confirms in advance, for scripts. Do not run it here: this
* figure shows record-level data.
*   fw_publish `"$outputs_private_figures/bp_individual.png"', includeprivate

* The guard checks the path, not the content. A record-level file saved
* under public/ would publish without a prompt, which is why 03 checks small
* cells before anything is written to a public folder.
