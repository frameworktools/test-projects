* 02_clean_private.do: build the record-level analysis file, still private.
*
* Output: inputs.private.final.visits_long ($inputs_private_final/visits_long.dta)

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

fw_use inputs.private.raw.sites, clear
keep site_id site_name setting
label variable site_name "Site"
tempfile sites
save `sites'

fw_use inputs.private.raw.participants, clear
label define arm 0 "Control" 1 "Intervention"
generate byte arm = (treatment == "intervention")
label values arm arm
label variable arm "Treatment arm"
generate byte female = (sex == "female")
label variable female "Female"
drop treatment sex enrolled_on
merge m:1 site_id using `sites', assert(match using) keep(match) nogenerate
tempfile participants
save `participants'

fw_use inputs.private.raw.visits, clear
drop visit_date
label variable visit_number "Visit"
label variable systolic_bp "Systolic blood pressure (mmHg)"
merge m:1 participant_id using `participants', assert(match) nogenerate
sort participant_id visit_number

* Dates are identifying, so the analysis file keeps only the visit number.
describe, short
fw_save inputs.private.final.visits_long, replace

* A record-level figure: one line per participant. Useful to the analyst,
* not shareable, so it goes to outputs/private/figures.
xtset participant_id visit_number
xtline systolic_bp, overlay legend(off) ///
    ytitle("Systolic blood pressure (mmHg)") xtitle("Visit") ///
    title("Systolic blood pressure, each participant") ///
    graphregion(color(white)) plotregion(color(white))
graph export `"$outputs_private_figures/bp_individual.png"', replace width(1600)
