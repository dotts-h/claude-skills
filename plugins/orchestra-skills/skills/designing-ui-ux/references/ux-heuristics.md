# UX audit: heuristics + severity

Evaluate real flows, not static screens. For each issue, record: location, the heuristic it breaks,
a severity, and a concrete fix. Severity is what turns a list into a plan.

## Severity scale (Nielsen)
- **0** not a problem · **1** cosmetic (fix if time) · **2** minor · **3** major (fix soon) ·
- **4** catastrophic (fix before release). Rank fixes by severity × frequency of the flow.

## Nielsen's 10 heuristics (what to check here)
1. **Visibility of system status** — is the app always showing what it's doing? (streaming, thinking,
   queued, aborting). This app's statusline/elapsed timer/context meter are this heuristic — keep them honest.
2. **Match to the real world** — labels in the user's language ("context", not "ctx").
3. **User control & freedom** — clear exits/undo (abort a turn, cancel a queued prompt, clear chat).
4. **Consistency & standards** — same action looks/behaves the same everywhere.
5. **Error prevention** — stop mistakes before they happen (confirm destructive actions, validate forms inline).
6. **Recognition over recall** — show options (slash-command autocomplete) rather than make users remember.
7. **Flexibility & efficiency** — shortcuts for power users without confusing newcomers.
8. **Aesthetic & minimalist design** — every element earns its place; remove noise.
9. **Help users recover from errors** — plain-language errors with a way forward (the surfaced EvError).
10. **Help & documentation** — discoverable help (the /help page) when needed.

## Krug's "don't make me think"
- Self-evident first; self-explanatory second; nothing requiring a manual.
- Reduce the number of choices and the effort per choice. Cut words ruthlessly.
- Make clickable things obviously clickable; make the primary action obvious.

## Output
A severity-ranked findings list. The high-severity items on high-frequency flows (send, approve,
switch model) are the ones to implement first.
