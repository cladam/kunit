# kunit improvement notes

## Implicit parameter resolution in test bodies

When using `assert/equal` or `assert/contains` inside `test`, `dtest`, or `itest` bodies,
Koka's implicit parameter resolution fails to find `?eq` and `?show` for common types
like `string`, `int`, `list<string>`, and `maybe<string>`.

This is because the test body effect rows (`<pure,kassertion,kscenario>`,
`<div,exn,console,kassertion,kscenario>`, etc.) prevent the compiler from resolving
the implicit parameters automatically.

### Workaround

Use `assert/is-true` with explicit comparisons instead:

```koka
// This fails to compile:
assert/equal("expected", actual-string)
assert/equal(42, actual-int)
assert/contains(string-list, "needle")

// This works:
assert/is-true(actual-string == "expected")
assert/is-true(actual-int == 42)
assert/is-true(string-list.any(fn(s) s == "needle"))
```

### Possible fix: concrete overloads

Add type-specific assertion functions that don't rely on implicit resolution:

```koka
pub fun assert/equal-string(expected: string, actual: string, ?kk-file-line: string): <pure,kassertion> ()
  if expected == actual then pass()
  else fail("assert/equal-string", kk-file-line, expected, actual)

pub fun assert/equal-int(expected: int, actual: int, ?kk-file-line: string): <pure,kassertion> ()
  if expected == actual then pass()
  else fail("assert/equal-int", kk-file-line, expected.show, actual.show)

pub fun assert/contains-string(collection: list<string>, expected: string, ?kk-file-line: string): <pure,kassertion> ()
  if collection.any(fn(s) s == expected) then pass()
  else fail("assert/contains-string", kk-file-line,
    "collection to contain " ++ expected,
    collection.join(", "))
```

This preserves kunit's structured error reporting (file/line, expected vs actual)
while avoiding the implicit resolution issue.

## Test function naming

The current names `test`, `dtest`, and `itest` are cryptic — the prefix doesn't
communicate what kind of test body each one expects.

### Current names and what they mean

| Function | Effect | Handler | Use case |
|----------|--------|---------|----------|
| `test` / `skip` | `<pure,kassertion,kscenario>` | `defaultKUnitHandler` | Pure unit tests |
| `dtest` / `dskip` | `<div,exn,console,kassertion,kscenario>` | `defaultKDivHandler` | Recursive/divergent code (parsers, tree walkers) |
| `itest` / `iskip` | `<io,kassertion,kscenario>` | `defaultKIntegrationHandler` | Side-effectful integration tests |

### Proposed renames

| Current | Terse alternative | Verbose alternative |
|---------|-------------------|---------------------|
| `test`  | `test` (keep) | `unit` |
| `dtest` | `div-test` | `divergent` |
| `itest` | `io-test` | `integration` |
| `skip`  | `skip` (keep) | `unit-skip` |
| `dskip` | `div-skip` | `divergent-skip` |
| `iskip` | `io-skip` | `integration-skip` |

Koka libraries tend toward terse names, so `div-test`/`io-test` may fit better
than the fully spelled-out versions.

Note: renaming is a breaking change for any consumers (e.g. klap's tests).
Coordinate with a major version bump if proceeding.

## Root cause verification for implicit parameters

The doc above attributes the implicit resolution failure to effect rows in test
bodies. This should be verified — it may be that Koka v3.2.3 simply doesn't
resolve `?eq`/`?show` for built-in types regardless of effects.

Test `assert/equal(1, 1)` outside a `test` body (under a plain `kassertion`
handler with no `kunit` effect) to confirm whether the issue is effect-related
or a general limitation of implicit resolution in this Koka version.

