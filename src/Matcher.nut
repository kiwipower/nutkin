@include once "src/NutkinPrettyPrinter.class.nut";

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
        if (isArray(x) || isTable(x)) {
           return NutkinPrettyPrinter().format(x);
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
        if (isTable(things)) {
            return (value in things);
        }

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

class CloseToMatcher extends Matcher {

    precision = null

    constructor(expectedVal = null, precisionInDps = 1, matchDescription = "") {
        base.constructor(expectedVal, matchDescription)
        precision = precisionInDps
    }

    function round(val, decimalPoints) {
        local f = pow(10, decimalPoints) * 1.0;
        local newVal = val * f;
        newVal = (val >= 0) ? floor(newVal) : ceil(newVal)
        return newVal;
    }

    function test(actual) {
        return round(expected, precision) == round(actual, precision)
    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(actual) + negateIfRequired(" to be close to " + expected, isNegated)
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

class InstanceOfMatcher extends Matcher {

    function test(actual) {
        return actual instanceof expected
    }

    function failureMessage(actual, isNegated) {
        return "Expected instance" + negateIfRequired(" to be an instance of specified class", isNegated)
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


/// This class implements a Matcher which compares the contents of two tables or arrays
/// It considers them to match if the contents are the same, regardless of ordering of the arrays
/// This is useful if you're generating arrays but don't care about the order (eg if they're generated from a foreach over a table)
class UnorderedObjectMatcher extends Matcher {

    _sortedExpected = null;
    _sortedActual = null;

    /// Sorts an object (array or table) recursively depth first based on the JSON representation of the members of the array
    /// \param obj The object (array or table) to be sorted. Any other type is ignored.
    function _sortObject(obj) {
        if (typeof(obj) == "table")
        {
            foreach (key, value in obj) {
                _sortObject(value);
            }
        } else if (typeof(obj) == "array") {
            foreach (entry in obj) {
                _sortObject(entry);
            }
            obj.sort( function( first, second ) {
                // We need to sort potentially any kind of data
                // So we convert it to JSON and then sort
                local jsonFirst = NutkinPrettyPrinter().format(first);
                local jsonSecond = NutkinPrettyPrinter().format(second);

                // Very crude - loop through the first JSON looking for differences with the second JSON
                // This algorithm just needs to be consistent, not sorted by any particular criteria
                foreach (index, ch in jsonFirst) {
                    if ((jsonSecond.len() > index) && (ch != jsonSecond[index])) {
                        return (ch <=> jsonSecond[index]);
                    }
                }

                // Here because they're the same
                return 0;

            }.bindenv(this));

        }
    }

    /// Performs a deep clone of a table or array container.
    /// \warning Container must not have circular references.
    /// \param  container the container/structure to deep clone.
    /// \return the cloned container.
    function _deepClone( container )
    {
        switch( typeof( container ) )
        {
            case "table":
                local result = clone container;
                foreach( k, v in container ) result[k] = _deepClone( v );
                return result;
            case "array":
                return container.map( _deepClone.bindenv(this) );
            default: return container;
        }
    }

    function test(actual) {
        _sortedExpected = _deepClone(expected);
        _sortObject(_sortedExpected);

        _sortedActual = _deepClone(actual);
        _sortObject(_sortedActual);

        return equal(_sortedActual, _sortedExpected);

    }

    function failureMessage(actual, isNegated) {
        return "Expected " + prettify(_sortedActual) + negateIfRequired(" to equal " + prettify(_sortedExpected), isNegated);
    }
}


class MockCallCountMatcher extends Matcher {
    function test(actual) {
        return (actual.hasCallCount(expected) == null);
    }

    function failureMessage(actual, isNegated) {
        if (isNegated)
        {
            return "Failed as function DID have " + expected + " calls";
        }

        return actual.hasCallCount(expected);
    }

}

class MockCalledWithAtIndexMatcher extends Matcher {
    _index = null;
    _argArray = null;

    constructor(index, argArray)
    {
        _index = index;
        _argArray = argArray;

        // As we store the 2 expected values in this class, we don't need to pass them to the constructor
        base.constructor();
    }
    
    function test(actual) {
        return (actual.wasCalledWithAtIndex(_index, _argArray) == null);
    }

    function failureMessage(actual, isNegated) {
        if (isNegated)
        {
            local res = "Failed as function WAS called at index " + _index + " with args";
            foreach (arg in _argArray)
            {
                res += " " + arg;
            }
            return res;
        }

        return actual.wasCalledWithAtIndex(_index, _argArray);
    }
}

class MockLastCalledMatcher extends Matcher {
    
    function _makeCall(actual)
    {
        // Put the reference to the MockFunction into the first arg (essentially bindenv for acall)
        local expContext = clone expected;
        expContext.insert(0, actual);

        return actual.wasLastCalledWith.acall(expContext);
    }

    function test(actual) {
        return (_makeCall(actual) == null);
    }

    function failureMessage(actual, isNegated) {
        if (isNegated) {
            local err = "Last function call WAS with args: ";
            foreach (arg in expected)
            {
                err += arg + ", ";
            }
            return err;
        }
        return _makeCall(actual);
    }
}


class MockAnyCallMatcher extends Matcher {
    function _makeCall(actual)
    {
        // Put the reference to the MockFunction into the first arg (essentially bindenv for acall)
        local expContext = clone expected;
        expContext.insert(0, actual);

        return actual.anyCallWith.acall(expContext);
    }

    function test(actual) {
        return (_makeCall(actual) == null);
    }

    function failureMessage(actual, isNegated) {
        if (isNegated) {
            local err = "There WAS a call with args: ";
            foreach (arg in expected)
            {
                err += arg + ", ";
            }
            return err;
        }
        return _makeCall(actual);
    }
}
