# Claude Code Project Template

Copy this template into any new project to give Claude Code scoped permissions without prompting.

## What's included

Claude Code reads instructions from two places, and this template keeps them apart:

| Where | Scope | File |
| --- | --- | --- |
| `~/.claude/CLAUDE.md` | You, in every project | `setup/global-CLAUDE.md` |
| `<project>/.claude/CLAUDE.md` | This project, everyone | `.claude/CLAUDE.md` |

**Copied into each new project:**

- `.claude/settings.json` — pre-authorizes file read/edit/write restricted to the project directory, plus a hook that authorizes script execution via `run_python.sh`
- `.claude/CLAUDE.md` — project facts only: virtual environment, entry points, notes
- `run_python.sh` — conda wrapper that activates the environment and runs a Python script
- `environment.yml` — conda environment definition, so the env itself is reproducible
- `.gitignore` — excludes personal Claude settings, Python cache files, and OneDrive/Windows artifacts
- `.gitattributes` — keeps `*.sh` on LF endings, so `run_python.sh` still works after a clone on Windows
- `.vscode/extensions.json` — recommends the Claude Code VSCode extension on folder open

**Set up once per machine, never copied into a project:**

- `setup/global-CLAUDE.md` — recommended coding conventions for your own `~/.claude/CLAUDE.md`

## Setup (once per machine)

Copy `setup/global-CLAUDE.md` to `~/.claude/CLAUDE.md` (Windows: `C:\Users\<you>\.claude\CLAUDE.md`),
then edit it to taste — it is a starting point, not a policy. If you already have a
`~/.claude/CLAUDE.md`, merge the sections in instead of overwriting.

Keeping these conventions in your personal file means they apply to every project you open, and you
maintain them in one place rather than in a copy per repo.

## Setup (per new project)

### 1. Copy the template files into the project root

Everything except the `setup/` folder.

### 2. Fill in `run_python.sh` and `environment.yml`

Replace `REPLACE_WITH_ENV_NAME` in both files with your conda environment name, then create the environment:

```powershell
conda env create -f environment.yml
```

### 3. Fill in `.claude/CLAUDE.md`

Replace `REPLACE_WITH_ENV_NAME` with your conda environment name (same as above), then fill in the entry point script name and any project-specific instructions for Claude.

Keep this file to things that are true of *this project* and would be true for any teammate working
on it. General coding conventions belong in your personal `~/.claude/CLAUDE.md` — see the
once-per-machine setup above.

> **Tip:** once the project has actual code in it, run `/init` in Claude Code to have it scan the codebase and fill in (or expand on) the entry points and notes sections automatically, instead of writing them by hand.

## Opening the project in VSCode so Claude Code loads the right settings

Claude Code uses VSCode's **workspace root** as its working directory. `.claude/settings.json` only loads when that root is the project folder itself — not a parent folder.

### Make sure VSCode is opened at the project root

1. In VSCode, open **File → Open Folder…** (`Ctrl+K Ctrl+O`) and select the project folder (e.g. `T_E/github/my-project`), not a parent like `T_E` or your home directory.
2. Confirm in the Explorer panel that the project folder is the top-level item shown — not nested inside another folder.
3. In the Claude Code panel, the working directory shown in the status bar or header should match the project folder path.

If VSCode is already open at a parent folder, use **File → Add Folder to Workspace…** then **File → Close Folder** on the parent — or simply close and reopen with the correct folder.

> **Why this matters:** a session opened at `C:\Users\Valentin Simon` won't load `T_E\github\my-project\.claude\settings.json`, so its permissions and execution hook never apply and every `bash run_python.sh` call will prompt.

## Your first Claude Code session

1. Open the project folder in VSCode (see above) and open the Claude Code panel.
2. Run `/init` to have Claude scan the codebase and draft the `.claude/CLAUDE.md` entry points/notes for you.
3. Ask Claude a read-only question first (e.g. "summarize what this project does") to confirm it can read files without prompting.
4. Try `bash run_python.sh main.py` (or whatever your entry point is) through Claude to confirm execution works without a prompt. If it prompts, the settings file isn't loading — check the workspace root above.

## Personal permission tweaks: `settings.local.json`

`.claude/settings.json` is shared and committed — it's the baseline every teammate gets. If you personally want to grant Claude extra permissions (e.g. a tool you use but your teammates don't) without changing the shared file, create `.claude/settings.local.json` with the same `{"permissions": {"allow": [...]}}` shape. It's already excluded via `.gitignore` and merges on top of `settings.json`.

## Notes

- `.claude/settings.json` is project-scoped: permissions only apply when Claude is opened in this directory.
- Access to your `~/.claude` folder (cross-session memory files) comes from your global settings, not
  from this file — see step 3. A file-tool allow rule in a project settings file only takes effect
  inside the workspace root, so pointing one at a path outside the project has no effect at all.
- Script execution is authorized by the `PreToolUse` hook in `.claude/settings.json`, which allows commands starting with `bash run_python.sh ` and nothing else. Claude cannot call `python` directly — all execution goes through `run_python.sh`, which activates the conda environment first. This avoids broad `Bash(python *)` permissions that would allow running any Python command anywhere.
- The hook, not a `permissions.allow` rule, is what grants execution. Claude Code does not honour `Bash(...)` allow rules for `bash <script>`, because it cannot see what runs inside the subshell — so `Bash(bash run_python.sh *)` has no effect and is deliberately absent. If execution starts prompting, fix the hook rather than adding allow rules.
- The hook only matches commands that *start* with `bash run_python.sh `, so a `cd ... &&` prefix or a chained `&&` will prompt. One script per command.
- The hook uses `grep`, so it needs Git Bash (already required by `bash run_python.sh`). It does not need `jq`.
- `desktop.ini` files you may see in this folder are Windows/OneDrive folder-customization artifacts, not part of the template — don't copy them into new projects.