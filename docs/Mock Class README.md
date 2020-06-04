# Squirrel Mock Class

The squirrel Mock class is designed to provide a generic and stable interface to build mocks. It allows the behaviour of a mock to be defined within a unit test.

The functionality is broadly based on the Python unittest.Mock class. https://docs.python.org/3/library/unittest.mock.html#unittest.mock.Mock.

Interface names have been borrowed from this class, changed from the original snake_case to camelCase. Not all features are implemented, or implemented fully.

## Injecting the Mock

### Dependency Injection

The simplest way to use this class is to pass it instead of the class you wish to mock. This requires the unit under test to be written for injected dependencies.

For example, if a module takes a reference to an I2C module as an argument to the constructor, you can instantiate and pass the Mock class instead.

```

// Create a mock class and pass it in place of the real hardware class
local mockI2C = Mock();
local myChip = myChipLibrary(mockI2C);

```

### Mocking Electric Imp Globals

Electric Imp provides some globals which aren't present in the test framework. These include `agent`, `crypto`, `device`, `ftp`, `hardware` and others.

As these objects aren't directly included, they can be mocked by carefully defining the include order in the test file. You may also need to define any constants which are referenced by these globals.

If a global object is mocked frequently, it may make sense to define it in a file which is included in the test.

```
// Include the Mock class
@include once "mock.stub.nut"

// Define constants which are normally defined by the i2c module
const CLOCK_SPEED_10_KHZ = 10000;
const CLOCK_SPEED_50_KHZ = 50000;
const CLOCK_SPEED_100_KHZ = 100000;
const CLOCK_SPEED_400_KHZ = 400000;

// Create a mock for the hardware module
hardware <- Mock();

// Include the file with the unit under test
@include once "si7020.device.class.nut"


describe( "SI7020", function()
{
    
    it( "Tests the module", function()
    {
        // Remember to reset your single hardware Mock object before each test runs
        hardware.resetMock();

        // ... test here ..

    });
});

```

### Code Under Test Creates Class

If the code being tested creates a class, we can't inject a Mock object. This requires a different approach.

## Usage

The Mock object provides three functions:

**Before** the unit under test has been run, the Mock must be preloaded with data and return values for any functions which will be called.

**During test** the test can call any function name (excluding reserved names) and read any predefined variables. Each function call is counted and the arguments recorded.

**After** the unit under test has been run, the Mock can be interrogated to see what was called and what arguments were passed.

### Reserved Names

Limitations of the implementation mean that the Mock class cannot mock certain names. If the class you're trying to mock implements functions or variables with these names you'll need to change them.

