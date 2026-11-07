# Stata test projects

Hand-testing projects for Framework for Stata. Each one reads the shared study
data in `../shared/csv/` (Stata cannot read `study.sqlite` without ODBC) and
never writes to it.

All three projects run without errors in batch mode on Stata 17 with
framework-stata 0.1.1. Every `capture noisily` returns the code its comment
expects.

## Install

In Stata:

```stata
net install framework, from("https://raw.githubusercontent.com/frameworktools/framework-stata/v0.1.1") replace
```

Or from a local checkout: `net install framework, from("/Users/erik/Projects/framework-stata") replace`.

Run `fw_setup` once afterwards if you like; `01_setup.do` runs it too.

## Projects

| Project | Shows | Run |
|---|---|---|
| `stata-project` | Every command: `fw_setup`, `fw_set`, `fw_project`, `fw_use`, `fw_save`, integrity checks, `fw_publish` to a local folder, and `fw_login` (commented out) | `do master.do` |
| `stata-project-sensitive` | The private/public split: raw data in private folders, a small-cell-checked aggregate in public, publishing only public results, and the private-path prompt | `do master.do` |
| `stata-bare` | A bare project: paths only, no folders or settings | `do demo.do` |

Always start Stata in the project folder (`cd` there first). `settings.do`
sets the root from the current folder.

## stata-project, in order

`master.do` runs these; each also runs on its own from the project folder,
such as `do do/04_integrity.do`, once the earlier steps have run.

1. `01_setup.do`: `fw_setup`, `fw_set` (backend and `fw_path`), `fw_project`.
2. `02_import.do`: catalog, dot, and path names; shared CSVs to `inputs/raw`.
3. `03_clean.do`: merges participants, sites, survey, labs, and visits into
   `inputs.final.visits_long`.
4. `04_integrity.do`: changes a tracked file and shows `check(strict)`,
   `warn`, `accept`, and `off`, using copies in `scratch/`.
5. `05_analysis.do`: table, figure, and three models (regress, mixed, logit).
6. `06_publish.do`: figure, CSV, models, a dyndoc HTML report, and a putdocx
   Word file, published to `local-site/`. Also shows the error cases and the
   fw CLI backend.
7. `07_cloud.do`: `fw_login` and `fw_logout` as comments, and `to(cloud)`
   failing safely without a project token.

Open `local-site/index.html` in a browser after step 6.

## What was added to the scaffolds

- `settings.yml` in both projects: the data catalog (`study.*`, pointing at
  the shared CSVs, locked) and a folder publish destination at `local-site/`.
  Folders stay in `settings.do`; `fw_project` reads both files.
- A `$shared_csv` global in both projects' `settings.do`.
- `local-site/` in both projects' `.gitignore`.

## Side effects outside these folders

`01_setup.do` runs `fw_set fw_path` to point at `../bin/fw`. That setting
goes in `~/.config/framework/stata.conf` and applies to every project. Undo it
with `fw_set fw_path clear`.

## Starting over

Delete `inputs/` data files, `outputs/` files, `scratch/`, `local-site/`, and
`.framework/stata-integrity.tsv`, then run `do master.do` again.
