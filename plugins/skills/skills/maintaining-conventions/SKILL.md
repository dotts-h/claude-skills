---
name: maintaining-conventions
description: Maintains CONVENTIONS.md — the project's coding standards, workflow, quality gates, and environment facts (build commands, toolchain paths, coverage floors). Use when establishing or changing a team convention, onboarding a repo, or when another skill needs the canonical project rules.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Maintaining conventions (the constitution)

`docs/CONVENTIONS.md` is the single living rulebook other skills read before they
act. `CLAUDE.md` stays a short authoritative pointer to it.

## When to use
- A new rule is agreed, or an existing rule changes.
- Onboarding a repo with no `CONVENTIONS.md` → bootstrap one from existing signals.
- A methodology skill (TDD, SDET, quality) needs the canonical gates/commands.

## Workflow
1. **Harvest, don't invent.** Pull existing signals first:
   ```bash
   scripts/harvest.sh
   ```
   It surfaces build/test commands (Makefile, package.json), lint config
   (`.golangci.yml`, `.eslintrc`), CI gates (`.github/workflows/`), and any
   `CONTRIBUTING.md` rules — the raw material for the doc.
2. Write/update `docs/CONVENTIONS.md` using the section set in
   [references/convention-categories.md](references/convention-categories.md).
3. **Every enforceable rule links to its ADR** (the decision that justifies it).
   If a rule has no ADR, either it's obvious (leave it) or it needs one — flag it.
4. Keep `CLAUDE.md` in sync: it should be a thin file that points here, not a copy.
5. Verify the doc is self-consistent: `scripts/check.sh` warns if commands named
   in CONVENTIONS don't exist in the Makefile/package scripts.

## Rules
- **Rules, not rationale.** CONVENTIONS states what to do *now*; the *why* lives
  in the ADR it links to.
- **Machine facts are exact.** Toolchain paths, command lines, and numeric gates
  (coverage floor) are copy-pasteable, never paraphrased.
- One source of truth. If a fact lives in the Makefile, link/quote it — don't fork it.

## Reference
- Section set + what belongs where: [references/convention-categories.md](references/convention-categories.md)

## This repo (seed values)
- **Workflow:** branch from `main`; failing test first; `make lint && make test`
  before push; `--no-ff` merge; push `origin/main`; delete the local branch.
- **Architecture rules:** no SDK imports outside `internal/copilot/SDKClient`;
  `telemetry`/`ctxforge`/`config` stay dependency-free; `Forge.Compile` + pricing
  are deterministic; config/forge writes are atomic (temp-file + rename + validate).
- **Gates:** `make lint` (gofmt + vet + golangci-lint v2), `make test`
  (`go test ./... -race -cover`), coverage floor **65%**, fuzz smoke on pricing.
- **Env fact:** Go toolchain not on default PATH —
  `export PATH=$PATH:/home/ori913/go-install/go/bin`.
Seed these from `CONTRIBUTING.md` + `Makefile` and link each to a backfilled ADR.
