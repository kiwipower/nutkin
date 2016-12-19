class Matcher {

    expected = null
    description = null

    constructor(expectedVal = null, matchDescription = "") {
        expected = expectedVal
        description = matchDescription
    }

    function isTable(x) {
        return typeof x == typeof {}
    }

    function isArray(x) {
        return typeof x == typeof []
    }

    function isString(x) {
        return typeof x == typeof ""
    }

    function prettify(x) {
        if (isArray(x)) {
            local array = "["
            local separator = ""
            foreach (e in x) {
                array += separator + prettify(e)
                separator = ", "
            }
            return array + "]"
        }
        if (isTable(x)) {
            local table = "{"
            local separator = ""
            foreach (k, v in x) {
                table += separator + k + ": " + prettify(v)
                separator = ", "
            }
            return table + "}"
        } else if (x == null) {
            return "(null)"
        } else if (isString(x)) {
            return "'" + x + "'"
        } else {
            return x
        }
    }

    function arraysEqual(a, b) {
        if (a.len() == b.len()) {
            foreach (i, value in a) {
                if (!equal(value, b[i])) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }

    function tablesEqual(a, b) {
        if (a.len() == b.len()) {
            foreach (key, value in a) {
                if (!(key in b)) {
                    return false
                } else if (!equal(value, b[key])) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }

    function equal(a, b) {
        if (isArray(a) && isArray(b)) {
            return arraysEqual(a, b)
        } else if (isTable(a) && isTable(b)) {
            return tablesEqual(a, b)
        } else {
            return a == b
        }
    }

    function contains(things, value) {
        if (isTable(value)) {
            local matcher = function(index, item) {
                return equal(value, item)
            }
            local filtered = things.filter(matcher.bindenv(this))

            return filtered.len() > 0
        }

        return things.find(value) != null
    }

    function test(actual) {
        return false
    }

    function negateIfRequired(text, isNegated) {
        local negatedText = isNegated ? "not " : ""
        return negatedText + text
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be " + prettify(expected), isNegated)
    }
}

class EqualsMatcher extends Matcher {

    function test(actual) {
        return equal(actual, expected)
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to equal " + prettify(expected), isNegated)
    }
}

class TruthyMatcher extends Matcher {

    function test(actual) {
        return actual
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be truthy", isNegated)
    }
}

class FalsyMatcher extends Matcher {

    function test(actual) {
        return !actual
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be falsy", isNegated)
    }
}

class ContainsMatcher extends Matcher {

    function test(actual) {
        return contains(actual, expected)
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to contain " + prettify(expected), isNegated)
    }
}

class RegexpMatcher extends Matcher {

    function test(actual) {
        return regexp(expected).match(actual)
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to match: " + expected, isNegated)
    }
}

class LessThanMatcher extends Matcher {

    function test(actual) {
        return actual < expected
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be less than " + prettify(expected), isNegated)
    }
}

class GreaterThanMatcher extends Matcher {

    function test(actual) {
        return actual > expected
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be greater than " + prettify(expected), isNegated)
    }
}

class TypeMatcher extends Matcher {

    function test(actual) {
        return typeof actual == expected
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be of type " + expected, isNegated)
    }
}

class NumberMatcher extends Matcher {

    function test(actual) {
        return typeof actual == "integer" || typeof actual == "float"
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be a number", isNegated)
    }
}

class ThrowsMatcher extends Matcher {

    function test(actual) {
        try {
            actual()
        } catch (error) {
            if (error == expected) {
                return true
            }
        }
        return false
    }

    function failureMessage(actual, isNegated) {
        if (isNegated) {
            return "Expected no exception but caught " + error
        }
        return "Expected " + expected + " but caught " + error
    }
}