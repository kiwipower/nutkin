# Nutkin

Nutkin is a testing framework for the Squirrel programming language.
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
