# Learnings log — registers & templates

Three registers in one file. Keep them as tables/sections so they stay skimmable.

## 1. Fixed (bugs with guards)
The rule: **every entry names the test that now guards it.**

```markdown
| # | Symptom (what was observed) | Root cause | Fix | Guarding test(s) |
|---|------------------------------|-----------|-----|------------------|
| 1 | "Thinking" rendered twice    | full block re-appended after deltas | drop dup full block, clear flag on idle | unit: copilot TestHandlerDropsDuplicateReasoningBlock |
```

## 2. Dead-ends (what not to retry)
```markdown
### Client-side reducer (rejected)
- **Tried:** duplicate the transcript reducer in JS so the browser owns render state.
- **Why it failed:** forces a JSON API + build chain and duplicates the unit-tested
  Go reducer — net loss for a single-user localhost tool.
- **Instead:** server owns all state; UI is a pure SSE-fragment projection (htmx).
```
Pair every dead-end with an **Instead**. A dead-end without an exit is just a ban.

## 3. Gotchas (things that bit us)
```markdown
- The demo is one shared in-memory session: per-session counters accumulate across
  the whole suite, so browser assertions must be relative (read → act → assert >),
  never a fixed value.
```

## Known gaps (fixed behavior, not yet guarded)
List any fix whose guard doesn't exist yet, so the absence is *visible*:
```markdown
- Markdown rendering — deferred (not built). No guard yet.
```
Move an item out of "Known gaps" the moment its guard test lands.
