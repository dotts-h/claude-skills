# Claude Code Skills: Comprehensive Research Report

> **Scope:** Built-in commands & bundled skills, the orchestra-skills plugin (this repo),
> testing-skill gap analysis, UI/UX prototyping, community ecosystem, architecture best
> practices, and a concrete improvement roadmap.
>
> **Branch:** `claude/repo-documentation-page-ux1pb8`  
> **Last updated:** June 2026

---

## Table of Contents

1. [What Are Claude Code Skills?](#1-what-are-claude-code-skills)
2. [All Built-in Claude Code Commands](#2-all-built-in-claude-code-commands)
3. [Bundled Skills & Workflows](#3-bundled-skills--workflows)
4. [Pre-built Agent Skills](#4-pre-built-agent-skills)
5. [This Repository: Orchestra-Skills](#5-this-repository-orchestra-skills)
6. [Testing Skills: Current State & Gaps](#6-testing-skills-current-state--gaps)
7. [UI/UX Prototyping Skills](#7-uiux-prototyping-skills)
8. [Community Ecosystem](#8-community-ecosystem)
9. [Skill Architecture Best Practices](#9-skill-architecture-best-practices)
10. [Recommended New Skills for This Repo](#10-recommended-new-skills-for-this-repo)
11. [Roadmap](#11-roadmap)

---

## 1. What Are Claude Code Skills?

A **Claude Code skill** is a directory containing a `SKILL.md` file — a markdown document
with YAML frontmatter (metadata) and a markdown body (instructions). Claude Code discovers
skills at startup, loads their metadata into the system prompt, and then reads the full body
only when that skill becomes relevant to the current task.

### 1.1 The Three-Level Architecture

Skills use **progressive disclosure** to keep context costs low:

| Level | Content | When loaded | Token cost |
|-------|---------|-------------|------------|
| 1 — Metadata | `name` + `description` from YAML frontmatter | Always, at startup | ~100 tokens per skill |
| 2 — Instructions | Full `SKILL.md` body | When skill is triggered | Under 5 000 tokens |
| 3 — Resources | Bundled reference files, scripts, templates | Only when referenced | Effectively unlimited |

Scripts in the `scripts/` subdirectory are **executed, not loaded** — only their stdout
enters the context window, so a 500-line validation script costs zero tokens unless it
produces output.

### 1.2 Skill File Format

Every skill requires a `SKILL.md` with two mandatory frontmatter fields:

```yaml
---
name: your-skill-name          # kebab-case, max 64 chars, no "anthropic" or "claude"
description: >                 # max 1 024 chars; what it does AND when to use it
  Analyzes Excel spreadsheets, creates pivot tables, generates charts.
  Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob   # optional
---

# Your Skill Title

## Instructions
...
```

### 1.3 Two Fundamental Skill Types

| Type | Purpose | Example |
|------|---------|---------|
| **Capability Uplift** | Grants Claude new abilities it lacks | PDF extraction, browser automation, chaos experiments |
| **Encoded Preference** | Captures *how your team* does something Claude already knows | ADR format, commit message style, TDD gate commands |

### 1.4 Where Skills Live

```
~/.claude/skills/         ← personal (all your projects)
.claude/skills/           ← project-scoped (checked in)
~/.claude/plugins/        ← installed plugins (bundled skill sets)
```

Skills installed via plugins (like orchestra-skills) drop into
`~/.claude/plugins/<plugin-name>/skills/` and are available in every session.

### 1.5 Invocation Modes

| Mode | How | Trigger |
|------|-----|---------|
| Manual | Type `/skill-name` | Explicit |
| Automatic | Claude recognises the task matches a description | Based on description field |
| Hybrid | Both work | Most skills |

---

## 2. All Built-in Claude Code Commands

Built-in commands are coded into the CLI binary. They are distinct from skills (which are
prompt files) but appear in the same `/` menu. The table below is the complete reference as
of Claude Code v2.1.161+ (June 2026). Commands marked **[Skill]** or **[Workflow]** are
covered in §3.

### 2.1 Session & Navigation Commands

| Command | Purpose |
|---------|---------|
| `/clear [name]` | Start a new conversation; previous stays in `/resume`. Aliases: `/reset`, `/new` |
| `/resume [session]` | Reopen a past conversation by ID, name, or picker. Alias: `/continue` |
| `/branch [name]` | Fork current conversation to try a different direction |
| `/fork <directive>` | Spawn background subagent that inherits full context, returns result to you |
| `/background [prompt]` | Detach session to run as a background agent. Alias: `/bg` |
| `/rewind` | Roll code and conversation back to a checkpoint. Aliases: `/checkpoint`, `/undo` |
| `/btw <question>` | Quick side question that doesn't add to conversation history |
| `/teleport` | Pull a Claude Code on the web session into this terminal. Alias: `/tp` |
| `/add-dir <path>` | Add a working directory for file access during this session |
| `/stop` | Stop an attached background session (keeps transcript + worktree) |
| `/exit` | Exit CLI or detach from background session. Alias: `/quit` |

### 2.2 Context Management Commands

| Command | Purpose |
|---------|---------|
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context usage as colored grid with optimization suggestions |
| `/diff` | Interactive diff viewer — uncommitted changes and per-turn diffs |
| `/copy [N]` | Copy last (or Nth-to-last) response to clipboard, with block picker |
| `/export [filename]` | Export conversation as plain text |
| `/recap` | One-line summary of current session |

### 2.3 Model & Effort Commands

| Command | Purpose |
|---------|---------|
| `/model [model]` | Switch AI model, save as default |
| `/effort [level\|auto]` | Set reasoning effort: `low`, `medium`, `high`, `xhigh`, `max`, `ultracode` |
| `/fast [on\|off]` | Toggle fast mode (Opus with faster output) |
| `/plan [description]` | Enter plan mode directly |

### 2.4 Code & Review Commands

| Command | Purpose |
|---------|---------|
| `/code-review [level] [--fix] [--comment] [target]` | **[Skill]** Review diff for bugs and cleanups |
| `/simplify [target]` | **[Skill]** Cleanup-only review, applies fixes (v2.1.154+) |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze branch changes for security vulnerabilities |
| `/diff` | Interactive diff viewer |
| `/autofix-pr [prompt]` | Spawn cloud session to watch PR and push fixes on CI failure or review comments |
| `/ultrareview [PR]` | Alias for `/code-review ultra` — deep multi-agent cloud review |

### 2.5 Parallel Work Commands

| Command | Purpose |
|---------|---------|
| `/agents` | Manage agent configurations |
| `/batch <instruction>` | **[Skill]** Orchestrate large codebase changes in parallel worktrees |
| `/tasks` | View and manage background tasks. Alias: `/bashes` |
| `/background [prompt]` | Detach current session as background agent |
| `/goal [condition]` | Set a goal; Claude keeps working until the condition is met |

### 2.6 Run & Verify Commands

| Command | Purpose |
|---------|---------|
| `/run` | **[Skill]** Launch project app and observe changes |
| `/verify` | **[Skill]** Confirm code change works in running app |
| `/run-skill-generator` | **[Skill]** Teach `/run` and `/verify` how to launch your specific project |

### 2.7 Workflow & Research Commands

| Command | Purpose |
|---------|---------|
| `/deep-research <question>` | **[Workflow]** Fan-out searches, fetch sources, verify, synthesize |
| `/ultraplan <prompt>` | Draft plan in browser, execute remotely or send to terminal |
| `/workflows` | View, pause, resume workflow progress |
| `/loop [interval] [prompt]` | **[Skill]** Run prompt repeatedly on schedule. Alias: `/proactive` |
| `/schedule [description]` | Create/manage routines on Anthropic cloud infrastructure. Alias: `/routines` |

### 2.8 Configuration & Settings Commands

| Command | Purpose |
|---------|---------|
| `/config` | Open Settings UI. Alias: `/settings` |
| `/permissions` | Manage allow/ask/deny rules. Alias: `/allowed-tools` |
| `/memory` | Edit CLAUDE.md files, enable/disable auto-memory |
| `/mcp` | Manage MCP server connections |
| `/hooks` | View hook configurations |
| `/keybindings` | Open keyboard shortcuts file |
| `/init` | Initialize project with CLAUDE.md guide |
| `/skills` | List available skills; sort by tokens; toggle visibility |
| `/plugin [subcommand]` | Manage Claude Code plugins |
| `/reload-plugins [--force]` | Reload plugins without restarting |
| `/reload-skills` | Re-scan skills added/changed on disk (v2.1.152+) |
| `/sandbox` | Toggle sandbox mode |
| `/theme` | Change color theme |
| `/color [color]` | Set prompt bar color for current session |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/statusline` | Configure status line |
| `/terminal-setup` | Configure terminal keybindings |
| `/fewer-permission-prompts` | **[Skill]** Scan transcripts and add tool allowlist |

### 2.9 Information & Diagnostics Commands

| Command | Purpose |
|---------|---------|
| `/help` | Show help and available commands |
| `/status` | Version, model, account, connectivity |
| `/usage` | Session cost, plan limits, activity stats. Aliases: `/cost`, `/stats` |
| `/insights` | Report analyzing your sessions, patterns, friction points |
| `/doctor` | Diagnose installation and settings |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot issues |
| `/context [all]` | Visualize context window usage |
| `/heapdump` | Write JS heap snapshot for memory diagnostics |
| `/feedback [report]` | Submit bug report or share conversation. Aliases: `/bug`, `/share` |
| `/release-notes` | View changelog in interactive version picker |
| `/team-onboarding` | Generate team onboarding guide from usage history |
| `/powerup` | Discover features through interactive animated lessons |

### 2.10 Integration & Cloud Commands

| Command | Purpose |
|---------|---------|
| `/install-github-app` | Set up Claude GitHub Actions integration |
| `/install-slack-app` | Install Claude Slack app |
| `/web-setup` | Connect GitHub account to Claude Code on the web |
| `/remote-control` | Make session available for remote control from claude.ai. Alias: `/rc` |
| `/remote-env` | Choose default environment for cloud agents |
| `/desktop` | Continue session in Claude Code Desktop app. Alias: `/app` |
| `/setup-bedrock` | Configure Amazon Bedrock authentication |
| `/setup-vertex` | Configure Google Vertex AI authentication |
| `/chrome` | Configure Claude in Chrome settings |
| `/ide` | Manage IDE integrations |
| `/mobile` | Show QR code for Claude mobile app. Aliases: `/ios`, `/android` |
| `/autofix-pr [prompt]` | Cloud PR auto-fix watcher |
| `/schedule` | Cloud-infrastructure routines |

### 2.11 Session Identity Commands

| Command | Purpose |
|---------|---------|
| `/login` | Sign in to Anthropic account |
| `/logout` | Sign out |
| `/upgrade` | Open upgrade page |
| `/usage-credits` | Configure extra usage credits |
| `/passes` | Share free week of Claude Code (if eligible) |
| `/rename [name]` | Rename current session |
| `/radio` | Open Claude FM lo-fi radio |
| `/stickers` | Order Claude Code stickers |

**Total built-in commands: 60+** (availability varies by platform, plan, and version)

---

## 3. Bundled Skills & Workflows

Bundled skills ship with Claude Code and follow the same SKILL.md format as custom skills —
they are prompts handed to Claude, which Claude can also invoke automatically.

### 3.1 Bundled Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| **batch** | `/batch <instruction>` | Orchestrates large-scale parallel codebase changes. Researches the repo, decomposes into 5-30 independent units, spawns one background subagent per unit in an isolated git worktree |
| **claude-api** | `/claude-api [migrate\|managed-agents-onboard]` | Loads Claude API reference for 8 languages. Also auto-activates when code imports `anthropic` or `@anthropic-ai/sdk`. Includes model migration and managed-agents onboarding |
| **code-review** | `/code-review [level] [--fix] [--comment] [target]` | Reviews diff for correctness bugs + reuse/simplification/efficiency cleanups. Levels: low, medium, high, xhigh, max, ultra (cloud). `--fix` applies findings; `--comment` posts as PR comments |
| **debug** | `/debug [description]` | Enables debug logging and reads session debug log to troubleshoot issues |
| **fewer-permission-prompts** | `/fewer-permission-prompts` | Scans transcripts for common read-only Bash/MCP calls and adds prioritized allowlist to `.claude/settings.json` |
| **loop** | `/loop [interval] [prompt]` | Runs a prompt repeatedly while session is open; Claude self-paces if interval omitted. Alias: `/proactive` |
| **run** | `/run` | Launches and drives your project's app to observe changes working in the running app, not just in tests |
| **run-skill-generator** | `/run-skill-generator` | Teaches `/run` and `/verify` how to build, launch, and drive your specific project by writing a per-project skill |
| **simplify** | `/simplify [target]` | Cleanup-only code review (v2.1.154+): 4 parallel agents covering reuse, simplification, efficiency, and abstraction level. Does **not** hunt for bugs — use `/code-review` for that |
| **verify** | `/verify` | Confirms a code change does what it should by building and running the app, then observing results |

### 3.2 Bundled Workflows

Workflows are dynamic multi-agent fan-outs that run in the background:

| Workflow | Command | Purpose |
|----------|---------|---------|
| **deep-research** | `/deep-research <question>` | Fans out web searches, fetches and cross-checks sources, synthesizes a cited report |
| **ultrareview** | `/code-review ultra` or `/ultrareview [PR]` | Deep multi-agent code review in cloud sandbox. 3 free runs on Pro/Max |
| **ultraplan** | `/ultraplan <prompt>` | Plans in browser, executes remotely or returns to terminal |

---

## 4. Pre-built Agent Skills

Anthropic provides pre-built skills for common document workflows, available on
claude.ai, Claude API, AWS Bedrock (via Claude Platform), and Microsoft Foundry.

| Skill ID | Capability |
|----------|-----------|
| `pptx` | Create presentations, edit slides, analyze PowerPoint content |
| `xlsx` | Create spreadsheets, analyze data, generate reports with charts |
| `docx` | Create documents, edit content, format text |
| `pdf` | Generate formatted PDF documents and reports |

These are specified via `skill_id` in the `container` parameter (API usage requires beta
headers: `code-execution-2025-08-25`, `skills-2025-10-02`, `files-api-2025-04-14`).

### 4.1 Open-Source Anthropic Skills

Anthropic also publishes open-source skills in [github.com/anthropics/skills](https://github.com/anthropics/skills):

| Skill | What it does |
|-------|-------------|
| **claude-api** | Up-to-date API reference material, SDK docs, and best practices for 8 programming languages. Bundled with Claude Code. |

### 4.2 Cross-Platform Note

Skills do **not** sync across surfaces automatically:
- **claude.ai** — individual-user only; not org-wide
- **Claude API** — workspace-wide; all members can access
- **Claude Code** — personal (`~/.claude/skills/`) or project (`.claude/skills/`)

---

## 5. This Repository: Orchestra-Skills

**Repository:** `dotts-h/claude-skills`  
**Plugin:** `orchestra-skills` v0.1.0  
**Skills:** 13, organized into 4 groups  
**Install:** Add to `.claude/settings.json` → cloud sessions install automatically

```json
{
  "extraKnownMarketplaces": {
    "ori": { "source": { "source": "github", "repo": "dotts-h/claude-skills" } }
  },
  "enabledPlugins": ["skills@ori"]
}
```

### 5.1 Documentation Group (5 skills)

These skills maintain the living documentation layer of a project — the single source of
truth files that every other skill reads before acting.

#### `recording-decisions`
Creates and maintains Architecture Decision Records (ADRs) in MADR-lite format.  
**Key rule:** Immutable once accepted — reversals create a *new* ADR, they don't edit the old one.  
**Scripts:** `new-adr.sh`, `reindex.sh`, `relink.sh`  
**References:** madr-template.md, styles.md

#### `registering-contracts`
Generates and maintains `docs/CONTRACTS.md` — a registry of stable promises between
components: interfaces, event vocabularies, HTTP routes, data schemas, invariants.  
**Stability levels:** `stable` (breaking change requires ADR), `internal` (free to move), `experimental`  
**Scripts:** `ensure-doc.sh`, `extract-interfaces.sh`  
**References:** contract-entry-template.md, detecting-drift.md

#### `maintaining-conventions`
Owns `docs/CONVENTIONS.md` — the single source of truth for rules, read by all other skills
before they act. Links every rule to an ADR.  
**Scripts:** `harvest.sh` (extracts signals from Makefile, package.json, .golangci.yml, etc.), `check.sh`  
**References:** convention-categories.md

#### `logging-learnings`
Maintains a running log of fixed bugs (with their guards), dead-end approaches, and gotchas.  
**Core rule:** Every fixed-bug entry must name the test that now guards it.  
**Scripts:** `ensure-doc.sh`  
**References:** entry-templates.md

#### `mapping-codebases`
Generates and maintains `docs/CODEBASE_MAP.md` — one-screen module layout, data flows,
and seam inventory.  
**Key distinction:** Pure-core (stdlib only) vs thin-edges (touches network/SDK/HTTP).  
**Scripts:** `module-inventory.sh`  
**References:** map-template.md

### 5.2 Process Group (4 skills)

#### `practicing-tdd`
Drives development test-first — red/green/refactor cycle. Tests drive behavior **through
the seam** (interface), not implementation, so they survive refactors.  
**Scripts:** `gate.sh`  
**References:** red-green-refactor.md, testing-through-the-seam.md

#### `managing-tech-debt`
Maintains a prioritized debt register (`docs/TECH_DEBT.md`).  
**Prioritization lens:** Interest × likelihood, not recency. Debt that slows every change
has high interest; cosmetic gaps have low interest.  
**Scripts:** `ensure-doc.sh`, `debt-scan.sh`  
**References:** debt-register-template.md, prioritization.md

#### `improving-architecture`
Assesses architecture for boundary violations, coupling, dependency drift; proposes
improvements as ADRs.  
**Scripts:** `deps-check.sh`  
**References:** dependency-rules.md, coupling-smells.md, refactor-as-adr.md

#### `auditing-code-quality`
Reviews code against a patterns/antipatterns catalog (Go idioms + project seam discipline).
Complements `/code-review` (bugs) and `/simplify` (mechanical) without duplicating.  
**Scripts:** `smells.sh`  
**References:** antipatterns-catalog.md, go-patterns.md, project-idioms.md

### 5.3 QA Group (3 skills)

#### `hardening-tests`
Audits and hardens existing test suites — coverage gaps, assertion strength, flakes,
missing edge/property/fuzz cases.  
**Key insight:** Coverage says a line ran; mutation testing says it's actually *checked*.  
**Scripts:** `flake-hunt.sh`, `mutation-run.sh`  
**References:** assertion-strength.md, flake-hunting.md, mutation-testing.md

#### `authoring-tests`
Writes higher test layers — e2e (Playwright), API/contract, performance, and a11y.  
**Layer matrix:**

| Layer | Proves | Location |
|-------|--------|----------|
| e2e | Real browser flows, htmx swaps, SSE | e2e/tests/*.spec.ts |
| api/contract | Content-types, escaping, cookies, malformed tolerance | internal/web/api_test.go |
| perf | Render/reducer hot paths, page latency | bench_test.go + Playwright |
| a11y | WCAG 2.1/2.2 A/AA via axe-core | e2e/tests/a11y.spec.ts |

**Scripts:** `init-agents.sh`, `run-layer.sh`

#### `exploring-quality`
Runs exploratory QA in two phases: scripted breadth (headless probes) then curiosity-led
depth (real browser), producing a ranked findings report.  
**Why two phases:** Breadth without depth is a pile of status codes. Depth without breadth
misses most of the surface.  
**Scripts:** `surface-inventory.sh`, `launch-demo.sh`, `breadth-sweep.sh`

### 5.4 Design Group (1 skill)

#### `designing-ui-ux`
Audits and improves UX (heuristics, IA, flows, a11y) and UI (hierarchy, tokens,
typography, spacing, color, motion); implements and verifies in browser.  
**Loop:** Audit → Design → Implement → Verify  
**Evaluation standard:** axe clean (no new A/AA violations), existing a11y test still green,
before/after screenshots show measurable improvement.  
**Scripts:** `axe-scan.sh`, `screenshot-states.sh`  
**References:** ux-heuristics.md, wcag-pour.md, refactoring-ui.md, design-tokens.md, htmx-implementation.md

---

## 6. Testing Skills: Current State & Gaps

### 6.1 What Orchestra Already Covers

The three QA skills plus `practicing-tdd` cover:

| Test type | Where it lives |
|-----------|---------------|
| Unit / seam tests (TDD) | `practicing-tdd` |
| Mutation testing | `hardening-tests` → mutation-run.sh |
| Property / fuzz hints | `hardening-tests` → assertion-strength.md |
| Flake detection | `hardening-tests` → flake-hunt.sh |
| e2e (Playwright) | `authoring-tests` |
| API / contract tests | `authoring-tests` |
| Performance (basic) | `authoring-tests` (bench_test.go + Playwright) |
| Accessibility | `authoring-tests` + `designing-ui-ux` |
| Exploratory | `exploring-quality` |

### 6.2 Gap: Performance & Load Testing

**What's missing:** A dedicated skill for systematic **load and stress testing** —
throughput baselines, regression detection across builds, soak (long-duration stability),
and spike testing.

The community has addressed this with dedicated skills:
- **k6-load-testing** (qaskills.sh) — covers smoke / load / stress / soak test shapes
- **performance-profiler** (alirezarezvani/claude-skills) — Node/Python/Go profiling, bundle analysis, load testing

**Gap analysis for this repo:**
- `authoring-tests` mentions `bench_test.go` but has no guidance on *when to run* performance
  tests, what thresholds to enforce, or how to track regression across commits
- No coverage of HTTP-layer throughput (requests/sec, P95/P99 latency)
- No guidance on profiling memory allocations under load
- No soak test pattern (run for hours to detect slow leaks)

**Recommended new skill: `profiling-performance`**
- Run Go's `pprof` and benchmark harness; generate flame graphs
- Enforce latency SLOs in CI (fail if P95 > threshold)
- Track perf regressions as entries in `docs/TECH_DEBT.md`
- Soak test pattern: run demo under sustained load for configurable duration, report allocations

### 6.3 Gap: Fuzz Testing

**What's missing:** Systematic **corpus-driven fuzz testing** of parsers, decoders, and
boundary-handling code.

Go has first-class fuzz support since 1.18 (`go test -fuzz=FuzzXxx`). The repo's
`hardening-tests` skill mentions property/fuzz tests in `assertion-strength.md` but
does not provide a workflow or scripts for:
- Seeding a fuzz corpus
- Running fuzzing in CI (time-boxed)
- Triaging and minimizing crashing inputs
- Storing corpus entries in version control

Community comparisons:
- **mutation-testing / property-based-test-gen** skill (MiniKao's 24-skill QA suite) — runs
  Hypothesis (Python) / fast-check (JS) strategies to close coverage gaps
- **ffuf-web-fuzzing** (travisvn/awesome-claude-skills) — HTTP-level fuzzing for web surfaces

**Recommended new skill: `fuzzing-inputs`**
- Identify fuzz targets: parsers, decoders, user-input handlers, template engines
- Scaffold `func FuzzXxx(f *testing.F)` with seed corpus
- Run `go test -fuzz=. -fuzztime=60s ./...` in a CI gate
- Store surviving corpus in `testdata/fuzz/` (Go standard location)
- Triage crashes: minimize input, write regression test, log to `logging-learnings`

### 6.4 Gap: Chaos / Stability Engineering

**What's missing:** A skill for controlled **failure injection** to verify the system
degrades gracefully rather than catastrophically.

The community has this well covered:
- **jeffallan/claude-skills chaos-engineer** — designs experiments with Litmus Chaos
  (Kubernetes pod/node failure), toxiproxy (network latency/packet-loss injection), and
  Chaos Monkey (instance termination). Outputs experiment manifests, rollback procedures,
  and post-mortem templates.
- **Guardrails enforced:** Steady-state first; blast radius stays minimal; automated
  rollback within 30 seconds; single variable change per experiment.

For this repo's context (Go server + SSE + browser client), relevant chaos scenarios:
- Network latency injection between components (toxiproxy)
- Abrupt connection drops during SSE streaming
- Concurrent request floods past handler capacity
- Disk-full / memory-pressure simulation
- Clock skew (time.Now() injection via interface)

**Recommended new skill: `stress-testing-resilience`**
- Phase 1: Map failure modes from CODEBASE_MAP.md and CONTRACTS.md
- Phase 2: Run controlled fault-injection scenarios (toxiproxy or synthetic)
- Phase 3: Assert steady-state metrics recovered within SLO
- Output: resilience report + new entries in `docs/REGRESSIONS.md` for any discovered gaps

### 6.5 Gap: Visual Regression Testing

**What's missing:** Pixel-level (or DOM-level) **visual regression detection** — catching
unintended CSS regressions across changes.

Community solutions:
- **visual-regression-percy-chromatic** (qaskills.sh) — visual diffing via Percy/Chromatic
- **visual-regression-gen** (MiniKao's 24-skill suite) — generates baseline screenshots
  and detects pixel-level changes
- **Storybook + Claude** (atfzl.com) — component-scoped visual regression within
  Storybook's isolated canvas

The `designing-ui-ux` skill already runs `screenshot-states.sh` for before/after evidence.
What's missing is a **baseline + diff** workflow that can fail CI on regression.

**Recommended enhancement to `authoring-tests`:** Add a visual regression section using
Playwright's built-in screenshot comparison (`expect(page).toHaveScreenshot()`) — no
external service required for a self-hosted app.

### 6.6 Gap: Contract Testing (Cross-Service)

**What's partially covered:** `authoring-tests` handles API/contract tests for this repo's
own HTTP surface. `registering-contracts` maintains the registry.

**What's missing:** If this project ever becomes a multi-service system, there is no
skill for **consumer-driven contract testing** (Pact-style) where the consumer defines
expectations and the provider verifies against them.

Community: **contract-testing-pact** (qaskills.sh).

For the current single-service context, `registering-contracts` + `authoring-tests`
is sufficient. The gap becomes relevant at the point of service extraction.

### 6.7 Testing Coverage Summary

| Test type | Covered? | Where | Gap skill needed? |
|-----------|---------|-------|-------------------|
| Unit / TDD | ✅ | `practicing-tdd` | No |
| Mutation | ✅ | `hardening-tests` | No |
| Flake detection | ✅ | `hardening-tests` | No |
| e2e (Playwright) | ✅ | `authoring-tests` | No |
| API / HTTP contract | ✅ | `authoring-tests` | No |
| Accessibility (a11y) | ✅ | `authoring-tests` + `designing-ui-ux` | No |
| Exploratory QA | ✅ | `exploring-quality` | No |
| Property / fuzz | ⚠️ Partial | `hardening-tests` mentions it | **`fuzzing-inputs`** |
| Load / stress | ⚠️ Partial | bench_test.go only | **`profiling-performance`** |
| Soak / stability | ❌ Missing | — | **`stress-testing-resilience`** |
| Visual regression | ⚠️ Partial | `screenshot-states.sh` (manual) | Add to `authoring-tests` |
| Consumer-driven contracts | ❌ Future | — | When multi-service |

---

## 7. UI/UX Prototyping Skills

### 7.1 What Orchestra Already Covers

`designing-ui-ux` is a comprehensive design skill covering:
- UX audit (Nielsen's 10 heuristics, Krug's "don't make me think")
- WCAG 2.2 a11y audit (POUR framework, axe-core)
- UI design (visual hierarchy, design tokens, typography, color, motion — Refactoring UI)
- Token-based implementation (CSS custom properties → `docs/DESIGN.md`)
- Verification in browser (axe-scan.sh + screenshot-states.sh)

The skill is **full-stack design**: it audits, designs, implements, and verifies. This is
the right scope for a production app living in one codebase.

### 7.2 What Prototyping Means and Why It's Different

**Prototyping** is different from design implementation. A prototype explores and
communicates ideas *before* committing to production code. The goals are:

1. **Speed** — try 3 layouts in an hour, not a sprint
2. **Isolation** — test a component without the full app
3. **Stakeholder communication** — interactive mockups without backend
4. **Design system validation** — ensure tokens look right across all components

The current `designing-ui-ux` skill focuses on production implementation. A **prototyping
skill** would front-load exploration.

### 7.3 The Storybook Pattern (Component Isolation)

The strongest 2026 pattern for UI prototyping in a real codebase is
**Storybook + Claude Code** (not external tools like Lovable or v0.dev).

**Why Storybook over external tools:**
- Prototypes live in the codebase — CI/CD catches regressions automatically
- Uses real production components — no handoff gap
- Direct CLAUDE.md integration — Claude knows your design system
- MCP integration — `@storybook/addon-mcp` exposes `list_components`,
  `get_component_props`, `get_component_source` to Claude as tools

**The workflow:**
1. Install `@storybook/addon-mcp` and configure
2. Claude queries your component library: `list_components`, `get_component_source`
3. Claude writes a Story (`ComponentName.stories.ts`) that renders the component with
   mock data and interaction tests
4. Visual regression testing runs automatically on each story
5. Stakeholders view the deployed Storybook (Chromatic/self-hosted) for interactive review

**Storybook assistant plugin** (flight505/storybook-assistant) provides:
- 18 skills, 12 slash commands, 3 agents (v2026)
- `/setup-storybook` — auto-configures for React, Vue, Angular, Next.js, Svelte, Solid
- `/generate-stories` — scaffolds stories with TypeScript, tests, a11y checks
- `/create-component` — full scaffold with story, test, docs
- Visual regression testing via Playwright (pixel-perfect change detection)
- Design system integration: MUI, Ant Design, shadcn/ui, Chakra, Mantine
- WCAG accessibility checks via axe-core on every story

### 7.4 The SPA Module Prototyping Pattern

For SPAs, prototyping a new **route or module** in isolation (before integrating into the
router) is a powerful pattern:

1. Create `src/prototypes/checkout-flow/` with a standalone React root
2. Wire up Mock Service Worker (MSW) to intercept API calls with realistic data
3. Use in-memory router for multi-step flows (wizard, tabs, breadcrumb navigation)
4. Share design tokens from `docs/DESIGN.md` / `app.css` variables
5. When approved: promote to `src/routes/checkout/`, remove MSW stubs

This approach lets Claude Code generate an entire interactive module prototype in a single
session, with the user providing feedback on the live Storybook/prototype before any
production routing is touched.

### 7.5 Gap Analysis for This Repo

The `designing-ui-ux` skill in orchestra-skills is **production-first**, which is correct
for its scope. What's missing is a **prototyping-first companion** for exploring new
UI ideas quickly.

This repo is a Go server-rendered app (htmx + SSE). Prototyping considerations:
- Server-side fragments can be previewed in isolation using the `demo` mode
- Static HTML mockups can be generated and opened in a browser to explore layouts
- The `screenshot-states.sh` script can capture states for stakeholder review

**Recommended enhancement to `designing-ui-ux`:** Add a `## Rapid prototyping` section:
1. Scaffold a static HTML mockup from design tokens in `app.css`
2. Run `python3 -m http.server` (or similar) for browser preview
3. Use `screenshot-states.sh` for stakeholder share
4. When approved: port to htmx templates

For JavaScript/React/Vue frontends, a separate **`prototyping-with-storybook`** skill
would be appropriate.

### 7.6 How Other Teams Are Approaching This

| Team approach | Tools | Tradeoff |
|--------------|-------|---------|
| External AI prototyping | v0.dev, Lovable, bolt.new | Fast but disconnected from real codebase |
| Storybook + Claude Code | @storybook/addon-mcp + Claude | Slower setup, but prototypes ARE production code |
| Design tool bridge | Figma → Code Connect → Claude | Preserves design intent, requires Figma |
| UXPin Merge | claude.ai + UXPin design system | Best for established design systems |

The consensus in 2026 is that **prototypes should live in the codebase** — external tools
create a handoff gap that costs more than the speed gain.

---

## 8. Community Ecosystem

### 8.1 The Awesome-Claude-Code Universe

Multiple "awesome" collections have emerged, with thousands of community skills:

| Repository | Highlight |
|------------|-----------|
| [travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) | Curated quality list; good starting point |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Skills, agents, hooks, orchestrators, apps, plugins |
| [rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) | 135 agents, 35 skills, 42 commands, 176+ plugins, 20 hooks |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | 337+ skills across 16 domains for 13 AI platforms |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1 000+ community agent skills |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 1 500+ installable skills; compatible CLI installer |
| [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | Integration-focused skills (Composio MCP) |

As of 2026, Claude Code skills follow the [Agent Skills open standard](https://agentskills.io),
meaning skills written for Claude Code also work (with minor adjustments) in Cursor,
Gemini CLI, Codex CLI, Antigravity IDE, and more.

### 8.2 Notable Community Skills

| Skill | What it does | Source |
|-------|-------------|--------|
| **obra/superpowers** | 20+ battle-tested utilities: TDD, debugging, collaboration. Commands: `/brainstorm`, `/write-plan` | travisvn list |
| **Trail of Bits security** | Static analysis, variant analysis, code auditing, vulnerability detection | travisvn list |
| **ios-simulator-skill** | Mobile app automation and testing | travisvn list |
| **playwright-skill** | Browser automation with full Playwright API | community |
| **ffuf-web-fuzzing** | Penetration testing with authenticated request handling | community |
| **claude-d3js-skill** | Data visualization capabilities | community |
| **loki-mode** | Orchestrates 37 AI agents across 6 swarms for autonomous startup building | community |
| **chaos-engineer** | Designs chaos experiments with Litmus Chaos, toxiproxy, Chaos Monkey | jeffallan |
| **skill-creator** | Anthropic's meta-skill — builds new skills interactively with eval-driven optimization | Anthropic |

### 8.3 The 24-Skill QA Suite (MiniKao)

One of the most comprehensive community testing suites, open-sourced in 2026:

| Category | Skills |
|----------|--------|
| Test Design | test-master, flutter-test-master, test-review, regression-test, speckit-to-tc, tc-version-diff, sheet-md-sync, smoke-test-analyzer |
| Automation | test-automation, flutter-test-automation, tc-to-pytest |
| Bug Management | bug-report |
| Quality Quantification | **mutation-testing**, **property-based-test-gen** |
| Reporting | publish-regression |
| Performance & Security | **performance-test-gen**, security-scan, **api-contract-test** |
| CI Health | **visual-regression-gen**, **flaky-test-hunter** |
| Quality Specialties | **a11y-audit**, localization-test, push-notification-test, test-data-factory |

**Notable:** `mutation-testing` runs mutmut on Python, deliberately introduces faults (`<` → `<=`),
and if tests still pass the mutation "survived" — meaning fake coverage.
`property-based-test-gen` then generates Hypothesis strategies to close those gaps.

### 8.4 Cross-Platform Skill Ecosystem (2026)

The skill ecosystem has fragmented/unified simultaneously:
- Same `SKILL.md` format works across Claude Code, Cursor, Gemini CLI, Codex CLI
- Community installers (curl one-liners) make single-command installation possible
- SkillKit marketplace referenced by rohitg00's toolkit claims 400 000+ skills
- Anthropic's official skill-creator meta-skill automates new skill development

### 8.5 What Makes Skills Stand Out

Analysis of the most-starred community skills reveals common patterns:

1. **Concrete scripts** — not just instructions; executable scripts for the deterministic parts
2. **Three-mode operation** — full-MCP, partial-MCP (degraded), markdown-only (offline)
3. **Safety guardrails** — explicit "do not do X" rules with consequences stated
4. **Linked docs** — every rule references an ADR or rationale document
5. **Evaluations-first** — 3+ test scenarios defined before the skill body is written

---

## 9. Skill Architecture Best Practices

### 9.1 Core Authoring Principles

**1. Concise is key.** Claude is already smart. Only add context Claude doesn't already
have. Challenge each paragraph: "Does Claude need this, or does it already know it?"

Good (50 tokens):
```markdown
## Extract PDF text
Use pdfplumber: `with pdfplumber.open("file.pdf") as pdf: text = pdf.pages[0].extract_text()`
```

Bad (150 tokens): Four paragraphs explaining what a PDF is and why pdfplumber is recommended.

**2. Set appropriate degrees of freedom.** Match specificity to task fragility:
- **High freedom** (text instructions): multiple valid approaches, context-dependent
- **Medium freedom** (pseudocode with params): preferred pattern with acceptable variation
- **Low freedom** (exact script, no flags): fragile operations, exact sequence required

**3. Test with all target models.** Skills are model-dependent. What works for Opus may
need more detail for Haiku. Haiku needs more guidance; Opus needs less verbosity.

**4. Build evaluations first.** Write 3 test scenarios before writing the skill body.
This prevents documenting imagined problems rather than real ones.

### 9.2 Naming Conventions

```
✅ processing-pdfs          (gerund — describes the activity)
✅ pdf-processing            (noun phrase — acceptable)
✅ process-pdfs              (action-oriented — acceptable)
❌ helper                   (too vague)
❌ anthropic-pdf-tools      (reserved word "anthropic")
❌ claude-docs              (reserved word "claude")
```

- Max 64 characters; lowercase letters, numbers, hyphens only
- Gerund form (`processing-pdfs`) is the recommended convention

### 9.3 Writing Effective Descriptions

The description field is the **most critical part** — Claude uses it to pick the right skill
from potentially 100+ available. It must answer: *what does it do* AND *when should I use it*.

Formula: `[Action verb] [what] [for/when] [trigger conditions]`

```yaml
# Good — specific, includes trigger
description: >
  Extracts text and tables from PDF files, fills forms, merges documents.
  Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.

# Bad — too vague
description: Helps with documents
```

Rules:
- Always write in **third person** (injected into system prompt)
- Max 1 024 characters
- No XML tags; no reserved words
- Include at least 2-3 specific trigger terms

### 9.4 Progressive Disclosure Structure

```
skill-name/
├── SKILL.md              ← ≤500 lines, points to reference files
├── references/
│   ├── topic-a.md       ← loaded only when topic A is needed
│   ├── topic-b.md       ← loaded only when topic B is needed
│   └── topic-c.md
└── scripts/
    ├── analyze.sh       ← executed (not loaded into context)
    └── validate.sh
```

Rules:
- All reference files link **one level deep** from SKILL.md (never chain references)
- Files > 100 lines should have a table of contents at the top
- Scripts are **executed, not read** — only their output costs tokens

### 9.5 Workflows and Feedback Loops

For multi-step operations, use a **checklist pattern**:

```markdown
Copy this checklist and check items off as you complete them:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

For validation-heavy skills, use the **plan-validate-execute pattern**:
1. Claude generates a structured plan file (JSON or YAML)
2. A script validates the plan before execution
3. Catch errors early — before irreversible changes are made

### 9.6 Anti-Patterns to Avoid

| Anti-pattern | Problem | Fix |
|-------------|---------|-----|
| Offering too many options | Paralyzes Claude | Provide one default with a named escape hatch |
| Punting errors to Claude | Unreliable | Handle errors explicitly in scripts |
| Windows-style paths (`\`) | Breaks on Unix | Always use forward slashes |
| Voodoo constants (`TIMEOUT = 47`) | Nobody knows why | Add brief inline justification |
| Too many nested references | Claude may partially read | Keep references one level deep from SKILL.md |
| Time-sensitive information | Becomes stale | Use "old patterns" sections for deprecated info |
| Inconsistent terminology | Confuses Claude | Pick one term and use it everywhere |

### 9.7 Security Considerations

- Only use skills from **trusted sources** (yourself, Anthropic, vetted community)
- Skills with `allowed-tools: Bash` can execute arbitrary shell commands
- Skills that fetch from external URLs can receive injected instructions
- Audit all files in a skill bundle before installation: SKILL.md, scripts, reference files
- Treat skill installation like installing software — review before running

### 9.8 Composition Patterns

Skills are designed to **compose**. The orchestra-skills plugin demonstrates this well:
each skill has explicit **boundary rules** that define what it does *and what it defers to
other skills*:

```
auditing-code-quality:
  bugs/correctness → /code-review
  mechanical simplify → /simplify
  structure/modules → improving-architecture
  test quality → hardening-tests
```

This prevents skill overlap and ensures Claude routes tasks to the right specialist.
Document your skill's boundaries explicitly in its SKILL.md.

---

## 10. Recommended New Skills for This Repo

Based on the gap analysis above, here are concrete skill proposals for orchestra-skills.

### 10.1 `profiling-performance` (High Priority)

**Purpose:** Systematically profile Go performance, detect regressions, enforce SLOs.

**When to use:** After perf-sensitive changes, before releases, or when investigating latency.

**Workflow:**
1. Run existing benchmarks: `go test -bench=. -benchmem ./...`
2. Profile hot path: `go test -run=^$ -bench=BenchmarkX -cpuprofile=cpu.prof ./pkg/`
3. Analyze: `go tool pprof -top cpu.prof` — report top 10 functions by CPU %
4. Compare against baseline in `docs/PERF_BASELINES.md`
5. If regression: add entry to `docs/TECH_DEBT.md` with severity and effort

**Files to add:**
```
skills/profiling-performance/
├── SKILL.md
├── references/
│   ├── slo-thresholds.md     ← P95 latency, throughput targets
│   └── profiling-guide.md    ← pprof commands, flame graph reading
└── scripts/
    ├── bench-compare.sh      ← run bench, compare to stored baseline
    ├── update-baseline.sh    ← update baseline after intentional improvement
    └── soak-run.sh           ← sustained load for N minutes, report allocations
```

### 10.2 `fuzzing-inputs` (High Priority)

**Purpose:** Scaffold and run Go corpus-driven fuzz tests for boundary-handling code.

**When to use:** New parsers, decoders, user-input handlers, template rendering functions.

**Workflow:**
1. Identify fuzz targets: grep for parsing/decoding functions
2. Scaffold `func FuzzXxx(f *testing.F)` with seed corpus entries
3. Run time-boxed fuzzing: `go test -fuzz=FuzzXxx -fuzztime=60s ./pkg/`
4. If crash found: minimize input, write regression test, log to `logging-learnings`
5. Store corpus in `testdata/fuzz/FuzzXxx/` (standard Go location, auto-replayed by `go test`)

**Files to add:**
```
skills/fuzzing-inputs/
├── SKILL.md
├── references/
│   ├── fuzz-target-patterns.md    ← what makes a good fuzz target
│   └── corpus-management.md       ← seeding, minimization, CI integration
└── scripts/
    ├── find-fuzz-targets.sh        ← grep for fuzz-worthy functions
    └── fuzz-timed.sh               ← run fuzz for N seconds, capture crashes
```

### 10.3 `stress-testing-resilience` (Medium Priority)

**Purpose:** Verify the system degrades gracefully under failure and load conditions.

**When to use:** Before releases involving network-dependent or concurrency-sensitive code.

**Workflow:**
1. Map failure modes from CODEBASE_MAP.md (seams, external deps, concurrency points)
2. Phase 1 — synthetic stress: `go test -race -count=10 ./...` + HTTP flood
3. Phase 2 — fault injection: toxiproxy latency/packet-loss on downstream calls
4. Phase 3 — connection drop: verify SSE clients reconnect, no orphaned goroutines
5. Assert: steady-state metrics (error rate, goroutine count) recover within SLO
6. Output: resilience report → `docs/qa/resilience-YYYY-MM-DD.md`

**Boundary:** This skill *runs* experiments and *reports* findings. Fixing discovered
gaps goes to `practicing-tdd` or `authoring-tests`.

### 10.4 Enhancement to `authoring-tests`: Visual Regression

Add a `## Visual regression tests` section using Playwright's built-in screenshot comparison:

```typescript
// In e2e/tests/visual.spec.ts
test('dashboard looks correct', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).toHaveScreenshot('dashboard.png');
});
```

- First run creates baseline screenshots in `e2e/tests/snapshots/`
- Subsequent runs diff against baseline; CI fails on unexpected change
- Update command: `npx playwright test --update-snapshots`

This is **zero-dependency** (built into Playwright) and maps perfectly onto the existing
`authoring-tests` structure.

### 10.5 Enhancement to `designing-ui-ux`: Rapid Prototyping Section

Add a `## Rapid prototyping` phase before the Audit → Design → Implement loop:

**Phase 0 — Prototype:**
1. Read relevant sections of CONVENTIONS.md, design-tokens.md
2. Generate a standalone static HTML prototype in `docs/prototypes/YYYY-MM-DD-feature/`
3. Serve: `python3 -m http.server 9999 --directory docs/prototypes/`
4. Run `screenshot-states.sh` to produce stakeholder-share images
5. Iterate on feedback *before* touching production templates

This adds a fast exploration phase without changing the production-quality focus of the
existing skill.

---

## 11. Roadmap

### Phase 1: Fill Critical Testing Gaps (Q3 2026)

| Item | Effort | Impact |
|------|--------|--------|
| Add visual regression section to `authoring-tests` | Small | High — zero-dependency, immediate CI value |
| Add rapid prototyping section to `designing-ui-ux` | Small | High — enables faster design iteration |
| Create `fuzzing-inputs` skill | Medium | High — Go 1.18+ fuzz is first-class, currently untapped |
| Create `profiling-performance` skill | Medium | High — no current perf regression detection |

### Phase 2: Stability & Resilience (Q4 2026)

| Item | Effort | Impact |
|------|--------|--------|
| Create `stress-testing-resilience` skill | Large | Medium-High — important pre-release gate |
| Add soak test pattern to `profiling-performance` | Small | Medium — catches slow memory leaks |

### Phase 3: Ecosystem Integration (Q1 2027)

| Item | Effort | Impact |
|------|--------|--------|
| Add Storybook MCP integration to `designing-ui-ux` | Medium | Medium — only relevant if frontend stack changes |
| Add consumer-contract testing to `registering-contracts` | Large | Low now, critical if multi-service |
| Publish skills to Agent Skills open standard registry | Small | High — discoverability for community |

### Skill Count Projection

| Phase | Current | Added | Total |
|-------|---------|-------|-------|
| Today | 13 | — | 13 |
| Phase 1 | 13 | +2 skills, 2 enhancements | 15 |
| Phase 2 | 15 | +1 skill, 1 enhancement | 16 |
| Phase 3 | 16 | +2 integrations | 18 |

---

## Appendix A: Quick Skill Comparison

| Skill | Group | Type | Scripts | References | Unique strength |
|-------|-------|------|---------|-----------|-----------------|
| recording-decisions | Docs | Preference | 3 | 2 | Immutable ADR lifecycle |
| registering-contracts | Docs | Preference | 2 | 2 | Stability-level taxonomy |
| maintaining-conventions | Docs | Preference | 2 | 1 | Cross-skill source of truth |
| logging-learnings | Docs | Preference | 1 | 1 | Mandatory guard linkage |
| mapping-codebases | Docs | Preference | 1 | 1 | Pure-core/thin-edge mapping |
| practicing-tdd | Process | Preference | 1 | 2 | Through-the-seam discipline |
| managing-tech-debt | Process | Preference | 2 | 2 | Interest × likelihood ranking |
| improving-architecture | Process | Preference | 1 | 3 | Coupling-smell taxonomy |
| auditing-code-quality | Process | Preference | 1 | 3 | Go seam discipline |
| hardening-tests | QA | Preference + Uplift | 2 | 3 | Mutation testing |
| authoring-tests | QA | Preference + Uplift | 2 | 3 | 4-layer test matrix |
| exploring-quality | QA | Uplift | 3 | 3 | Two-phase breadth/depth |
| designing-ui-ux | Design | Preference + Uplift | 2 | 5 | Full design loop |

---

## Appendix B: Key External Resources

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) — official reference
- [Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) — official authoring guide
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) — architecture reference
- [Claude Code Commands Reference](https://code.claude.com/docs/en/commands) — full command table
- [travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) — curated community skills
- [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — comprehensive community list
- [rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) — 135 agents + toolkit
- [flight505/storybook-assistant](https://github.com/flight505/storybook-assistant) — Storybook + Claude Code integration
- [jeffallan/claude-skills chaos-engineer](https://jeffallan.github.io/claude-skills/skills/devops/chaos-engineer/) — chaos engineering skill reference
- [agentskills.io](https://agentskills.io) — open standard for cross-platform skills
- [Storybook AI Documentation](https://storybook.js.org/docs/ai) — Storybook MCP + AI tools

---

*Report compiled from: official Anthropic documentation, Claude Code commands reference,
platform.claude.com best practices, community GitHub repositories, qaskills.sh blog,
dev.to QA skills article, atfzl.com Storybook prototyping guide, and direct analysis of
the orchestra-skills plugin source code.*
