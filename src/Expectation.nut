class Expectation {
    actual = null
    to = null
    be = null
    been = null
    a = null
    has = null
    have = null
    with = null
    that = null
    which = null
    and = null
    of = null
    is = null

    constructor(actualValue) {
        actual = actualValue
        to = this
        be = this
        been = this
        a = this
        has = this
        have = this
        with = this
        that = this
        which = this
        and = this
        of = this
        is = this
    }

    function isString(x) {
        return typeof x == typeof ""
    }

    function execMatcher(matcher) {
        if (!matcher.test(actual)) {
            throw Failure(matcher.failureMessage(actual, false), matcher.description)
        }
    }

    function equal(expected, description = "") {
        return execMatcher(EqualsMatcher(expected, description))
    }

    function truthy(description = "") {
        return execMatcher(TruthyMatcher(null, description))
    }

    function falsy(description = "") {
        return execMatcher(FalsyMatcher(null, description))
    }

    function contain(expected, description = "") {
        return execMatcher(ContainsMatcher(expected, description))
    }

    function contains(value, description = "") {
        return contain(value, description)
    }

    function match(expression, description = "") {
        return execMatcher(RegexpMatcher(expression, description))
    }

    function matches(expression, description = "") {
        return match(expression, description)
    }

    function lessThan(value, description = "") {
        return execMatcher(LessThanMatcher(value, description))
    }

    function greaterThan(value, description = "") {
        return execMatcher(GreaterThanMatcher(value, description))
    }

    function throws(exception, description = "") {
        return execMatcher(ThrowsMatcher(exception, description))
    }

    function toThrow(expected, description = "") {
        return throws(expected, description)
    }

    function number(description = "") {
        return execMatcher(NumberMatcher(null, description))
    }

    function ofType(type, description = "") {
        return execMatcher(TypeMatcher(type, description))
    }

    function ofClass(clazz, description = "") {
        return execMatcher(InstanceOfMatcher(clazz, description))
    }

    function closeTo(value, precision = 1, description = "") {
        return execMatcher(CloseToMatcher(value, precision, description))
    }

    function beCloseTo(value, precision = 1, description = "") {
        return closeTo(value, precision, description)
    }

    function toBe(expectedOrMatcher, description = "") {
        if (typeof expectedOrMatcher == "instance") {
            // Custom matcher
            return execMatcher(expectedOrMatcher)
        } else {
            // SquirrelJasmine compatability function
            return equal(expectedOrMatcher, description)
        }
    }

    // SquirrelJasmine compatability functions

    function toBeTruthy() {
        return truthy()
    }

    function toBeFalsy() {
        return falsy()
    }

    function toBeNull() {
        return equal(null)
    }

    function toContain(value) {
        return contain(value)
    }

    function toMatch(regex) {
        return match(regex)
    }

    function toBeLessThan(value) {
        return lessThan(value)
    }

    function toBeGreaterThan(value) {
        return greaterThan(value)
    }

    function toBeCloseTo(value, precision = 1) {
        return closeTo(value, precision)
    }
}

class NegatedExpectation extends Expectation {

    function execMatcher(matcher) {
        if (matcher.test(actual)) {
            throw Failure(matcher.failureMessage(actual, true), matcher.description)
        }
    }
}

class expect extends Expectation {
    not = null

    constructor(expectedValue) {
        base.constructor(expectedValue)
        not = NegatedExpectation(expectedValue)
    }
}

// SquirrelJasmine compatability function
function expectException(exception, func) {
    return expect(func).throws(exception)
}
