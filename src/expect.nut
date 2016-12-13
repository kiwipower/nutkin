class Expectation {
    actual = null
    to = null
    be = null

    constructor(actualValue) {
        actual = actualValue
        to = this
        be = this
    }

    function _isTable(x) {
        return typeof x == typeof {}
    }

    function _isArray(x) {
        return typeof x == typeof []
    }

    function _prettify(x) {
        if (_isArray(x)) {
            local array = "["
            local separator = ""
            foreach (e in x) {
                array += separator + _prettify(e)
                separator = ", "
            }
            return array + "]"
        }
        if (_isTable(x)) {
            local table = "{"
            local separator = ""
            foreach (k, v in x) {
                table += separator + k + ": " + _prettify(v)
                separator = ", "
            }
            return table + "}"
        } else if (x == null) {
            return "(null)"
        } else {
            return x
        }
    }

    function _arraysEqual(a, b) {
        if (a.len() == b.len()) {
            foreach (i, value in a) {
                if (!_equal(value, b[i])) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }

    function _tablesEqual(a, b) {
        if (a.len() == b.len()) {
            foreach (key, value in a) {
                if (!(key in b)) {
                    return false
                } else if (!_equal(value, b[key])) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }

    function _equal(a, b) {
        if (_isArray(a) && _isArray(b)) {
            return _arraysEqual(a, b)
        } else if (_isTable(a) && _isTable(b)) {
            return _tablesEqual(a, b)
        } else {
            return a == b
        }
    }

    function _contains(value) {
        if (_isTable(value)) {
            local matcher = function(index, item) {
                return _equal(value, item)
            }
            local filtered = actual.filter(matcher.bindenv(this))

            return filtered.len() > 0
        }

        return actual.find(value) != null
    }

    function equal(expected, description = "") {
        if (!_equal(actual, expected)) {
            throw Failure("Expected '" + _prettify(actual) + "' to equal " + _prettify(expected), description)
        }
    }

    function truthy(description = "") {
        if (!actual) {
            throw Failure("Expected " + _prettify(actual) + " to be truthy", description)
        }
    }

    function falsy(description = "") {
        if (actual) {
            throw Failure("Expected " + _prettify(actual) + " to be falsy", description)
        }
    }

    function contain(value, description = "") {
        if (!_contains(value)) {
            throw Failure("Expected " + _prettify(actual) + " to contain " + _prettify(value), description)
        }
    }

    function contains(value, description = "") {
        return contain(value, description)
    }

    function match(expression, description = "") {
        if (!regexp(expression).match(actual)) {
            throw Failure("Expected '" + _prettify(actual) + "' to match: " + expression, description)
        }
    }

    function matches(expression, description = "") {
        return match(expression, description)
    }

    function lessThan(value, description = "") {
        if (actual > value) {
            throw Failure("Expected " + _prettify(actual) + " to be less than " + _prettify(value), description)
        }
    }

    function greaterThan(value, description = "") {
        if (actual < value) {
            throw Failure("Expected " + _prettify(actual) + " to be greater than " + _prettify(value), description)
        }
    }

    function throws(expected, description = "") {
        try {
            actual()
        } catch (error) {
            if (error == expected) {
                return
            } else {
                throw Failure("Expected " + expected + " but caught " + error, description)
            }
        }
        throw Failure("Expected exception to have been thrown but wasn't: " + expected, description)
    }

    function toThrow(expected, description = "") {
        return throws(expected, description)
    }

    // SquirrelJasmine compatability functions

    function toBe(expected, description = "") {
        return equal(expected, description)
    }

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

    constructor(actualValue) {
        base.constructor(actualValue);
    }

    function equal(expected, description = "") {
        if (_equal(actual, expected)) {
            throw Failure("Expected " + _prettify(actual) + " not to equal " + _prettify(expected), description)
        }
    }

    function truthy(description = "") {
        if (actual) {
            throw Failure("Expected " + _prettify(actual) + " to not be truthy", description)
        }
    }

    function falsy(description = "") {
        if (!actual) {
            throw Failure("Expected " + _prettify(actual) + " to not be falsy", description)
        }
    }

    function contain(value, description = "") {
        if (_contains(value)) {
            throw Failure("Expected " + _prettify(actual) + " not to contain " + _prettify(value), description)
        }
    }

    function match(expression, description = "") {
        if (regexp(expression).match(actual)) {
            throw Failure("Expected '" + _prettify(actual) + "' not to match: " + expression, description)
        }
    }

    function lessThan(value, description = "") {
        if (actual <= value) {
            throw Failure("Expected " + _prettify(actual) + " not to be less than " + _prettify(value), description)
        }
    }

    function greaterThan(value, description = "") {
        if (actual >= value) {
            throw Failure("Expected " + _prettify(actual) + " not to be greater than " + _prettify(value), description)
        }
    }

    function throws(expected, description = "") {
        try {
            actual()
        } catch (error) {
            if (error != expected) {
                return
            } else {
                throw Failure("Expected " + expected + " not to have been thrown but was", description)
            }
        }
    }
}

class expect extends Expectation {
    not = null

    constructor(actualValue) {
        base.constructor(actualValue);
        not = NegatedExpectation(actualValue)
    }
}

function expectException(expected, func) {
    return expect(func).throws(expected)
}
