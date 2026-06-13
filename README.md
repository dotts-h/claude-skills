# ori — my Claude Code marketplace

**[Documentation →](https://dotts-h.github.io/claude-skills/)**

`ori` is my personal Claude Code plugin marketplace (served from this repo), so my
tooling is available everywhere — including Claude Code on the web/phone (cloud
sessions install declared plugins at session start). It hosts **two** plugins:

| Plugin | Install id | What it is |
|--------|-----------|------------|
| **`skills`** | `skills@ori` | 13 reusable methodology skills (docs, process, QA, design). |
| **`cookbook`** | `cookbook@ori` | Recipe system: install versioned doc-based engineering-process packages into any repo, update via a lock + 3-way merge, check conformance with doctors. |

## Use it in a repo (and from the phone)

Add to the repo's committed `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "ori": { "source": { "source": "github", "repo": "dotts-h/claude-skills" } }
  },
  "enabledPlugins": ["skills@ori", "cookbook@ori"]
}
```

Commit + push. Any cloud session for that repo installs the plugins automatically at
session start (GitHub is in the default network allowlist). Locally you can also add
them interactively:

```
/plugin marketplace add dotts-h/claude-skills
/plugin install skills@ori
/plugin install cookbook@ori
```

## The `skills` plugin

13 methodology skills, bundled:

| Group | Skills |
|-------|--------|
| Docs | `recording-decisions` · `registering-contracts` · `maintaining-conventions` · `logging-learnings` · `mapping-codebases` |
| Process | `practicing-tdd` · `managing-tech-debt` · `improving-architecture` · `auditing-code-quality` |
| QA | `hardening-tests` · `authoring-tests` · `exploring-quality` |
| Design | `designing-ui-ux` |

## The `cookbook` plugin

**Installable, versioned, doc-based engineering process packages.** A *recipe*
turns a hard-won process (a constitution, quality gates, an issue store, a dev
loop, a release ritual, a contracts registry) into something you install into a
repo, keep updated, and conformance-check — the way a package manager treats code.

| thing | lives where | lifetime | who benefits |
|-------|-------------|----------|--------------|
| **plugin / skill** | the agent host | per-session context; leaves **no trace** in the repo | the agent that loaded it |
| **recipe** | the target repo (docs, scripts, CI, `.recipes/lock.json`) | **durable state**, versioned + updatable | *any* agent (or human) that opens the repo, on any host |

Skills here are the *operators*; recipes are the *payload*. A repo that adopted
recipes works with no plugin installed at all — the docs and scripts are just there,
host-agnostic (both `CLAUDE.md` and `AGENTS.md` thin pointers).

### Quickstart

```text
# In the repo you want to bring under management (with cookbook@ori enabled)
/adopt-recipes
```

`adopt-recipes` inventories the repo, proposes a profile + tier + answers, confirms
with you, installs in dependency order (harvesting existing docs on brownfield —
never clobbering), writes `.recipes/lock.json`, and reports gaps. Later:
`/update-recipes` (semantic 3-way merge to new versions, via PR) and `/recipe-doctor`
(aggregate conformance report).

Without the plugin, everything is runnable by hand:

```bash
make evals                       # run all recipe evals (fixture repos in mktemp)
make lint                        # bash -n all scripts + secret/date scans
make doctor TARGET=/path/to/repo # aggregate doctors against a repo
plugins/cookbook/scripts/install-recipe.sh \
  --recipe plugins/cookbook/recipes/core --target /path/to/repo --tier M
```

### Catalog

| recipe | layer | what it installs |
|--------|-------|------------------|
| `core` | 0 | CLAUDE.md + AGENTS.md thin pointers, CONVENTIONS constitution (doctrine), CONTEXT glossary; ADR log (M+); CODEMAP/RETROS/TECH_DEBT (L) |
| `quality` | 1 | single-run CI (make/npm flavors) with docs-only `paths-ignore` skip, the self-enforcing workflow guard, coverage-floor parameter, opt-in fuzz-smoke workflow, REGRESSIONS register (M+) |
| `loop` | 1 | the dev loop playbook + `start-fresh.sh` (verified base) + `next-issue.sh` (dependency-aware picker) |
| `issues` | 1 | hybrid issue store: markdown source of truth + GitHub mirror; INDEX + frontmatter format; epics via `group:` |
| `release` | 1 | tag-driven release workflow with verified version resolution; SemVer + verify-after playbook |
| `contracts` | 1 | CONTRACTS registry with Provides/Consumes; fleet `constellation.yaml` + `fleet-doctor.sh` cross-check |

**Bindings** (Layer 2, adapter docs — not recipes): `frontend`, `api`, `qa`,
`services` — each fills the slots Layers 0/1 leave open for that repo shape.

**Profiles** (recipes × tier × bindings × prefilled answers): `app-full`,
`library`, `mini-api`, `mini-fe-components`, `mini-functions`, `greenfield-lean`.

**Tiers:** **S** (mini repo: ~4 lean files, decisions inline in CONVENTIONS) ·
**M** (+ ADR log, REGRESSIONS, issues store, loop) · **L** (+ CODEMAP wiring,
RETROS, TECH_DEBT).

### Cookbook docs

- [docs/recipes/SPEC.md](docs/recipes/SPEC.md) — exact schemas: `recipe.yaml`,
  `lock.json`, profiles, `constellation.yaml`, the doctor exit-code contract,
  `min_model`.
- [docs/recipes/DESIGN.md](docs/recipes/DESIGN.md) — why it's built this way.
- [docs/recipes/RESEARCH.md](docs/recipes/RESEARCH.md) — the original deep-dive
  research notes that governed the design.

## Layout

```
.claude-plugin/marketplace.json          # the ori catalog (both plugins)
plugins/skills/
  .claude-plugin/plugin.json             # the skills plugin manifest
  skills/<skill>/SKILL.md                # one dir per skill (+ references/, scripts/)
plugins/cookbook/
  .claude-plugin/plugin.json             # the cookbook plugin manifest
  skills/<skill>/SKILL.md                # adopt-recipes, update-recipes, recipe-doctor
  recipes/<recipe>/                      # recipe.yaml + templates + evals + doctor
  profiles/  bindings/  scripts/
Makefile                                 # cookbook recipe gates: make lint / make evals
```

## CI

`.github/workflows/ci.yml` runs the cookbook recipe gates on every push/PR:
`make lint` (bash -n + secret/date scans) and `make evals` (every recipe's evals in
mktemp fixtures; needs bash + python3 + git).
