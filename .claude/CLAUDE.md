# CLAUDE.md

Guidance for Claude Code when working in this repository. Read this instead of re-exploring.

Project: computes NS (Dutch Railways) train punctuality and cancellation stats per year and service
type from the rijdendetreinen.nl open data, for T&E's rail research. Notebooks only - not a package,
no tests.

General coding conventions live in your personal `~/.claude/CLAUDE.md` (see `setup/global-CLAUDE.md`
in the template), not here. This file is only for facts about this project.

## Environment & Execution

Virtual environment: conda env `panda_env`. Captured in `environment.yml` (pandas, numpy, ipykernel,
openpyxl). Never `pip install` into it without asking.

There is no `main.py` - the entry points are Jupyter notebooks (see below), normally run interactively
in VS Code with the `panda_env` kernel selected. `run_python.sh` is still the way to execute any
standalone `.py` script (ad-hoc checks, or a notebook's code extracted for a non-interactive run):
```bash
bash run_python.sh some_script.py
```

`run_python.sh` activates the conda environment before running. Always use it instead of calling
`python` directly. The command must start with exactly `bash run_python.sh ` to run without
prompting:
- Pass a plain relative script name. No `cd` prefix, no `&&` chaining, one script per Bash call.
- Do not activate the environment yourself. Each Bash call gets a fresh shell, so `conda activate`
  cannot persist between calls - `run_python.sh` activates per invocation, which is why it exists.

Permission for this comes from a `PreToolUse` / `Bash` hook in `.claude/settings.json` that matches
`bash run_python.sh ` and returns `permissionDecision: allow`. It is the only mechanism - a
`permissions.allow` rule cannot grant `bash <script>`. If a run_python.sh call prompts, fix the hook.

### Ad-hoc Python (inspecting a file, checking a number)

Write a temp script into the project root, run it with the wrapper, then delete it:

```python
# Write to: <project root>/_tmp_<what>.py
```

Do NOT write it outside the project root (not pre-authorized) and do NOT leave `_tmp_*.py` behind.
`.gitignore` excludes them, so a stray one will not be committed - it will just sit there.

## Entry points

- **`data_NS_exploratory_analysis.ipynb`** — exploratory notebook. Works out the dataset's quirks
  (what `Service:Company`/`Service:Type` values mean, how to identify a service's terminus, how
  cancellation flags interact) on a single year. Not meant to be re-run end to end; read it to
  understand *why* the summary notebook is built the way it is.
- **`NS_punctuality_summary.ipynb`** — the real output. Streams every `services-YYYY.csv` found in
  the raw data folder (chunked, since each file is ~3 GB) and writes a per-year, per-service-type
  punctuality summary to `output/NS_punctuality_summary.xlsx`. Takes roughly 5-10 minutes for all
  years on a warm file cache; longer the first time a file is read off the shared drive.

## Repository layout

| Path | Contents |
|---|---|
| `data_NS_exploratory_analysis.ipynb` | dataset exploration (see above) |
| `NS_punctuality_summary.ipynb` | builds the Excel summary (see above) |
| `environment.yml` | conda environment definition (`panda_env`) |
| `output/` | generated Excel output - gitignored, not committed |

Raw input data lives outside this repo, on the shared drive:
`.../T&A/Shared knowledge tools and data/data_sources/Rail_databases/punctuality_big_data/NL_rijdendetreinen/services-YYYY.csv`
(one huge CSV per year - it's a Google Drive sync folder, so which years are present can change
between runs; 2021 appeared partway through this project after initially being absent). The notebook
discovers whichever year files exist rather than hardcoding a list, so a newly-added year is picked
up automatically.

## How to verify a change

Run `NS_punctuality_summary.ipynb` end to end (or the equivalent `.py` via `run_python.sh`) and check
`output/NS_punctuality_summary.xlsx`:
- one row per (year, service type) actually present in the data - no hardcoded list to compare against
- `Total trains scheduled` >= `Total fully + partially` for every row
- `Total fully + partially` == `Total trains fully cancelled` + `Total trains partially cancelled`
- `Total trains arriving at terminus` <= `Total trains scheduled` for every row (NOT `scheduled -
  cancelled` - see Conventions, that equality does not hold)
- the four "on time" columns are non-increasing as the threshold shrinks (3 min <= 5 min <= 10 min <= 15 min),
  and none of them exceeds `Total trains arriving at terminus`, within a row

## Conventions

- A "service" = one `Service:RDT-ID`. A single ID can span multiple physical trains end-to-end but is
  always uniquely dated and has a single cancellation status - see the exploratory notebook.
- A service flagged both fully and partially cancelled is counted as **fully** cancelled only, never
  both - avoids double-counting in `Total fully + partially`.
- `Total trains arriving at terminus` is **not** `scheduled - (fully + partially cancelled)`. A
  partially cancelled service can still reach its terminus - `Service:Partly cancelled` just means
  *some* stop was skipped, not necessarily the last one. Verified against 2023 data: 50.7% of
  partly-(not fully-)cancelled services had a non-cancelled arrival at their terminus. So "arrived"
  is read off the **stop-level** `Stop:Arrival cancelled` flag on the terminus row itself, not the
  service-level flags. Don't reintroduce the subtraction shortcut without re-checking this.
- "On time at terminus" = arrival delay at the service's **last stop** is <= the threshold (minutes),
  counted only among services whose terminus arrival was not cancelled (per the stop-level flag
  above). A missing arrival delay at the terminus counts as not on time.
- 2019-01-02 through 2019-09-08 has a source data gap: 36% of `Snelbus i.p.v. trein` /
  `Stopbus i.p.v. trein` services in that window have only a single row (departure only, no arrival
  stop recorded at all), so arrival can't be determined and they count as not-arrived. This
  understates those two service types' 2019 arrival/on-time figures; the gap doesn't exist in any
  other year or service type.
- `Service:Type` labels come straight from the source and are not normalized - e.g. `Metro i.p.v.
  trein` (2019-2022) and `Metro ipv trein` (2023+) are the same concept written differently across
  years; treat them as distinct rows unless you deliberately decide to merge them.
- Only `Service:Company == "NS"` is kept (excludes NS Int. and other operators). In the 2019-2020
  files this NS-company filter still includes some `Eurostar`/`Thalys`/`ICE International`/`Int.
  Trein` rows - that's how the source data was tagged for those years, not a filtering bug.

## Notes

- `panda_env` was picked because it already had pandas/numpy/ipykernel; `openpyxl` was added via pip
  for Excel export. If you rebuild the env from `environment.yml`, `pip install openpyxl` runs
  automatically as part of `conda env create`.
