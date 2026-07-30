# Recommended personal CLAUDE.md

Copy this file to `~/.claude/CLAUDE.md` (Windows: `C:\Users\<you>\.claude\CLAUDE.md`) so it applies
to every project you open with Claude Code. Do **not** copy it into a project — project repos carry
only `.claude/CLAUDE.md`, which is for project-specific facts (environment, entry points, notes).

If you already have a `~/.claude/CLAUDE.md`, merge these sections into it rather than overwriting.
Adjust anything you disagree with: this is a starting point, not a policy.

---

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

## 6. Code Style

- Comment all code that isn't straightforward.
- Do not write non-ASCII characters (e.g. arrows `→`, en/em dashes `–` `—`, `×`) in code. This
  matters on Windows: `conda run` re-encodes stdout as cp1252 and crashes with `UnicodeEncodeError`
  on such characters in anything printed or logged. `run_python.sh` uses `conda run`.
