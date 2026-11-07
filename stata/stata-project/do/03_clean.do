* 03_clean.do: label, merge, and save the analysis datasets.
*
* Every input comes in through fw_use, so each one is checked against its
* record before it is used. Merges read from tempfiles made from those checked
* loads, never from the .dta files directly. The outputs are:
*   inputs.intermediate.participants   one row per participant (unlocked)
*   inputs.final.participants          one row per participant, with survey
*   inputs.final.visits_long           one row per visit, with labs and
*                                      participant data (the analysis file)

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* ---------------------------------------------------------------------------
* Sites: four clinics
* ---------------------------------------------------------------------------

fw_use inputs.raw.sites, clear
label variable site_name "Site"
label variable setting "Urban or rural site"
keep site_id site_name setting state
tempfile sites
save `sites'

* ---------------------------------------------------------------------------
* Participants: labels, dates, and the site
* ---------------------------------------------------------------------------

fw_use inputs.raw.participants, clear

* import delimited keeps ISO dates as text. Convert them to Stata dates.
generate enrolled = date(enrolled_on, "YMD")
format enrolled %td
assert !missing(enrolled)
drop enrolled_on

* Treatment arm and sex as labeled 0/1 variables, so tables and models read well.
label define arm 0 "Control" 1 "Intervention"
generate byte arm = (treatment == "intervention")
assert inlist(treatment, "control", "intervention")
label values arm arm
label define female 0 "Male" 1 "Female"
generate byte female = (sex == "female")
label values female female
label define yesno 0 "No" 1 "Yes"
label values smoker yesno
drop treatment sex

label variable participant_id "Participant ID"
label variable enrolled "Enrollment date"
label variable age "Age (years)"
label variable bmi "Body mass index"
label variable smoker "Current smoker"
label variable arm "Treatment arm"
label variable female "Female"

* Every participant has a site, so the merge must match every row.
merge m:1 site_id using `sites', assert(match using) keep(match) nogenerate

* An intermediate dataset saved unlocked: it is expected to change while the
* cleaning code changes, so fw_use will warn rather than stop when it differs
* from its record. Look for "Saved inputs.intermediate.participants" and
* r(locked) = 0.
fw_save inputs.intermediate.participants, replace unlocked
return list

* ---------------------------------------------------------------------------
* Survey: one row per participant who answered (about 250 of 300)
* ---------------------------------------------------------------------------

fw_use inputs.raw.survey, clear
generate survey_date = date(completed_on, "YMD")
format survey_date %td
drop completed_on
label define satisfaction 1 "very low" 2 "low" 3 "neutral" 4 "high" 5 "very high"
encode satisfaction, generate(satisfaction_n) label(satisfaction)
drop satisfaction
rename satisfaction_n satisfaction
label variable sleep_hours "Sleep (hours per night)"
label variable exercise_days "Exercise (days per week)"
label variable stress_score "Stress score"
label variable satisfaction "Satisfaction with care"
label variable survey_date "Survey date"
tempfile survey
save `survey'

* Participant file with the survey. Participants without a survey stay in.
fw_use inputs.intermediate.participants, clear
merge 1:1 participant_id using `survey', keep(master match) generate(has_survey)
replace has_survey = (has_survey == 3)
label values has_survey yesno
label variable has_survey "Answered the survey"
tabulate arm has_survey

* A final dataset saved locked (the default).
fw_save inputs.final.participants, replace
tempfile participants
save `participants'

* ---------------------------------------------------------------------------
* Labs: long (one row per test) to wide (one row per visit)
* ---------------------------------------------------------------------------

fw_use inputs.raw.labs, clear
keep visit_id test value
reshape wide value, i(visit_id) j(test) string
rename value* *
label variable hba1c "HbA1c (%)"
label variable ldl "LDL cholesterol (mg/dL)"
label variable crp "C-reactive protein (mg/L)"
tempfile labs
save `labs'

* ---------------------------------------------------------------------------
* Visits: the analysis file
* ---------------------------------------------------------------------------

fw_use inputs.raw.visits, clear
rename visit_date visit_date_str
generate visit_date = date(visit_date_str, "YMD")
format visit_date %td
drop visit_date_str
label variable visit_number "Visit"
label variable visit_date "Visit date"
label variable systolic_bp "Systolic blood pressure (mmHg)"
label variable diastolic_bp "Diastolic blood pressure (mmHg)"
label variable weight_kg "Weight (kg)"

merge 1:1 visit_id using `labs', assert(master match) nogenerate
merge m:1 participant_id using `participants', assert(match) nogenerate

* Months since enrollment, for a time scale that is not just the visit number.
generate months = (visit_date - enrolled) / 30.4375
label variable months "Months since enrollment"

order participant_id visit_id visit_number visit_date months arm
sort participant_id visit_number
describe, short

fw_save inputs.final.visits_long, replace
