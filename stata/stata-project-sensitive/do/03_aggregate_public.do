* 03_aggregate_public.do: make the aggregate that may leave the private side.
*
* Following the project's rules, the aggregate goes to a private output folder
* first, gets a small-cell check, and only then is written to public folders:
*   outputs/private/tables/bp_aggregate_unchecked.csv   before suppression
*   inputs.public.final.bp_aggregate                    after suppression
*   outputs/public/tables/bp_aggregate.csv              the same, as CSV
*   outputs/public/figures/bp_by_visit.png              figure from the aggregate

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* The smallest cell count that may be shown.
local min_cell 11

fw_use inputs.private.final.visits_long, clear

* Means by site, arm, and visit, with the number of participants behind each.
collapse (mean) mean_sbp = systolic_bp (sd) sd_sbp = systolic_bp ///
    (count) n = systolic_bp, by(site_name arm visit_number)
label variable mean_sbp "Mean systolic BP (mmHg)"
label variable sd_sbp "SD of systolic BP"
label variable n "Participants with a reading"
format mean_sbp sd_sbp %6.1f

* Unchecked aggregate: private until reviewed.
fw_save `"$outputs_private_tables/bp_aggregate_unchecked.csv"', replace

* Small-cell check: blank out any cell with fewer than `min_cell' people.
* Look at the count: with about 300 participants over 4 sites, 2 arms, and
* 4 visits, a few late-visit cells may fall below the threshold.
generate byte suppressed = (n < `min_cell')
label variable suppressed "Suppressed: fewer than `min_cell' participants"
count if suppressed
display as text "Cells suppressed: " as result r(N) as text " of " as result _N
replace mean_sbp = . if suppressed
replace sd_sbp = . if suppressed
replace n = . if suppressed

* The checked aggregate as a public, locked dataset. inputs.public.final is
* also $fw_data, the folder other projects and people may read.
fw_save inputs.public.final.bp_aggregate, replace
fw_save `"$outputs_public_tables/bp_aggregate.csv"', replace options(datafmt)

* A figure built only from the public aggregate: participant-weighted means
* of the site means, by arm and visit. Suppressed cells stay out.
drop if suppressed
collapse (mean) mean_sbp [aweight = n], by(arm visit_number)
twoway ///
    (connected mean_sbp visit_number if arm == 0, lcolor("42 120 214") ///
        mcolor("42 120 214") msymbol(circle)) ///
    (connected mean_sbp visit_number if arm == 1, lcolor("235 104 52") ///
        mcolor("235 104 52") msymbol(square)), ///
    legend(order(1 "Control" 2 "Intervention") rows(1) position(6)) ///
    xlabel(1(1)4) xtitle("Visit") ytitle("Mean systolic blood pressure (mmHg)") ///
    title("Systolic blood pressure by visit and treatment arm") ///
    note("From site-level aggregates; cells under `min_cell' participants suppressed.") ///
    graphregion(color(white)) plotregion(color(white))
graph export `"$outputs_public_figures/bp_by_visit.png"', replace width(1600)
