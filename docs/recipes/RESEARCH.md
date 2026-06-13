# Recipes: packaging an engineering process stack as installable, doc-based software

> The original deep-dive research report (2026-06-12) that led to this repo. Written before
> the project was named **cookbook** — references to "orchestra-recipes" and "the recipes
> repo" read as *cookbook*. The condensed, living version is [DESIGN.md](DESIGN.md); this
> file is the full record, including prior art and the fleet/rollout reasoning. Grounded in
> `dotts-h/Copilot-sdk` (the *my-orchestra* app), whose process stack is the source material.

## TL;DR

The idea is sound and closer than it looks: `seed-project-infra` (Copilot-sdk) is already
recipe v0, and the claude-skills marketplace is already the distribution channel. What's
missing is exactly four things that turn "a skill that scaffolds docs" into "process
software": a **manifest** (what a recipe needs and provides), a **lock file** in the target
repo (what was installed, which version, with which answers), a **doctor** (deterministic
conformance check that detects drift), and an **update path** (re-apply a newer recipe
version with a 3-way merge instead of a clobber). Recipes should be **layered** — one core
recipe everything depends on, lifecycle recipes on top, thin per-surface *bindings* rather
than parallel FE/BE/QA recipes — and each repo declares a **profile + scale tier** so a
300-line functions mini-repo gets ~4 small files while a full app gets the whole stack.

---

## 1. The raw material (what Copilot-sdk has)

The process stack decomposes into four kinds of material, and the distinction matters
because each travels differently:

| Kind | What it is there | How it travels |
|---|---|---|
| **Doctrine** (invariant rules) | one fact one home; enforce with hooks, not memory; small auditable diffs; verify outward-facing actions; test-first | Copied verbatim — repo-independent prose |
| **Structure** (doc skeleton) | thin `CLAUDE.md` pointer → CONVENTIONS / CONTEXT glossary / CONTRACTS / ADR log / REGRESSIONS / RETROS / TECH_DEBT / issues+INDEX / generated CODEMAP | Templated — same shape, empty-but-structured |
| **Enforcement** (executable guards) | `check-workflows.sh` wired into CI **and** `make lint`, coverage floor, CI-runs-once triggers, docs-only path-ignore, PostToolUse hook | Parametrized scripts + CI snippets |
| **Facts** (repo-specific bindings) | `make lint && make test`, Go PATH, 65% floor, Playwright layers, branch naming | **Never copied** — asked at install or harvested from the repo |

On top of that sit the **skills**: 13 global methodology skills distributed via the
`skills@ori` plugin from `dotts-h/claude-skills`, plus 5 operational ones
committed in-repo (`cut-release`, `get-next`, `governing-qa-framework`,
`seed-project-infra`, `tracking-issues`).

The crucial design move was already made in Copilot-sdk's SKILLS_PLAN §2 and it is the seed
of the whole recipe idea: **"global methodology, repo-side output — every methodology skill
begins by reading CLAUDE.md + CONVENTIONS for repo-specific values."** Skills *read* the
repo's facts; what was missing is the thing that *writes and maintains* those facts across
many repos. That thing is the recipe.

## 2. Recipe = doc-based software, defined precisely

The "similar to software but built on docs" intuition maps one-to-one onto software
concepts, and taking the analogy seriously is what makes the system work:

- **Interface** → the manifest's `requires`: repo facts the recipe needs bound (test
  command, CI provider, language) and other recipes it depends on.
- **Implementation** → templates (doc skeletons), scripts (guards, generators like
  `codemap.sh`), CI snippets, and the skills that operate the process.