* resetMock
* MockFunction
* Mock (Reserved but possibly doesn't need to be)
* print (Reserved but possibly doesn't need to be)

### Before Testing

#### Reset Mock

If a single Mock object is being used across tests (for example if you're mocking an Electric Imp global), the `resetMock()` function should be called at the beginning of each test. This will reset all pre-loaded values and recorded calls.

There's a few interfaces to preload data.

#### Return Value

Any variable (excluding reserved names) can be assigned a value. When the unit under test reads this variable, it will have the assigned value.

```
local m = Mock();
        
// Assign a value
m.thisVal <- 22.03;

// This prints 22.03
print(m.thisVal);
```
The unit under test can call any function name (excluding reserved names and variables which have been assigned values). The user can choose to preload any function with a simple return value or more complicated behaviour.

Assigning the `returnValue` will return that value whenever that function is called.

```
local m = Mock();
        
// Assign function aFunction() the return value "hello"
m.aFunction.returnValue <- "hello";


// This prints hello
print(m.aFunction());
```

#### Side Effect Function

Assigning the `sideEffect` can have two effects:

If `sideEffect` points to a function, that will be called whenever the mock function is called by the unit under test. The arguments will be passed transparently to the sideEffect function. The return value of the sideEffect function will be returned to the unit under test except in the special case that the sideEffect function returns an instance of the type `MockFunction.DefaultReturn`.

```

function sideEffectFunc(arg1)
{
    // arg1 == "thisIsArg"
    return "side effects happen";
};

local m = Mock();

// Pass a function to be called when the mock function is called
m.newFunc.sideEffect <- sideEffectFunc;

// prints "side effects happen"
print(m.newFunc("thisIsArg"));

```

If the assigned function returns an instance of `MockFunction.DefaultReturn`, the mock function will return the default value - either the `returnValue` (if it has been assigned), or a new Mock instance.

This behaviour is useful if you wish to mock a function which in turn returns a different class. The default behaviour of the Mock class is to create a new instance of Mock for each function name called. If the same function is called twice, the same instance of Mock will be returned twice. This means your test code can access the Mock created by a function by calling that function. That Mock instance can then be preloaded or interrogated in the same way.

**Note** that if you access the generated Mock by calling a function, that function's `called` will be set true and `callCount` will be incremented. Your tests must account for this.

```
local m = Mock();

// Use an anonymous function
m.newFunc.sideEffect <- function() {
        return MockFunction.DefaultReturn();
    };

// Call the function and take reference of the result
local newMock = m.newFunc();

// Prints true
print(newMock instanceof Mock);

// Our newMock IS NOT just m, it's a new Mock instance.
// Prints false
print(newMock == m);

```

#### Side Effect Array

If `sideEffect` is assigned an array, each entry in the array will be returned in turn every time the mock function is called. If the function is called more times than the array has members, the last element will be repeatedly returned.

```
local m = Mock();

// Declare an array to be returned as a side effect
local sideEffectArray = [22, 33, 44, 55, 66, 77, 88];

m.thisFunc.sideEffect <- sideEffectArray;

// prints 22, 33, 44, 55, 66, 77, 88
foreach (effect in sideEffectArray)
{
    print(m.thisFunc());
}

// prints 88
print(m.thisFunc());

// prints 88
print(m.thisFunc());

```
#### Order of Priority

If both `returnValue` and `sideEffect` are assigned, the `sideEffect` has precedence. Only if the `sideEffect` function returns `MockFunction.DefaultReturn` will the `returnValue` be returned.

If neither the `returnValue` or `sideEffect` variables are assigned, the default behaviour is to return a new Mock object (see the effects of returning `MockFunction.DefaultReturn`).

```
local m = Mock();

// Don't assign anything

// Call any function and take reference of the result
local newMock = m.myArbitraryFunction();

// Prints true
print(newMock instanceof Mock);

// Our newMock IS NOT just m, it's a new Mock instance.
// Prints false
print(newMock == m);

// Call the same function again - the Mock object is the same.
local secondMock = m.myArbitraryFunction();

// Prints true
print(newMock == secondMock);

// Call a different function, you'll get a different Mock again
local otherMock = m.differentFunction();

// Prints false
print(newMock == otherMock);

```

**Note** that if you want a mock function to behave the same as a function with no return value, you need to set `returnValue` to `null`.

### After Test

After a test has run, you may want to examine a Mock object. 

#### Call Count

If a function was called, `called` will be true. `callCount` will record the number of times it was called.

```
local m = Mock();

// Call an arbitrary function once
m.hello();

// Prints true
print(m.hello.called);

// Prints 1
print(m.hello.callCount);

```

#### Call Arguments

`callArgs` is an array of the last arguments it was called with. `callArgsList` is an array of arrays, containing the arguments from every time the function was called.


```
local m = Mock();

// Call the same arbitrary function a few times
m.whassup("this", "is", 1);
m.whassup("now", "its", 2);

// Prints 2
print(m.whassup.callCount);

// callArgs is the _last_ call args
// Prints "now"
print(m.whassup.callArgs[0]);

// Prints its
print(m.whassup.callArgs[1]);

// Prints 2
print(m.whassup.callArgs[2]);

// call_args_list is _all_ the call args
local callArgs = m.whassup.callArgsList;

// Prints "this"
print(callArgs[0][0])

// Prints "is"
print(callArgs[0][1])

// Prints 1
print(callArgs[0][2])


// Prints "now"
print(callArgs[1][0])

// Prints "its"
print(callArgs[1][1])

// Prints 2
print(callArgs[1][2])

```

## Using With Nutkin

Nutkin provides additional helpers to enable more effective use of the Mock object.

```
local m = Mock();

// Call the same arbitrary function a few times
m.whoopee("this", "is", 1);
m.whoopee(); // No args for this call
m.whoopee("third", "call", 3);
m.whoopee("Different", 4.0, "arg", 19, false, "types");


// *Checking call count*
// Passes
expect(m.whoopee).to.have.callCount(4);

// Alias for same thing
expect(m.whoopee).toHaveCallCount(4);

// callCount can be chained with other expectations
expect(m.whoopee).to.have.callCount(4).and.be.truthy();

// Fails
expect(m.whoopee).to.have.callCount(2);


// *Checking call arguments for specified call*
// Passes
expect(m.whoopee).to.be.calledWithAtIndex(0, ["this", "is", 1]);

// Alias for same thing
expect(m.whoopee).toBeCalledWithAtIndex(0, ["this", "is", 1]);

// Passes (checking for type, not exact argument)
expect(m.whoopee).to.be.calledWithAtIndex(0, [Mock.Type("string"), "is", Mock.Type("integer")]);

// Fails (index too high)
expect(m.whoopee).toBeCalledWithAtIndex(4);

// Fails (arguments don't match)
expect(m.whoopee).toBeCalledWithAtIndex(3, ["third", "call", 3]);

// *Checking arguments for specified type*
// Passes
expect(m.whoopee).toBeC

// *Checking arguments for last call*
// Passes
expect(m.whoopee).to.be.lastCalledWith("Different", 4.0, "arg", 19, false, "types");
// Also passes (checking for types)
expect(m.whoopee).to.be.lastCalledWith(Mock.Type("string"), Mock.Type("float"), Mock.Type("string"), Mock.Type("integer"), Mock.Type("bool"), Mock.Type("string"));


// Alias for same thing
expect(m.whoopee).toBeLastCalledWith("Different", 4.0, "arg", 19, false, "types");

// Fails (not last call)
expect(m.whoopee).toBeLastCalledWith("third", "call", 3);


// *Checking arguments for _any_ call*
// Passes
expect(m.whoopee).to.have.anyCallWith();
// Alias for same thing
expect(m.whoopee).toHaveAnyCallWith();

// Fails (no call with these args)
expect(m.whoopee).toHaveAnyCallWith("not", "here");



```