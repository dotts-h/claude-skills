# CONVENTIONS.md section set

Use these headings. Keep each rule one line; link the ADR that justifies it.

## Contents
- Workflow
- Architecture rules
- Testing
- Quality gates
- Persistence & data
- Environment facts
- Naming & style

## Workflow
How work flows from idea to merged: branching, test-first expectation, review,
merge strategy, push/cleanup. Make the exact git steps copy-pasteable.

## Architecture rules
The invariants that must not be violated: dependency direction (which package may
import which), purity rules (which packages stay dependency-free), determinism
requirements, seam boundaries. Each links an ADR.

## Testing
What "tested" means here: the layers (unit / contract / browser), table-driven
expectation, what must have a guard test (e.g. every fixed bug). Point to the
TDD/SDET/authoring skills for *how*.

## Quality gates
The exact commands and numeric thresholds CI enforces (lint command, test command,
coverage floor, fuzz/bench). Methodology skills read this section verbatim.

## Persistence & data
Rules for writing state: atomicity (temp-file + rename), validation-before-save,
schema-stability expectations.

## Environment facts
Machine truths a fresh agent needs: toolchain paths not on default PATH, required
env vars, how to launch the app/demo, ports. Exact strings.

## Naming & style
Conventions a linter can't fully capture: file/branch naming, commit message
shape, terminology to keep consistent.

## Rule format
`- <rule, imperative> — see [ADR-NNNN](adr/NNNN-...md)`
A rule with no ADR is either self-evidently necessary (fine) or an undocumented
decision (flag it for `recording-decisions`).
