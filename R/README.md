# R hand-testing projects

Five projects made with `fw new` (fw 0.4.6, framework 2.0.1), filled with notebooks
that walk through the framework R package on the shared study data. Every
project has a `study` connection to `../../shared/study.sqlite` (300 fictional
participants, their visits, labs, and a survey) with `read_only: true`, so
Framework opens it read-only. The write demos use project-local databases.
The projects sit inside this repository, so they have no `.git` of their own
and the git helpers report on the enclosing repo.

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
| `01-setup-and-settings` | `scaffold()`, `project_path()`, `status()`, `project_info()`, `settings()`, `settings_read()`/`settings_write()`, `make_*()` (with `title =`), stubs and templates, global settings, `adopt()`, `bootstrap()`, specs, `setup()`, and the retired `gui()` |
| `02-data-catalog` | `data_read()` (with whitespace trimming), `data_add()`, `data_list()`, `data_info()` (with `columns = TRUE`), `data_verify()`, locked-file hash checks, `data_save()` and its warning when it replaces locked data; runs `scripts/build-analysis-data.R` |
| `03-databases` | `connections_list()`, `db_list()`, `db_query()`, `db_with()`, `db_connect()`, the read-only `study` connection refusing writes, `read_only` per call, `db_execute()`, `db_execute_file()` (runs `scripts/sql/analysis-schema.sql`), `db_copy_from()`, `db_transaction()` with a rollback |
| `04-caching` | `cache_remember()` (with `depends_on`), `cache()`, `cache_get()`, `cache_list()`, `cache_forget()`, `cache_flush()`, expiry in minutes and seconds |
| `05-outputs` | `save_table()`, `show_table()`, `save_figure()` (several formats, subfolders), `save_model()`, `load_model()`, `save_notebook()`, `save_report()`, `result_list()`, `capture_output()`, `scratch_capture()`, `scratch_clean()` |
| `06-publishing` | `publish()`, `publish_notebook()`, `publish_data()`, `publish_dir()`, and `publish_list()` to the `local-site/` folder destination, plus `local-deck/` with `layout: site-root`; Cloud functions shown with their errors or not run |
| `07-packages-git-ai-security` | `package_add()`, `packages_*()`, renv, `git_*()`, hooks (install refuses inside the test repo), `git_security_audit()` including the secrets and identifier checks on a temporary copy, `ai_*()`, `env_summary()`, `env_clear()` |

After 06, open `local-site/index.html` and `local-deck/index.html` in a browser. Things worth trying by
hand: `view(data_read("inputs.final.bp_long"))` and `project_add_directory()`.
The local GUI is retired; `gui()` only points to Framework Cloud.

The notebooks generate `framework.db`, `analysis.sqlite`, `local-site/`, and
`local-deck/` (gitignored) plus files in `inputs/`, `outputs/`, and `settings/data.yml`
(not gitignored). Notebook 07 also adds broom to `settings/packages.yml` and
refreshes `AGENTS.md`. Delete the generated files and set `settings/data.yml`
back to `data: []` to start over.

## r-project-sensitive: private and public data

`notebooks/01-private-and-public-data.qmd` puts identifiable data in
`inputs/private/`, saves aggregates to `public/`, checks what git ignores,
shows the warnings on public saves after private reads, shows that there's no
encryption, runs the security audit, and shows the publish guards: private
paths, and confirmation for every object and notebook in a sensitive project.
It publishes the de-identified summary to its own gitignored `local-site/`.
The data security hooks are on in `settings/git.yml`, but they can't be
installed while the project sits inside this repository. Rendered output goes to
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
