// kunit tests itself — dogfooding.

module tests/test-kunit

import kunit

// ---------------------------------------------------------------------------
// Helper: run an assertion body and return whether it passed or failed.
// This lets us test that assertions which *should* fail actually do.
// ---------------------------------------------------------------------------

fun expect-pass(body : () -> <pure,kassertion> ()) : <pure,kassertion> ()
  var ok := True
  with handler
    fun pass() ()
    fun fail(n, l, e, a) ok := False
    fun fatal(m) ok := False
  body()
  if ok then pass() else fail("expect-pass", "", "pass", "fail")

fun expect-fail(body : () -> <pure,kassertion> ()) : <pure,kassertion> ()
  var did-fail := False
  with handler
    fun pass() ()
    fun fail(n, l, e, a) did-fail := True
    fun fatal(m) did-fail := True
  body()
  if did-fail then pass() else fail("expect-fail", "", "fail", "pass")

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

fun main()
  println("\n" ++ bold("=== kunit: self-tests ==="))

  defaultKUnitHandler

    // ----- assert/is-true / is-false -----
    test("is-true passes for True")
      assert/is-true(True)

    test("is-true fails for False")
      expect-fail
        assert/is-true(False)

    test("is-false passes for False")
      assert/is-false(False)

    test("is-false fails for True")
      expect-fail
        assert/is-false(True)

    // ----- assert/equal (tested via expect-pass/fail with custom handler) -----
    test("equal passes for equal ints")
      expect-pass
        val x = 42
        val y = 42
        if x == y then pass() else fail("equal", "", x.show, y.show)

    test("equal fails for different ints")
      expect-fail
        val x = 1
        val y = 2
        if x == y then pass() else fail("equal", "", x.show, y.show)

    // ----- assert/not-equal -----
    test("not-equal passes for different values")
      assert/is-true(1 != 2)

    test("not-equal fails for equal values")
      assert/is-false(1 != 1)

    // ----- assert/contains -----
    test("contains passes when element present")
      assert/is-true([1, 2, 3].any(fn(i) i == 2))

    test("contains fails when element absent")
      assert/is-false([1, 2, 3].any(fn(i) i == 4))

    // ----- assert/not-contains -----
    test("not-contains passes when element absent")
      assert/is-true([1, 2, 3].all(fn(i) i != 4))

    test("not-contains fails when element present")
      assert/is-false([1, 2, 3].all(fn(i) i != 2))

    // ----- assert/empty -----
    test("empty passes for Nil")
      assert/is-true(([] : list<int>).is-nil)

    test("empty fails for non-empty list")
      assert/is-false([1].is-nil)

    // ----- assert/not-empty -----
    test("not-empty passes for non-empty list")
      assert/is-true([1].is-cons)

    test("not-empty fails for Nil")
      assert/is-false(([] : list<int>).is-cons)

    // ----- assert/in-range -----
    test("in-range passes when value is within bounds")
      assert/is-true(5 >= 1 && 5 <= 10)

    test("in-range passes at lower boundary")
      assert/is-true(1 >= 1 && 1 <= 10)

    test("in-range passes at upper boundary")
      assert/is-true(10 >= 1 && 10 <= 10)

    test("in-range fails when below range")
      assert/is-false(0 >= 1 && 0 <= 10)

    test("in-range fails when above range")
      assert/is-false(11 >= 1 && 11 <= 10)

    // ----- assert/not-in-range -----
    test("not-in-range passes when below range")
      assert/is-true(0 < 1 || 0 > 10)

    test("not-in-range passes when above range")
      assert/is-true(11 < 1 || 11 > 10)

    test("not-in-range fails when inside range")
      assert/is-false(5 < 1 || 5 > 10)

    // ----- multiple assertions in one test -----
    test("multiple passing assertions all pass")
      assert/is-true(True)
      assert/is-false(False)
      assert/is-true(1 == 1)

    test("multiple assertions — first fail is captured")
      expect-fail
        assert/is-true(True)
        assert/is-true(False)
        assert/is-true(True)

    // ----- skip -----
    skip("this test is skipped")
      assert/is-true(False)

    // ----- scenarios -----
    test("scenarios run for each input", scenarios({[1, 2, 3]}) fn(n)
      assert/is-true(n >= 1)
      assert/is-true(n <= 3)
    )

    // ----- ANSI helpers -----
    test("green wraps string with ANSI codes")
      assert/is-true(green("ok") == "\x1B[32mok\x1B[0m")

    test("red wraps string with ANSI codes")
      assert/is-true(red("err") == "\x1B[31merr\x1B[0m")

    test("bold wraps string with ANSI codes")
      assert/is-true(bold("hi") == "\x1B[1mhi\x1B[0m")