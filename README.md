# Framework test projects

Projects scaffolded with `fw new` from offline defaults, one of each project type per language, with notebooks that walk through the Framework API. Use them to try Framework by hand.

| Folder | Projects | Guide |
|---|---|---|
| `R/` | r-project, r-project-sensitive, r-course, r-presentation, r-bare | [R/README.md](R/README.md) |
| `python/` | py-project (Quarto), py-project-jupyter, py-project-sensitive, py-course, py-presentation, py-bare | [python/README.md](python/README.md) |
| `stata/` | stata-project, stata-project-sensitive, stata-bare | [stata/README.md](stata/README.md) |

Start with the `*-project` folder in each language. Its numbered notebooks or do-files cover the whole API.

## Shared data

`shared/study.sqlite` is a fictional cohort study: 4 sites, 300 participants, about 1,000 visits, 3,000 lab results, and a survey, with some values missing. Every project reaches it through a `study` connection at `../../shared/study.sqlite`. Stata reads the CSV copies in `shared/csv/`.

Treat it as read-only. Write demos use each project's own `framework.db` or a local database that is gitignored. To rebuild it (the output is deterministic):

```sh
python3 shared/scripts/build_database.py
```

## The fw CLI

```sh
./bin/build-fw.sh      # builds ../framework-cli into bin/fw
./bin/fw doctor
```

Your shell's `fw` function (cd to a project) shadows the binary, so call `./bin/fw`.

The projects came from `fw new NAME --lang LANG --type TYPE --offline --no-cloud --headless`. `fw new` made a git repository inside each one; those were deleted so this repository can track the files.
