# Red → Green → Refactor

The rhythm, and the judgment behind each beat.

## Red
Write the smallest test that *fails because the behavior is missing*. Run it. If it
passes, your test isn't testing what you think (or the behavior already exists). If it
fails on a compile error or typo, fix that until it fails on the assertion — only then
is it a real red.

## Green
Write the *minimum* to pass — even something slightly naive. The discipline is to not
build ahead of a test. If you find yourself wanting to write more code than the test
demands, that's a signal to write another test first.

## Refactor
Now that the behavior is pinned, clean it up — names, duplication, structure — with the
test green the whole time. This is where design quality comes from; the green test is
your safety net. Hand deeper structural cleanup to `auditing-code-quality`/`improving-architecture`.

## Table-driven tests (the default for edge cases)
```go
tests := []struct{ name, in string; want int }{
    {"empty", "", 0},
    {"unknown model", "frobnicate", fallbackRate},
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) { /* assert */ })
}
```
Each row is a documented expectation; adding the next edge case is one line. When a bug
is found, the fix is "add the row that reproduces it, then make it pass".

## Small steps
Keep diffs small — one behavior per red-green cycle. Small steps make failures point at
exactly what you just changed, which is the whole speed advantage of TDD.