- **Tests** → the **doctor**: a deterministic conformance script per recipe ("CLAUDE.md
  points at CONVENTIONS; CI has no feature-branch push trigger; every REGRESSIONS entry
  names its guard test; lock file matches installed version"). This is `check-workflows.sh`
  generalized — the "enforce with hooks, not memory" doctrine applied to the recipes
  themselves.
- **Package-manager state** → a lock file in the target repo (`.recipes/lock.json`): recipe
  name, version, the answers given at install. This is the single piece of state that makes
  *updates* possible — without it every re-application is a blind overwrite.
- **Releases** → recipes are versioned SemVer; updating a fleet repo = diff lock version vs
  latest, re-apply with a 3-way merge (old template / current repo / new template), open a PR.

That update mechanism is the industry-validated piece: it is exactly what separates Copier
from Cookiecutter — Copier records template version + answers and smart-merges template
updates into living projects, which is the known fix for scaffold drift ("every project
you've ever created is stuck in the past"). We don't need Copier itself — an agent doing
the merge is actually *better* for prose docs (semantic, not textual merge) — but we steal
its state model: **version + answers recorded in the repo, always**.

One sharp difference from plugins, worth keeping in mind: a **plugin/skill is loaded
per-session and leaves no trace in the repo; a recipe installs durable state *into* the
repo** (docs, CI, scripts) that works even with no plugin present — and for any agent, not
just Claude. The two compose: a recipe *ships as* a plugin (its installer skill +
templates), but its *product* is repo content.

## 3. Layering — a default dev recipe that branches out, with one correction

The motivating observation — *the flows are the same regardless of FE/BE/QA* — is confirmed
by Copilot-sdk's own structure, and it dictates the architecture: **don't build parallel
frontend/backend/QA recipes**. The loop (verify base → pick next → failing test first →
gates → review → PR → record decision → merge green) is surface-independent. What varies
per surface is small: which commands, which test layers, which contract artifacts, a
handful of named conventions (e.g. a `--dim`-token rule is frontend-only). So:

```
Layer 0  core               doc skeleton + doctrine + glossary + lock + thin pointers
Layer 1  loop               roadmap→issues→branch→TDD→PR→record  (get-next generalized)
         quality            gates, guard scripts, review-sizing rules, regressions log
         issues             hybrid local-markdown + GitHub mirror (tracking-issues)
         release            tag-driven release + version verification (cut-release)
         contracts          the seams registry — promoted to Layer 1 (see fleet, §5)
Layer 2  surface BINDINGS   frontend.md / api.md / qa.md / services.md — each a small
                            adapter: commands, test layers, surface-specific conventions
```

A binding is ~50–150 lines, not a recipe: it fills the slots the Layer 0/1 recipes leave
open. This keeps "one fact, one home" intact across the catalog — the TDD loop is written
once, in `loop`, and a frontend repo binds `npm test` + Playwright + axe where a Go app
binds `make test` + its e2e layers.

## 4. Repo diversity: profiles and scale tiers

"Don't bring the whole shebang" is solved by two orthogonal knobs recorded in the answers
file:

**Scale tier** controls *doc mass* — important because a mature repo's meta-layer rivals
the code in size, and `seed-project-infra` already encodes the principle ("a new repo
inherits the structure and a few hundred lines, not a mature project's whole doc corpus"):

- **S (mini-repo / functions / components):** CLAUDE.md pointer, CONVENTIONS-lite (one
  page), CONTRACTS, the CI guard. No ADR log (decisions go in a `## Decisions` section of
  CONVENTIONS until there are ~5, then graduate), no RETROS/TECH_DEBT.
- **M (service / library):** + ADR log, REGRESSIONS, issues/INDEX.
- **L (app):** the full stack incl. CODEMAP generation, RETROS, TECH_DEBT.

**Profile** controls *which recipes + bindings*: `app-full`, `mini-api`,
`mini-fe-components`, `mini-functions`, `library`, `greenfield-lean`. A profile is just a
preset bundle of recipes + tier + pre-filled answers.

**Repo age** is handled by install *mode*, not different recipes:

- **Greenfield:** full scaffold, empty-but-structured.
- **Brownfield / in-progress:** **harvest mode** — inventory first, never clobber,
  *generate* CONVENTIONS from what exists (CI workflows, Makefile/package.json scripts,
  CONTRIBUTING). This is proven: Copilot-sdk's own CONVENTIONS footer says it was
  "bootstrapped 2026-06-04 from CONTRIBUTING.md, Makefile, workflows." Gaps become a
  flagged checklist, exactly like the *"ADR needed (backfill)"* markers — adopt
  incrementally, never block on completeness.

## 5. The fleet problem (mini-repos that together form one product)

When FE-framework / components / API / functions are separate repos, the per-repo recipes
aren't enough — the process value lives *between* repos. Two additions:

1. **`contracts` becomes mandatory at every tier**, because a mini-repo fleet lives and
   dies by its seams: each repo's CONTRACTS.md declares **provides** (the component
   library's public API, the API service's routes/schemas) and **consumes** (which versions
   of which siblings). A breaking change to a *provided* contract requires the same
   ceremony everywhere: decision note + version bump + consumer notification.
2. **One hub repo** carries the fleet-level facts that must not be duplicated per-repo: a
   **constellation file** (list of member repos, their profiles, who-consumes-whom) and the
   **shared glossary** (domain terms used across repos — each repo's CONTEXT.md defines
   only its local terms and points up). A fleet-level doctor walks the constellation and
   cross-checks: does every consumed contract exist in the provider's registry at a
   compatible version? That is "one fact, one home" scaled to N repos.

## 6. Distribution mechanics

Plugins bundle skills, commands, agents, hooks, and MCP servers, and the existing private
marketplace already serves cloud/web sessions. What plugins do **not** do is scaffold files
into a repo or track installed versions — so the recipe layer is agent-executed:

- **Where:** a plugin (this repo), later merged into `dotts-h/claude-skills` as a second
  plugin alongside `skills` (the marketplace wiring already exists in every
  repo's settings; one repo, two plugins).
- **Install:** an `/adopt-recipes` skill — inventory the target repo → propose profile +
  tier + answers → confirm with the user → apply recipes in dependency order (harvest mode
  where files exist) → write `.recipes/lock.json` → wire doctor into the repo's lint
  target/CI → emit the gap checklist. Deterministic steps live in scripts (executed, not
  read); judgment steps (merging into an existing CONVENTIONS) stay in the skill procedure.
- **Update:** `/update-recipes` — lock vs latest → agent does the semantic 3-way merge →
  PR, human reviews. Never auto-overwrite a repo's docs: the repo's copy is canonical *for
  that repo* (a repo may legitimately fork a rule — divergence is a doctor *flag*, resolved
  either as a local decision note or as an upstream contribution back to the recipe).
- **Security:** fully consistent with Copilot-sdk ADR-0051 — this is an **own** marketplace,
  pinned and source-reviewed; no third-party material. The Snyk numbers in RETROS 0007
  (13.4% of audited marketplace skills with critical issues) are an argument *for* owning
  this layer, not against it.
- **Host-agnosticism (sleeper benefit):** because recipes are docs + scripts, only the thin
  entry pointers are Claude-specific. `core` emits **both** CLAUDE.md and AGENTS.md pointing
  at the same `docs/` — the same process then steers Copilot, Cursor, or anything else that
  reads AGENTS.md. "Built on docs rather than code" literally buys agent portability.

## 7. Making the flows work on more models

This is a first-class requirement in the manifest, and Copilot-sdk already contains the
blueprint: the **subagent model-routing table** in CONVENTIONS (retrieval→cheap,
mechanical→mid, judgment→strong). Generalized:

- **Push determinism into scripts.** Every step moved from prose into a script
  (`start-fresh.sh`, `next-issue.sh`, `doctor.sh`) is a step a smaller model cannot get
  wrong. The get-next skill is the existence proof — its base-verification logic went from
  "tribal knowledge re-performed by hand" to a script with a testable failure mode.
- **Checklists with testable termination conditions** (the loop-engineering lens from
  ADR-0051) rather than narrative prose — weak models fail on ambiguity, not on length.
- **Ship runnable evals in each recipe dir** (the "≥3 evals before prose" rule) and run
  them per model tier. Record the result in the manifest as a `min_model` per step. That
  gives an honest answer to "can a mid-tier model run the whole dev loop here?" instead of
  a vibe — the certification that makes recipes trustworthy on cheaper models.

## 8. Recommended rollout

1. **Extract** (small): formalize `seed-project-infra` into `core` + `quality` — add
   manifest, lock, doctor. Trial on a brand-new empty repo (zero risk, perfect greenfield
   eval).
2. **Brownfield-harden:** adopt onto in-progress TS repos. This forces the language
   parametrization (Go→TS: Makefile→package.json scripts, lint/coverage tooling) and
   validates harvest mode — the hardest 30% of the system.
3. **Lifecycle recipes:** generalize `get-next` → `loop`, `tracking-issues` → `issues`,
   `cut-release` → `release`. These are the highest-value exports — already battle-debugged
   (Copilot-sdk RETROS 0003/0004 show the loop being fixed until it ran clean).
4. **Surface bindings + fleet:** only once ≥2 mini-repos actually share a contract —
   building the fleet layer before the constellation exists would violate the
   "marginal value over what exists" bar.
5. **Model certification evals** last — they need stable recipes to certify.

Main risks to watch: update-merge conflicts on heavily-diverged CONVENTIONS (mitigated by
PR + human review, never auto-apply), doc-mass creep on small repos (mitigated by tiers —
be ruthless about the S tier), and provenance ambiguity once a fact lives in both a recipe
template and a repo's doc (mitigated by the lock recording provenance and the doctor
flagging divergence instead of forbidding it).

---

*Prior art consulted:* Claude Code plugin/marketplace docs
(<https://code.claude.com/docs/en/discover-plugins>), `anthropics/claude-plugins-official`,
Copier vs Cookiecutter update semantics
(<https://dev.to/cloudnative_eng/copier-vs-cookiecutter-1jno>), Cruft vs Copier — template
updates at scale
(<https://www.blenddata.nl/en/blogs/cruft-vs-copier-automating-template-updates-at-scale>),
structkit vs cookiecutter vs copier
(<https://dev.to/structkit/structkit-vs-cookiecutter-vs-copier-which-project-scaffolding-tool-is-right-for-you-5gag>).
