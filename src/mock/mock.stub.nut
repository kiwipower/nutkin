

/*

Squirrel Mocking Class
Author: Leo Rampen
Date: 20/04/2020

This class provides a generic, stable interface to build mocks with. It allows the logic of a mocks behaviour to be defined
as part of a unit test.

The functionality is broadly based on the Python unittest.Mock class. https://docs.python.org/3/library/unittest.mock.html#unittest.mock.Mock.

Interface names have been converted to match the Electric Imp Style Guide - generally the snake_case python names have been converted to camelCase. Not all features are implemented, or implemented fully.

The unit tests should give an idea of the spec this class was built against.

*/

class MockFunction {
    // The parent Mock type which created this
    _parentMock = null;

    // The function name called to create us
    _name = null;

    // A list of all the variables which have been added (with the <- operator)
    _attributes = null;

    _callCount = 0;
    _callArgs = null;
    _callMock = null;


    constructor(parentMock = null, name = null)
    {
        _parentMock = parentMock;
        _name = name;
        _callCount = 0;

        _attributes = {};
        _callArgs = [];

        // We don't always return a mock (if the user sets a return_value, we return something else)
        // But we pre-emptively create it anyway
        _callMock = Mock();

    }

    // _set and _newslot are just used to record values in this class
    function _newslot(key, value)
    {
        _attributes[key] <- value;
    }   

    function _set(key, val)
    {
        _attributes[key] = val;
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
        if ((typeof(a) == "array") && (typeof(b) == "array")) {
            return arraysEqual(a, b)
        } else if ((typeof(a) == "table") && (typeof(b) == "table")) {
            return tablesEqual(a, b)
        } else {
            return a == b
        }
    }

    // Check for a call with the defined count
    function _hasCallCount(callCount)
    {
        // Helper function to collate common arguments
        if (_callCount != callCount)
        {
            return "Call count doesn't match. Expected: " + callCount + ", Actual: " + _callCount;
        }

        return null;
    }

    function _wasCalledWithAtIndex(callToCheck, callArgs = [])
    {
        if (callToCheck >= _callCount)
        {
            return "Call to check doesn't exist. Checking " + callToCheck + " but only " + _callCount + " calls.";
        }

        // Check that each argument is present
        foreach (index, arg in callArgs)
        {
            if (_callArgs[callToCheck].len() <= index)
            {
                return "Argument " + index + " expected: " + arg + " but no argument given";
            }

            local actual = _callArgs[callToCheck][index];

            // Type check or value check
            if (arg instanceof Mock.Type)
            {
                local comparison = arg.compare(actual);
                if (comparison != null)
                {
                    return comparison;
                }
            } 
            else if (arg instanceof Mock.Ignore)
            {
                // an arg of Mock.Ignore should be ignored - continue to next argument
                continue;
            } 
            else
            {
                if (!equal(actual, arg))
                {
                    return "Argument " + index + " expected: " + arg + " but actual was " + actual;
                }
            }
        }

        // And then check that there's no additional arguments
        if (_callArgs[callToCheck].len() > callArgs.len())
        {
            return "Function called with additional arguments. Expected: " + callArgs.len() + " but got: " + _callArgs[callToCheck].len() + " arguments";
        }

        return null;

    } 



    function _anyCallWith(...)
    {
        local callFound = false;

        // Check each call made in turn looking for this call
        for (local i = 0; i < _callCount; i++)
        {
            local result = _wasCalledWithAtIndex(i, vargv);

            // A null result means the call was matched
            if (result == null)
            {
                callFound = true;
                break;
            }
        }

        if (callFound)
        {
            return null;
        } else {
            return "Call not found";
        }

    }

    // Check to see if this function was last called with the provided arguments
    function _wasLastCalledWith(...)
    {
        if (_callArgs.len() > 0)
        {
            return _wasCalledWithAtIndex(_callArgs.len() - 1, vargv);
        } else {
            return "Was not called";
        }
    }


