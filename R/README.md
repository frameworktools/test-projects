# R hand-testing projects

Five projects made with `fw new` (framework 1.9.0.9005), filled with notebooks
that walk through the framework R package on the shared study data. Every
project has a `study` connection to `../../shared/study.sqlite` (300 fictional
participants, their visits, labs, and a survey) with `read_only: true`, so
Framework opens it read-only. The write demos use project-local databases.

Open each project folder as its own working directory (in RStudio or Positron,
open the `.code-workspace` file or set the working directory to the project).
Run notebooks chunk by chunk, or render them from the project folder:

```sh
cd r-project
quarto render notebooks/01-setup-and-settings.qmd
```

Rendered notebooks land in the folder set in `_quarto.yml` (`outputs/` here).

## r-project: the full tour

Run these in order; later ones read what earlier ones saved.

| Notebook | Covers |
|----------|--------|
| `01-setup-and-settings` | `scaffold()`, `status()`, `project_info()`, `settings()`, `settings_read()`/`settings_write()`, `make_*()`, stubs and templates, global settings, `adopt()`, `bootstrap()`, specs |
| `02-data-catalog` | `data_read()`, `data_add()`, `data_list()`, `data_info()`, `data_verify()`, locked-file hash checks, `data_save()`; runs `scripts/build-analysis-data.R` |
| `03-databases` | `connections_list()`, `db_list()`, `db_query()`, `db_with()`, `db_connect()`, the read-only `study` connection refusing writes, `db_execute()`, `db_transaction()` with a rollback |
| `04-caching` | `cache_remember()`, `cache()`, `cache_get()`, `cache_list()`, `cache_forget()`, `cache_flush()`, expiry in minutes and seconds |
| `05-outputs` | `save_table()`, `save_figure()`, `save_model()`, `save_notebook()`, `save_report()`, `result_list()`, `capture_output()`, `scratch_capture()`, `scratch_clean()` |
| `06-publishing` | `publish()`, `publish_notebook()`, `publish_data()`, `publish_dir()`, and `publish_list()` to the `local-site/` folder destination; Cloud functions shown with their errors or not run |
| `07-packages-git-ai-security` | `package_add()`, `packages_*()`, renv, `git_*()`, hooks (install refuses inside the test repo), `git_security_audit()`, `ai_*()`, `env_summary()`, `env_clear()` |

After 06, open `local-site/index.html` in a browser. Things worth trying by
hand: `gui()`, `view(data_read("inputs.final.bp_long"))`, and
`project_add_directory()`.

The notebooks generate `framework.db`, `analysis.sqlite`, and `local-site/`
(gitignored) plus files in `inputs/`, `outputs/`, and `settings/data.yml`
(not gitignored). Notebook 07 also adds broom to `settings/packages.yml` and
refreshes `AGENTS.md`. Delete the generated files and set `settings/data.yml`
back to `data: []` to start over.

## r-project-sensitive: private and public data

`notebooks/01-private-and-public-data.qmd` puts identifiable data in
`inputs/private/`, saves aggregates to `public/`, checks what git ignores,
shows that there's no encryption, runs the security audit, and shows the
publish guard for private paths. Rendered output goes to
`outputs/private/notebooks/` (gitignored).

## r-course: teaching materials

Render in this order, since the assignment reads data the module saves:

```sh
cd r-course
quarto render course_docs/syllabus.qmd
quarto render slides/01-meet-the-study.qmd
quarto render modules/01-blood-pressure-by-arm.qmd
quarto render assignments/assignment-01-weight-change.qmd
```

Output goes to `rendered/`, which is gitignored.

## r-presentation: one talk

`presentation.qmd` is a short reveal.js deck on the study. Render it with
`quarto render presentation.qmd`; the slides land next to it as
`presentation.html` (not gitignored).

## r-bare: the minimum

A bare project is only `settings.yml`. Run `Rscript explore-study.R` to see
that `scaffold()`, connections, `save_table()`, the data catalog, and caching
still work without any configured directories.
