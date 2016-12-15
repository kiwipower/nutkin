class Expectation {
    actual = null
    to = null
    be = null

    constructor(actualValue) {
        actual = actualValue
        to = this
        be = this
    }

    function isString(x) {
        return typeof x == typeof ""
    }

    function is(matcher) {
        if (!matcher.test(actual)) {
            throw Failure(matcher.failureMessage(actual, false), matcher.description)
        }
    }

    function equal(expected, description = "") {
        return is(EqualsMatcher(expected, description))
    }

    function truthy(description = "") {
        return is(TruthyMatcher(null, description))
    }

    function falsy(description = "") {
        return is(FalsyMatcher(null, description))
    }

    function contain(expected, description = "") {
        return is(ContainsMatcher(expected, description))
    }

    function contains(value, description = "") {
        return contain(value, description)
    }

    function match(expression, description = "") {
        return is(RegexpMatcher(expression, description))
    }

    function matches(expression, description = "") {
        return match(expression, description)
    }

    function lessThan(value, description = "") {
        return is(LessThanMatcher(value, description))
    }

    function greaterThan(value, description = "") {
        return is(GreaterThanMatcher(value, description))
    }

    function throws(exception, description = "") {
        return is(ThrowsMatcher(exception, description))
    }

    function toThrow(expected, description = "") {
        return throws(expected, description)
    }

    function toBe(expectedOrMatcher, description = "") {
        if (typeof expectedOrMatcher == "instance") {
            // Custom matcher
            return is(expectedOrMatcher)
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
}

class NegatedExpectation extends Expectation {

    function is(matcher) {
        if (matcher.test(actual)) {
            throw Failure(matcher.failureMessage(actual, true), matcher.description)
        }
    }
}

class expect extends Expectation {
    not = null

    constructor(expectedValue) {
        base.constructor(expectedValue);
        not = NegatedExpectation(expectedValue)
    }
}

// SquirrelJasmine compatability function
function expectException(exception, func) {
    return expect(func).throws(exception)
}
