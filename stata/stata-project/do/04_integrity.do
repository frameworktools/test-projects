* 04_integrity.do: change a tracked file behind Framework's back and watch
* fw_use catch it.
*
* The demo works on copies in scratch/, so the real analysis files stay as
* 03_clean.do left them. scratch.<name> is a dot name for $scratch/<name>.dta.
*
* The four check() modes of fw_use:
*   strict  (default) a changed locked dataset stops with error 459
*   warn    loads it once with a warning and keeps the old record
*   accept  loads it and records it as it is now; the file is not rewritten
*   off     skips the check and the record

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* ---------------------------------------------------------------------------
* A locked dataset
* ---------------------------------------------------------------------------

* Save a copy of the analysis file under a new name. fw_save locks it.
fw_use inputs.final.visits_long, clear
fw_save scratch.tamper_demo, replace
local saved_sha `"`r(sha256)'"'

* An unchanged file loads quietly. r(sha256) matches what fw_save recorded.
fw_use scratch.tamper_demo, clear
display as text "Recorded: " as result "`saved_sha'"
display as text "Now:      " as result "`r(sha256)'"

* Change the file without fw_save, as an outside edit would: one blood
* pressure reading goes up by 5. A plain save does not update the record.
replace systolic_bp = systolic_bp + 5 in 1
save `"$scratch/tamper_demo.dta"', replace

* strict: fw_use stops with error 459 before loading. The message shows the
* file, the recorded and current checksums, and the command that accepts the
* change. The data in memory is left as it was.
capture noisily fw_use scratch.tamper_demo, clear
display as text "fw_use returned " as result _rc as text " (459 means: a locked dataset changed)."

* warn: loads the changed file with warnings and keeps the old record, so
* the next strict load stops again.
fw_use scratch.tamper_demo, clear check(warn)
capture fw_use scratch.tamper_demo, clear
display as text "After check(warn), a strict fw_use still returns " as result _rc

* accept: records the file as it is now (new SHA-256, new datasignature,
* new time) and keeps the lock. Look for "Accepted scratch.tamper_demo as it
* is now" and r(accepted) = 1, r(locked) = 1.
fw_use scratch.tamper_demo, clear check(accept)
return list

* Now a strict load passes again. Accepting an unchanged file says "matches
* its record. Nothing to accept."
fw_use scratch.tamper_demo, clear
fw_use scratch.tamper_demo, clear check(accept)

* off: no check and no record update. Useful for a quick look; it loads even
* a changed locked file without a word.
fw_use scratch.tamper_demo, clear check(off)

* ---------------------------------------------------------------------------
* What counts as a change
* ---------------------------------------------------------------------------

* The SHA-256 covers every byte of the file, so a label-only change is a
* change too, even though datasignature (values and variable names) is the
* same. Look for the "changed since Framework recorded it" message and 459.
fw_use scratch.tamper_demo, clear
label variable systolic_bp "Systolic BP, relabeled outside Framework"
save `"$scratch/tamper_demo.dta"', replace
capture noisily fw_use scratch.tamper_demo, clear
display as text "Label-only change: fw_use returned " as result _rc
fw_use scratch.tamper_demo, clear check(accept)

* ---------------------------------------------------------------------------
* An unlocked dataset
* ---------------------------------------------------------------------------

* Unlocked datasets may change. fw_use warns, loads, and updates the record,
* so the second load is quiet. Look for warnings on the first load (one for
* the file checksum, one for the datasignature) and none on the second.
fw_save scratch.tamper_unlocked, replace unlocked
keep in 1/100
save `"$scratch/tamper_unlocked.dta"', replace
fw_use scratch.tamper_unlocked, clear
display as text "Observations after the outside edit: " as result c(N)
fw_use scratch.tamper_unlocked, clear

* ---------------------------------------------------------------------------
* Accept works only for tracked names
* ---------------------------------------------------------------------------

* A plain path is never recorded, so there is nothing to accept: error 198.
capture noisily fw_use `"$scratch/tamper_demo.dta"', clear check(accept)
display as text "check(accept) on a plain path returned " as result _rc

* The records for both demo files. Compare the recorded_at times and the
* locked column (1 for tamper_demo, 0 for tamper_unlocked).
type `"$root/.framework/stata-integrity.tsv"'

* The real analysis file was never touched, so it still loads strictly.
fw_use inputs.final.visits_long, clear
