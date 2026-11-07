* 05_analysis.do: blood pressure over visits by treatment arm.
*
* Makes the outputs that 06_publish.do publishes:
*   outputs/tables/bp_by_visit.csv    means and 95% CIs by arm and visit
*   outputs/figures/bp_by_visit.png   the same, as a figure
*   scratch/bp_ols.ster               linear model, SEs clustered by participant
*   scratch/bp_mixed.ster             random-intercept mixed model
*   scratch/bp_logit.ster             high blood pressure at the last visit

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* The analysis file from 03_clean.do, checked against its record.
fw_use inputs.final.visits_long, clear

* ---------------------------------------------------------------------------
* Descriptives
* ---------------------------------------------------------------------------

* Mean systolic blood pressure by visit and arm. Visits 3 and 4 have fewer
* participants; the intervention arm should drift lower over time.
tabulate visit_number arm, summarize(systolic_bp) means obs

* ---------------------------------------------------------------------------
* Table: means and confidence intervals by arm and visit
* ---------------------------------------------------------------------------

preserve
collapse (mean) mean_sbp = systolic_bp (sd) sd_sbp = systolic_bp ///
    (count) n = systolic_bp, by(arm visit_number)
generate double se = sd_sbp / sqrt(n)
generate double ci_low = mean_sbp - invttail(n - 1, 0.025) * se
generate double ci_high = mean_sbp + invttail(n - 1, 0.025) * se
label variable mean_sbp "Mean systolic BP (mmHg)"
label variable ci_low "95% CI, lower"
label variable ci_high "95% CI, upper"
label variable n "Participants with a reading"
format mean_sbp sd_sbp se ci_low ci_high %6.1f
list, sepby(arm) noobs

* A CSV by file path. fw_save writes it with export delimited; options()
* passes datafmt so the CSV uses the display formats (one decimal) above.
* Plain paths are not tracked, so there is no checksum in the message.
fw_save `"$outputs_tables/bp_by_visit.csv"', replace options(datafmt)

* ---------------------------------------------------------------------------
* Figure: the same means over visits, one line per arm
* ---------------------------------------------------------------------------

* The arms are nudged apart on the x axis so the intervals do not overlap.
* Color and marker shape both mark the arm, so the figure reads in grayscale.
generate visit_x = visit_number + cond(arm == 1, 0.06, -0.06)
twoway ///
    (rcap ci_low ci_high visit_x if arm == 0, lcolor("42 120 214")) ///
    (connected mean_sbp visit_x if arm == 0, lcolor("42 120 214") ///
        mcolor("42 120 214") msymbol(circle)) ///
    (rcap ci_low ci_high visit_x if arm == 1, lcolor("235 104 52")) ///
    (connected mean_sbp visit_x if arm == 1, lcolor("235 104 52") ///
        mcolor("235 104 52") msymbol(square)), ///
    legend(order(2 "Control" 4 "Intervention") rows(1) position(6)) ///
    xlabel(1(1)4) xtitle("Visit") ///
    ytitle("Systolic blood pressure (mmHg)") ///
    title("Systolic blood pressure by visit and treatment arm") ///
    note("Means with 95% confidence intervals.") ///
    graphregion(color(white)) plotregion(color(white))

* graph export does not create folders; settings.do already made this one.
graph export `"$outputs_figures/bp_by_visit.png"', replace width(1600)
restore

* ---------------------------------------------------------------------------
* Models
* ---------------------------------------------------------------------------

* Linear model: does the change over visits differ by arm? The interaction
* 1.arm#c.visit_number is the difference in slope. Standard errors are
* clustered by participant because each person has up to four visits.
regress systolic_bp i.arm##c.visit_number age i.female bmi i.smoker, ///
    vce(cluster participant_id)
estimates save `"$scratch/bp_ols"', replace

* The same question with a random intercept for each participant.
mixed systolic_bp i.arm##c.visit_number age i.female bmi i.smoker ///
    || participant_id:, reml
estimates save `"$scratch/bp_mixed"', replace

* High blood pressure (140 mmHg or more) at each participant's last visit.
* A logit, so the published model offers an odds-ratio view.
bysort participant_id (visit_number): keep if _n == _N
generate byte high_bp = (systolic_bp >= 140) if !missing(systolic_bp)
label variable high_bp "Systolic BP 140 or more at the last visit"
logit high_bp i.arm age i.female bmi i.smoker
estimates save `"$scratch/bp_logit"', replace
