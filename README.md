# kunit

A lightweight xUnit-style test framework for [Koka](https://koka-lang.github.io/), inspired by [KUnit](https://github.com/koka-community/kunit).

## Features

- **Unit tests** — pure test bodies via the `kunit` effect (`test`, `skip`)
- **Divergent tests** — for recursive code (parsers, tree walkers) via the `kdiv` effect (`dtest`, `dskip`)
- **Integration tests** — IO-capable test bodies via the `kintegration` effect (`itest`, `iskip`)
- **Rich assertions** — `equal`, `not-equal`, `is-true`, `is-false`, `contains`, `not-contains`, `empty`, `not-empty`, `in-range`, `not-in-range`
- **Scenarios** — data-driven tests with automatic input display
- **Coloured output** — green/red/yellow ANSI results with pass/fail/skip summary
- **Non-zero exit** — exits with code 1 on failure for CI integration

## Setup

Add kunit as a git submodule in your project:

```sh
git submodule add https://github.com/cladam/kunit.git lib/kunit
```

Then compile with `-i` pointing at the submodule:

```sh
koka -ilib/kunit tests/my-tests.kk
```

To update kunit later:

```sh
git submodule update --remote lib/kunit
```

## Usage

Import the top-level `kunit` module, which re-exports everything:

```koka
import kunit

fun main()
  defaultKUnitHandler
    test("addition")
      assert/equal(4, 2 + 2)

    test("list contains element")
      assert/contains([1, 2, 3], 2)

    skip("not implemented yet")
      assert/is-true(False)
```

### Assertions

```koka
// Equality
assert/equal(expected, actual)
assert/not-equal(expected, actual)

// Boolean
assert/is-true(value)
assert/is-false(value)

// Collections
assert/contains(list, element)
assert/not-contains(list, element)
assert/empty(list)
assert/not-empty(list)

// Numeric ranges
assert/in-range(actual, low, high)
assert/not-in-range(actual, low, high)
```

### Scenarios (data-driven tests)

```koka
test("double is correct", scenarios({[1, 2, 3]}) fn(n)
  assert/equal(n * 2, double(n))
)
```

### Test kinds

Use the handler that matches your test's effect requirements:

| Handler                      | Effect          | Use case                                     |
|------------------------------|-----------------|----------------------------------------------|
| `defaultKUnitHandler`        | `kunit`         | Pure tests (default)                         |
| `defaultKDivHandler`         | `kdiv`          | Recursive / potentially divergent code       |
| `defaultKIntegrationHandler` | `kintegration`  | Tests that need IO (files, network, etc.)    |

## License

MIT — see [LICENSE](LICENSE) for details.
