# CLAUDE.md

Project-specific instructions. General coding conventions live in your personal
`~/.claude/CLAUDE.md` (see `setup/global-CLAUDE.md` in the template), not here.

## Environment

Virtual environment: conda env `REPLACE_WITH_ENV_NAME`

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

## Entry Points

- **`main.py`** — _describe what it does_

## Notes

_Add any project-specific instructions here._
