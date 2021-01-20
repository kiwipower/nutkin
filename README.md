# Nutkin

Nutkin is a testing framework, with mocking capabilties, for the Squirrel programming language.
It is very similar to the Mocha and Chai JavaScript frameworks.

It is currently being developed for use with the [Electric Imp](https://electricimp.com) flavour of Squirrel but should be (mostly) applicable to any use case.

## Contents

* [About Squirrel](#about-squirrel)
* [Getting Started](#getting-started)
* [Building & Using Nutkin](#building-and-using-nutkin)
    * [Running The Tests](#running-tests)
    * [Continuous Integration](#continuous-integration)
    * [Console Output](#console-output)
* [How To Write Nutkin Tests](#how-to-write-nutkin-tests)
    * [Suites & Specs](#suites-and-specs)
    * [Asserting Behaviour](#asserting-behaviour)
    * [Setup & Teardown](#setup-and-teardown)
    * [Test Selection](#test-selection)
* [Chainables](#chainables)
* [Matchers](#matchers)
* [Custom Matchers](#custom-matchers)
    * [Examples](#examples)
    * [Usage](#usage)
* [Mocking](#mocking)
    * [Injecting the Mock](#injecting-the-mock)
    * [Usage](#usage)
    * [Integrating with Nutkin](#integrating-with-nutkin)


## About Squirrel
If you're new to Squirrel, it's probably best to start with the Electric Imp [Squirrel Programming Guide](https://electricimp.com/docs/squirrel/squirrelcrib/) and the [Developer Guides](https://electricimp.com/docs/resources/).

## Prerequisites
* [node/npm](https://nodejs.org/en/)
* [brew](https://brew.sh) (OSX)
* [Squirrel](http://www.squirrel-lang.org) compiler
  * `brew install squirrel`
  * See [KiWi Squirrel](https://github.com/kiwipower/squirrel) for a fork that supports Electric   Imp features such as:
    * unsigned chars
    * bind() strongrefs
    * Length-based string functions (as opposed to NULL termination)
* [Builder](https://github.com/electricimp/Builder)
  * `npm i -g Builder`

## Building and using Nutkin
To use Nutkin in your own squirrel code you will need to build the output file and import the built file. To generate `build/nutkin.nut` use `npm build`

Copy the `nutkin.nut` into your project import it as required, for example `@import "path/to/nutkin.nut"`

Additionally `npm build` will also generate `agent.stub.nut` and `device.stub.nut` that provide stubbing for much of the Electric Imp API, which may also be imported as required.

**Note** `@import` is part of [Builder](https://github.com/electricimp/Builder)

How you trigger the tests is up to you. One way would be to run the test files using sq in a script.

## Running tests
Nutkin can test itself by running `npm test`

### Test filter
Supplying an argument to Nutkin allows the tests to be filtered at runtime, rather than modifying the test code, for example:
```
sq build/nutkin.spec.nut pattern
sq build/nutkin.spec.nut "pattern with spaces"
```

## npm build and test
`npm` can be used to build, test or clean the project using:

* `npm run build`
* `npm test`
* `npm run clean`

### Continuous Integration
Nutkin includes a test reporter for [TeamCity](TeamCityReporter) that outputs test information in a format that will let TeamCity automatically show information about the tests run and correctly detect a failure.
To enable this reporter you need to set the following environment variable in your build: `NUTKIN_ENV=TEAM_CITY`

### Console Output
By default, Nutkin will output test information using a console reporter. This will output test details to stdout, coloured for clarity:

![Console reporter example](https://raw.githubusercontent.com/kiwipower/nutkin/master/docs/console_reporter_example.png)

## How To Write Nutkin Tests

### Suites and Specs

Tests are specified using `it()`, and these must be defined inside a `describe()` suite
```
describe("A suite", function() {
   it("contains this test", function() {
        expect(true).to.be.truthy()
   })
})
```

Suites can be nested
```
describe("A suite", function() {
    describe("A nested suite", function() {
        it("contains this test", function() {
            expect(false).to.be.falsy()
        })
    })
})
```

You can mix and match suites and tests at the same level
```
describe("A suite", function() {
    describe("A nested suite", function() {
        it("contains this test", function() {
            expect(false).to.be.falsy()
        })
    })

    it("Another test that is in the root suite", function() {
        expect(false).to.be.falsy()
    })
})
```

### Asserting Behaviour

You can assert values by chaining calls to `expect()`
```
it("uses an expect", function() {
    expect(thing).to.equal(otherThing)
})
```

All matcher functions take an optional message parameter that will be included in the output on failure
```
it("has a failure comment", function() {
    expect(thing).to.equal(otherThing, "This message is shown on failure")
})
```

All matcher functions can be prefixed with not to give a negated match
```
it("has a not", function() {
    expect(thing).not.to.equal(otherThing)
})
```

See the [Matchers](#matchers) section later for a list of all built in matchers.

### Setup and Teardown

You can run some setup code before each test using `beforeEach()`
```
describe("Has a beforeEach", function() {
    beforeEach(function() {
        // Run before each test in this suite
    })
})
```

And, likewise, you can also use `afterEach()` for tear down code
```
describe("Has an afterEach", function() {
    afterEach(function() {
        // Run after each test in this suite
    })
})
```

Nested suites can also specify `beforeEach()` and `afterEach()` and these are run for each descendant test
```
describe("Root suite", function() {
    beforeEach(function() {
        // Root beforeEach
    })

    afterEach(function() {
        // Root afterEach
    })

    describe("Nested suite", function() {
        beforeEach(function() {
            // Nested beforeEach
        })

        afterEach(function() {
            // Nested afterEach
        })

        it("Leaf test", function() {
            // Execution order for this test is:
            // Root beforeEach
            // Nested beforeEach
            // This test
            // Nested afterEach
            // Root afterEach
        })
    })

    it("Another test", function() {
        // Execution order for this test is:
        // Root beforeEach
        // This test
        // Root afterEach
    })
})
```

Note that `beforeEach()` calls are executed top down in the suite stack, whereas `afterEach()` calls are executed bottom up.

If you want to run some setup or tear down code once for a describe suite then you can use `beforeAll()` and `afterAll()`:

```
describe("Has a beforeAll", function() {
    beforeAll(function() {
        // Run before any test in this suite is executed
    })
})
```

```
describe("Has an afterAll", function() {
    afterAll(function() {
        // Run after all of the tests in this suite have executed
    })
})
```

Nested suites can also specify `beforeAll()` and `afterAll()` and these are run at the start and end of their respective suite:
```
describe("Root suite", function() {
    beforeAll(function() {
        // Root beforeAll
    })

    afterAll(function() {
        // Root afterAll
    })

    describe("Nested suite", function() {
        beforeAll(function() {
            // Nested beforeAll run before all tests in this nested suite, root beforeAll is not re-run
        })

        afterAll(function() {
            // Nested after works like the nested beforeAll, but after all the tests in this suite have run
        })
    })
})
```

Note that, unlike `beforeEach()` and `afterEach()`, `beforeAll()` and `afterAll()` do not call any `beforeAll()` or `afterAll()` implementations in their ancestor suites.

And, of course, you can mix and match `beforeAll()`, `afterAll()`, `beforeEach()` and `afterEach()` to achieve the setup and tear down that you need.

### Test Selection

You can mark tests and suites as skipped for later implementation
```
describe.skip("Skipped suite", function() {
    it("This test will be skipped", function() {})
})

describe("Skipped test inside this suite", function() {
    it.skip("This test will be skipped", function() {})
    it("This test will NOT be skipped", function() {})
})
```

You can flag individual tests at the `it()` or `describe()` level if you want to only run a sub-set of tests
```
describe.only("Only this suite will run", function() {
    it("This test will be run", function() {})
    it("This test will also be run", function() {})
})

describe("Suite", function() {
    it.only("This test will run", function() {})
    it("This test will NOT run", function() {})
})

describe.only("Suite", function() {
    it.only("This test will run", function() {}) // This .only takes precedence
    it("This test will NOT run", function() {})
})
```

## Chainables
The following are available to use for chaining calls to `expect()` to make your tests more readable:

* to
* be
* been
* a
* has
* have
* with
* that
* which
* and
* of
* is


## Matchers
The following are the built-in matchers:

* **equal** - == equality for strings and numbers, and deep equals for arrays and tables
```
expect(squirrel.name).to.equal("Whisky Frisky")

// For compatability with squirrel jasmine:
expect(squirrel.name).toBe("Whisky Frisky")
```
* **truthy**
```
expect(squirrel.frisky).to.be.truthy()

// For compatability with squirrel jasmine:
expect(squirrel.frisky).toBeTruthy()
```
* **falsy**
```
expect(squirrel.calm).to.be.falsy()

// For compatability with squirrel jasmine:
expect(squirrel.calm).toBeFalsy()
```
* **number** - matches any integer or float
```
expect(1).to.be.a.number()
```
* **ofType** - matches against built-in Squirrel type names
```
expect("something").to.be.ofType("string")
```
* **ofClass** - checks against a specific class instance
```
expect(whiskyFrisky).to.be.ofClass(Squirrel)
```
* **contains** - expects an array and will work with nested tables
```
expect(squirrels).to.contain("Furly Curly")
// or
expect(squirrels).contains("Furly Curly")

// For compatability with squirrel jasmine:
expect(squirrels).toContain("Furly Curly")
```
* **matches** - expects a string and checks that it matches the given regular expression
```
expect(squirrel.name).to.match("[A-Za-z]*")
// or
expect(squirrel.name).matches("[A-Za-z]*")

// For compatability with squirrel jasmine:
expect(squirrel.name).toMatch("[A-Za-z]*")
```
* **lessThan**
```
expect(squirrelCount).to.be.lessThan(100)

// For compatability with squirrel jasmine:
expect(squirrelCount).toBeLessThan(100)
```
* **greaterThan**
```
expect(squirrelCount).to.be.greaterThan(1)

// For compatability with squirrel jasmine:
expect(squirrelCount).toBeGreaterThan(1)
```
* **throws** - expects an exception
```
expect(squirrelNutkinPlayingNinepins).throws("A crab apple")
// or
expect(squirrelNutkinPlayingNinepins).toThrow("A crab apple")

// For compatability with squirrel jasmine:
expectException("A crab apple", squirrelNutkinPlayingNinepins)
```
* **closeTo** - checks that a float matches with the precision given. Useful for ignoring floating point rounding errors.
```
expect(squirrel.length).to.be.closeTo(0.4, 0.1)
```
* **equalUnsorted** - expects a table or array, and recursively compares every array without regard for the order of array members. Particularly useful to validate the contents of arrays which were generated from tables (which are unordered).

```
// For example, the following arrays have the same contents, but not in the same order
array1 <- [1, 2, 3, [5, 4, 3]];
array2 <- [[3, 5, 4], 3, 1, 2];

// Also works for nested arrays within tables
table1 <- { "item": ["a", "b", "c"] };
table2 <- { "item": ["c", "a", "b"] };

expect(array1).to.be.equalUnsorted(array2);
// or
expect(table1).toBeEqualUnsorted(table2);
```
* **Mock Matchers** - If you use the Mock class, additional matchers are implemented to check for mock interactions. See [Integrating with Nutkin](#integrating-with-nutkin).


Plus the meta-expectation **not**, which can prefix any of the above to give you the inverse, e.g.:

```
expect("Whisky Frisky").to.not.equal("Hippity Hop")
```

## Custom Matchers

You can easily add your own matchers to Nutkin. All you need to do is extend `Matcher` and implement two methods:

1. **test** - returns true if the value matches, false otherwise
```
function test(actual) { return boolean }
```
2. **failureMessage** - called if the test method returns false and returns the failure message to pass to the reporter
```
function failureMessage(actual, isNegated) { return string }
```

All matchers have an `expected` variable in scope which represents the expected value, i.e. the value passed into `expect()` in the test.

### Examples

Here is a simple matcher that checks against a constant value:
```
class SquirrelMatcher extends Matcher {

    function test(actual) {
        return actual == "Nutkin"
    }

    function failureMessage(actual, isNegated) {
        return actual + " is not a squirrel"
    }
}
 ```

Here is an example that checks that actual value against the expected one:
```
class NameMatcher extends Matcher {

    function test(actual) {
        return actual == expected
    }

    function failureMessage(actual, isNegated) {
        return actual + " is not called " + expected
    }
}
```

You can use the `isNegated` parameter to customise your failure message for the case when the matcher is preceeded by not:
```
test:
expect("Fluffball").not.toBe(called("Fluffball"))

matcher:
class NameMatcher extends Matcher {

    function test(actual) {
        return actual == expected
    }

    function failureMessage(actual, isNegated) {
        if (isNegated) {
            return actual + " IS called " + expected
        }
        return actual + " is not called " + expected
    }
}

```

All matchers also have the following functions in scope:

* `isTable(thing): bool`
* `isArray(thing): bool`
* `isString(thing): bool`
* `prettify(thing): string` - outputs a formatted value - does the right thing for nulls, arrays and tables
* `arraysEqual(array1, array2): bool`
* `tablesEqual(table1, table2): bool`
* `equal: bool` - generic equality checker that does a deep equal for arrays and tables
* `contains(array, thing): bool`
* `negateIfRequired(string, bool): string` - will prefix the given string with a negation (e.g. 'not ') if the second param is true

All of the built-in matchers are implemented this way, so the best place to see an example is in the source code itself.

### Usage

A neat way of using a custom matcher is to define a local variable in your test with a fluent name. For example:
```
local aSquirrel = SquirrelMatcher
```

Then you can chain the matcher into an expect call in a readable way:
```
expect("Nutkin").toBe(aSquirrel())

expect("Old Brown").not.toBe(aSquirrel())
```

Note that all matchers will work with the ```.not``` prefix for free, apart from possibly customising the failure message.

## Mocking

Nutkin includes a Mock class which is designed to provide a generic and stable interface to build mocks. It allows the behaviour of a mock to be defined within a unit test.

The functionality is broadly based on the [Python unittest.Mock class.](https://docs.python.org/3/library/unittest.mock.html#unittest.mock.Mock)

Interface names have been borrowed from this class, changed from the original snake_case to camelCase. Not all features are implemented, or implemented fully.

### Injecting the Mock

#### Dependency Injection

The simplest way to use this class is to pass it instead of the class you wish to mock. This requires the unit under test to be written for injected dependencies.

For example, if a module takes a reference to an I2C module as an argument to the constructor, you can instantiate and pass the Mock class instead.

```

// Create a mock class and pass it in place of the real hardware class
local mockI2C = Mock();
local myChip = myChipLibrary(mockI2C);

```

#### Mocking Electric Imp Globals

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

#### Code Under Test Creates Class

If the code being tested creates a class, we can't inject a Mock object. This requires a different approach.

### Usage

The Mock object provides three functions:

**Before** the unit under test has been run, the Mock must be preloaded with data and return values for any functions which will be called.

**During test** the test can call any function name (excluding reserved names) and read any predefined variables. Each function call is counted and the arguments recorded.

**After** the unit under test has been run, the Mock can be interrogated to see what was called and what arguments were passed.

#### Reserved Names

Limitations of the implementation mean that the Mock class cannot mock certain names. If the class you're trying to mock implements functions or variables with these names you'll need to change them.

* resetMock
* MockFunction
* Mock (Reserved but possibly doesn't need to be)
* print (Reserved but possibly doesn't need to be)

#### Before Testing

##### Reset Mock

If a single Mock object is being used across tests (for example if you're mocking an Electric Imp global), the `resetMock()` function should be called at the beginning of each test. This will reset all pre-loaded values and recorded calls.

There's a few interfaces to preload data.

##### Return Value

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

##### Side Effect Function

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

##### Side Effect Array

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
##### Order of Priority

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

#### After Test

After a test has run, you may want to examine a Mock object. 

##### Call Count

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

##### Call Arguments

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

### Integrating with Nutkin

Nutkin provides additional matchers to enable more effective use of the Mock object.

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