    function _get(key)
    {
        // Special cases to access details of the mock calls
        switch (key)
        {
            case "called":
                return (_callCount > 0);
            case "callCount":
                return _callCount;
            case "callArgs":
                if ((_callArgs != null) && (_callArgs.len() > 0))
                {
                    return _callArgs.top();
                } else {
                    return null;
                }
            case "callArgsList":
                return _callArgs;
            case "returnValue":
                if ("returnValue" in _attributes)
                {
                    return _attributes.returnValue;
                } else {
                    return _callMock;
                }
            case "hasCallCount":
                return _hasCallCount;
            case "wasLastCalledWith":
                return _wasLastCalledWith;
            case "anyCallWith":
                return _anyCallWith;
            case "wasCalledWithAtIndex":
                return _wasCalledWithAtIndex;
        }

        // If the user has set this attribute we'll return it (otherwise we have nothing)
        if (key in _attributes)
        {
            return _attributes[key];
        } else {
            throw null;
        }

    }

    function acall( arguments )
    {
        ++_callCount;

        local newCallArgs = arguments.slice( 1, arguments.len() );

        // Save the callers arguments for analysis later
        _callArgs.append( _deepClone(newCallArgs) );

        // Check if there's a sideEffect function or array
        if ("sideEffect" in _attributes)
        {
            if (typeof(_attributes.sideEffect) == "function")
            {
                // Create a new vargv array with the context from the original call
                local allArgs = [newCallArgs[0]];
                allArgs.extend(newCallArgs);

                // Call the function using acall to pass the array as its arguments
                local result = _attributes.sideEffect.acall(allArgs);

                // The tester can return DefaultReturn to ignore this sideEffect function
                if (!(result instanceof MockFunction.DefaultReturn))
                {
                    return result;
                }
            } 
            else if (typeof(_attributes.sideEffect) == "array")
            {
                // If sideEffect is an array, return each variable in turn
                if (_callCount <= _attributes.sideEffect.len())
                {
                    return _attributes.sideEffect[_callCount - 1];
                } else {
                    // Saturate at the last member of the array for all subsequent calls
                    return _attributes.sideEffect.top();
                }

            }
        }

        // If we've had a return value set, we return that
        if ("returnValue" in _attributes)
        {
            return _attributes.returnValue;
        }
        
        // If nothing else was set, we return a new Mock class
        return _callMock;
    }

    // Argument zero is documented as "original_this" in the squirrel2 docs, but not in squirrel3
    // There's definitely something there... Whatever it is we don't need it :)
    function _call(originalThis, ...)
    {
        local arguments = [originalThis];
        arguments.extend( vargv );
        return acall( arguments );
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
                foreach( k, v in container ) result[k] = deepClone( v );
                return result;
            case "array":
                return container.map( deepClone );
            default: return container;
        }
    }
} 

class MockFunction.DefaultReturn {
    // A default return type for sideEffect functions
}


class Mock {  
    // A list of all the variables which have been added (with the <- operator)
    _attributes = null;

    // A list of all the mocks we returned
    _calls = null;


    constructor(mockType = null)
    {
        _attributes = {};
        _calls = {};
    }

    function _call(...)
    {
    }

    function resetMock()
    {
        // Clear everything
        _attributes = {};
        _calls = {};

        // TODO: We're just clearing the lists, which means if someone took a reference to a call
        // it might still be hanging about. Should we reset all referenced calls as well?
    }


    // Store any data which is assigned
    function _newslot(key, value)
    {
       _attributes[key] <- value;
    }   

    function _set(key, val)
    {
        _attributes[key] = value;
    }

    function _get(key)
    {
        // Check if this slot has been created and if it has, return the value
        if (key in _attributes)
        {
            return _attributes[key];
        }

        // If we don't whitelist all external functions/objects/references
        // we end up with recursion. Uhoh. If you have an infinite loop or stack overflow, check this
        if ((key == "print") || (key=="Mock") || (key=="MockFunction"))
        {
            throw null;
        }


        if (key in _calls)
        {
            return _calls[key];
        }

        local newReturn = MockFunction(this, key);
        _calls[key] <- newReturn;
        return newReturn;

    }


}

class Mock.Type
{    
    _type = null;
    
    constructor(type)
    {
        local allowedTypes = ["bool", "string", "integer", "float", "blob", "instance", "array", "table", "function"];

        if (allowedTypes.find(type) == null)
        {
            throw("Type " + type + " not valid");
        }

        _type = type;
    }

    function compare(var)
    {
        if (typeof(var) != _type)
        {
            return "Var " + var + " is not of type " + _type;
        }

        return null;
    }
}

class Mock.Ignore
{

}


