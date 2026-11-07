<<dd_do: quietly>>
fw_use inputs.final.visits_long, clear
quietly summarize systolic_bp if arm == 0 & visit_number == 1
scalar c1 = r(mean)
quietly summarize systolic_bp if arm == 1 & visit_number == 1
scalar i1 = r(mean)
quietly summarize systolic_bp if arm == 0 & visit_number == 4
scalar c4 = r(mean)
quietly summarize systolic_bp if arm == 1 & visit_number == 4
scalar i4 = r(mean)
quietly count if visit_number == 1
scalar n_people = r(N)
<</dd_do>>

# Blood pressure by treatment arm

A short report from the stata-project test project. Stata built it with
dyndoc in do/06_publish.do, and fw_publish published it with its
bp_report_files folder.

The study followed <<dd_display: %3.0f n_people>> participants for up to four
visits. At the first visit, mean systolic blood pressure was
<<dd_display: %5.1f c1>> mmHg in the control arm and <<dd_display: %5.1f i1>>
mmHg in the intervention arm. At the fourth visit it was
<<dd_display: %5.1f c4>> and <<dd_display: %5.1f i4>> mmHg.

![Mean systolic blood pressure by visit and arm](bp_report_files/bp_by_visit.png)

## Means by visit and arm

<<dd_do>>
tabulate visit_number arm, summarize(systolic_bp) means obs
<</dd_do>>
