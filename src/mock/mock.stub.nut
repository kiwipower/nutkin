

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
        }

        // If the user has set this attribute we'll return it (otherwise we have nothing)
        if (key in _attributes)
        {
            return _attributes[key];
        } else {
            throw null;
        }

    }

    // Argument zero is documented as "original_this" in the squirrel2 docs, but not in squirrel3
    // There's definitely something there... Whatever it is we don't need it :)
    function _call(originalThis, ...)
    {
        _callCount++;

        // Save the callers arguments for analysis later
        _callArgs.append(vargv);

        // Check if there's a sideEffect function or array
        if ("sideEffect" in _attributes)
        {
            if (typeof(_attributes.sideEffect) == "function")
            {
                // Create a new vargv array with the context from the original call
                local allArgs = [originalThis];
                allArgs.extend(vargv);

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

