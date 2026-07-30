# CLAUDE.md

Guidance for Claude Code when working in this repository. Read this instead of re-exploring.

Project: _one or two lines - what this models or produces, for whom, and over what scope. Say what
it is not, if that is easy to get wrong (e.g. "research code, not a package")._

General coding conventions live in your personal `~/.claude/CLAUDE.md` (see `setup/global-CLAUDE.md`
in the template), not here. This file is only for facts about this project.

## Environment & Execution

Virtual environment: conda env `REPLACE_WITH_ENV_NAME`. Captured in `environment.yml`.
Never `pip install` into it without asking.

To run the main script:
```bash
bash run_python.sh main.py
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

- **`main.py`** — _describe what it does, and roughly how long it takes_
- _Mark library modules explicitly as having no `__main__` block, so a run that does nothing is not
  mistaken for a run that failed._

## Repository layout

| Path | Contents |
|---|---|
| `main.py` | _..._ |
| `environment.yml` | conda environment definition |

_List inputs, outputs, and any folder holding raw source data or credentials. Note anything large,
generated, or not usefully diffable._

## How to verify a change

_State the actual check, not "run the tests" - if there are no tests, say so and name what replaces
them (an output sheet, a reconciliation total, a known-good figure to compare against)._

Example shape: run `bash run_python.sh main.py`, then read _<output>_ and confirm _<check>_. Add a
new check when you add behaviour worth asserting.

## Conventions

_Units, domain vocabulary, and any rule a newcomer would otherwise have to infer from the code._

## Notes

_Add any project-specific instructions here._
