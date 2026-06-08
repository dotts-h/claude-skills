# orchestra — Claude Code skills marketplace

**[Documentation →](https://dotts-h.github.io/claude-skills/)**

A plugin marketplace distributing the methodology skills built for the *my-orchestra*
project, so they're available everywhere — including Claude Code on the web/phone
(cloud sessions install declared plugins at session start).

## What's here

One plugin, **`orchestra-skills`**, bundling 13 skills:

| Group | Skills |
|-------|--------|
| Docs | `recording-decisions` · `registering-contracts` · `maintaining-conventions` · `logging-learnings` · `mapping-codebases` |
| Process | `practicing-tdd` · `managing-tech-debt` · `improving-architecture` · `auditing-code-quality` |
| QA | `hardening-tests` · `authoring-tests` · `exploring-quality` |
| Design | `designing-ui-ux` |

## Use it in a repo (and from the phone)

Add to the repo's committed `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "orchestra": { "source": { "source": "github", "repo": "dotts-h/claude-skills" } }
  },
  "enabledPlugins": ["orchestra-skills@orchestra"]
}
```

Commit + push. Any cloud session for that repo installs the plugin automatically at
session start (GitHub is in the default network allowlist). Locally you can also add
it interactively:

```
/plugin marketplace add dotts-h/claude-skills
/plugin install orchestra-skills@orchestra
```

## Layout

```
.claude-plugin/marketplace.json          # the catalog
plugins/orchestra-skills/
  .claude-plugin/plugin.json             # the plugin manifest
  skills/<skill>/SKILL.md                # one dir per skill (+ references/, scripts/)
```
