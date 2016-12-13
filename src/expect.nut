class Expectation {
    actual = null
    to = null
    be = null

    constructor(actualValue) {
        actual = actualValue
        to = this
        be = this
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
        } if (_isTable(x)) {
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

    function _isTable(x) {
        return typeof x == typeof {}
    }

    function _isArray(x) {
        return typeof x == typeof []
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

    function toBe(expected, description = "") {
        return equal(expected, description)
    }

    function equal(expected, description = "") {
        if (!_equal(actual, expected)) {
            throw Failure("Expected " + _prettify(actual) + " to equal " + _prettify(expected), description)
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
}

class expect extends Expectation {
    not = null

    constructor(actualValue) {
        base.constructor(actualValue);
        not = NegatedExpectation(actualValue)
    }
}
