# CLAUDE.md

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

## Development Best Practices

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Secrets & Sensitive Data

**Never output, log, or commit secrets. Warn if the user might be about to.**

- Never print, echo, or include API keys, tokens, passwords, connection strings, or credentials in responses, commit messages, logs, or files you create — including partially (e.g. truncated keys), unless the user explicitly asks you to display a specific secret they already own and control.
- Before committing, pushing, or writing files to shared locations, check for secrets in the diff (`.env` files, hardcoded keys, credential JSON) and flag them instead of proceeding silently.
- If the user pastes something that looks like a live credential (API key, token, private key, password) into chat, tell them it looks sensitive and suggest they rotate/revoke it if it wasn't meant to be shared — don't just use it silently.
- Prefer reading secrets from environment variables or existing secret files over asking the user to paste them into the conversation.