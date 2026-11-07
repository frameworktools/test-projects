# Python test projects

Hand-testing projects for framework-py 0.1.0.dev9. Each was created with
`fw new --lang python` and then filled with notebooks that use the shared study database
(`../shared/study.sqlite`, a fictional blood pressure cohort of 300 participants).

Every project has a `study` connection to that database (`../../shared/study.sqlite` in
its settings, resolved from the project root) with `read_only: true`, so writes to it
fail.

## Setup

Run these in any project folder:

```sh
uv sync                                 # install framework-py and the project's packages
export PATH=/Applications/quarto/bin:$PATH
```

## The projects, in order

1. **py-project** (Quarto workflow). The full tour of the API, in
   `notebooks/01-…` to `07-…`. Run them in order: 02 builds the data catalog the
   others use, and 06 publishes what 05 saves.

   | Notebook | Covers |
   |----------|--------|
   | 01 Setup and Settings | `scaffold`, `status`, settings, `.env`, creating and adopting projects, `bootstrap` |
   | 02 Data Catalog | `data_add`, `data_list`, `data_info`, `data_read`, `data_save`, `data_verify`, integrity errors |
   | 03 Databases | `study` (read-only), `framework`, and `local` connections, queries, writes, transactions |
   | 04 Caching | `cache_remember`, `cache`, `cache_get`, `cache_list`, `cache_forget`, `cache_flush` |
   | 05 Outputs | `save_table`, `save_figure`, `save_model`, `save_notebook`, `save_report`, `result_list`, scratch |
   | 06 Publishing | `publish`, `publish_notebook`, `publish_data`, `publish_dir`, `publish_list` to the `local` folder destination; cloud and bucket calls |
   | 07 Project Tools | packages, git hooks, security audit, AI skills, stubs and templates, global config, Quarto config |

   ```sh
   uv run quarto preview notebooks/01-setup-and-settings.qmd   # one at a time, live
   uv run quarto render notebooks/02-data-catalog.qmd          # or render to outputs/notebooks/
   ```

   Open `published/index.html` after notebook 06 to browse the published bundles.

2. **py-project-jupyter** (Jupyter workflow). The same tour, condensed into four
   `.ipynb` notebooks, to compare how Jupyter feels.

   ```sh
   uv run jupyter lab
   ```

3. **py-project-sensitive**. One notebook, `01-private-and-public.ipynb`: private and
   public folders, what git ignores, small-cell suppression, `public=True` outputs, and
   the publishing guard on private paths. `uv run jupyter lab`.

4. **py-course**. A module (`modules/`), slides (`slides/`), an assignment, and a
   syllabus. Render the module first: it saves the data the slides and assignment read.

   ```sh
   uv run quarto render modules/01-blood-pressure-basics.qmd
   uv run quarto render            # everything, into rendered/
   uv run quarto preview slides/week-1-blood-pressure.qmd
   ```

5. **py-presentation**. A reveal.js deck built from the study database.

   ```sh
   uv run quarto preview presentation.qmd
   ```

6. **py-bare**. A bare project: only `settings.yml` and one script.

   ```sh
   uv run python bp-check.py
   ```

## Things to know

- Notebooks run from `notebooks/`, but Framework resolves project paths (data, database
  files, publishing folders) from the project root.
- These projects have no `.git` of their own; they sit inside the outer
  `framework-test-projects` repository. `status()` says so, and `git_hooks_install()`
  refuses with an error, which the notebooks show on purpose.
- Calls that change your global settings, the project registry, or `pyproject.toml` are
  behind `RUN_* = False` flags. Cloud calls run only when `cloud_status()` says you are
  logged in.
- If `fw new` or `uv lock` says only an older framework-py is available, uv's package
  index cache is stale: run it again with `UV_NO_CACHE=1`.
- Running the notebooks writes data copies to `inputs/`, results to `outputs/`, and
  catalog entries to `settings/data.yml` (`settings.yml` in py-course). To start over, empty those, delete
  `framework.db`, `local.sqlite`, and `published/`, and set `settings/data.yml` back to
  `data: {}`. `scaffold()` creates a fresh `framework.db`.
