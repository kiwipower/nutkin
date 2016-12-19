# Nutkin

Nutkin is a testing framework for the Squirrel programming language.
It is very similar to the Mocha and Chai JavaScript frameworks.

It is currently being developed for use with the [Electric Imp](https://electricimp.com) flavour of Squirrel but should be (mostly) applicable to any use case.

## About Squirrel
If you're new to Squirrel, it's probably best to start with the Electric Imp [Squirrel Programming Guide](https://electricimp.com/docs/squirrel/squirrelcrib/). Please also read the [Developer Guides](https://electricimp.com/docs/resources/).

## Getting Started
To build Nutkin you require [Builder](https://www.npmjs.com/package/Builder) and the [Squirrel](http://www.squirrel-lang.org) compiler. These instructions assume that you already have [Node/npm](http://nodejs.org) and [brew](http://brew.sh/) installed.
```
npm i -g Builder
brew install squirrel
```

## Building and Using Nutkin
To use Nutkin in your own squirrel code you will need to build the output file and import that.

To build nutkin.nut:
```
./build.sh
```
This will output the final built file to /build/nutkin.nut

Copy the nutkin.nut file somewhere useful to use and import it as required (note that @import is part of Builder)
```
@import "path/to/nutkin.nut"
```
How you trigger the tests is up to you. One way would be to run the test files using sq in a script.

#### Running the tests
Nutkin can test itself. To run the unit tests do
```
./test.sh
```

#### Continous Integration
Nutkin includes a test reporter for [TeamCity](TeamCityReporter) that outputs test information in a format that will let TeamCity automatically show information about the tests run and correctly detect a failure.
To enable this reporter you need to set the following environment variable in your build:
```
NUTKIN_ENV=TEAM_CITY
```

#### Console Output
By default, Nutkin will output test information using a console reporter. This will output test details to stdout, coloured for clarity:

![Console reporter example](https://raw.githubusercontent.com/kiwipower/nutkin/master/docs/console_reporter_example.png)

## How To Write Nutkin Tests

### Suites and Specs

Tests are specified using it(), and these must be defined inside a describe() suite
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

You can assert values by chaining calls to an expect()
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

### Before & After

You can run some setup code before each test using before()
```
describe("Has a before", function() {
    before(function() {
        // Run before each test in this suite
    })

    it("A test", function() {})
})
```

And, likewise, you can also use after() for tear down code
```
describe("Has an after", function() {
    after(function() {
        // Run after each test in this suite
    })

    it("A test", function() {})
})
```

Nested suites can also specify before() and after() and these are run top down for each descendant test
```
describe("Root suite", function() {
    before(function() {
        // Root before
    })

    after(function() {
        // Root after
    })

    describe("Nested suite", function() {
        before(function() {
            // Nested before
        })

        after(function() {
            // Nested after
        })

        it("Leaf test", function() {
            // Execution order for this test is:
            // Root before
            // Nested before
            // This test
            // Nested after
            // Root after
        })
    })

    it("Another test", function() {
        // Execution order for this test is:
        // Root before
        // This test
        // Root after
    })
})
```

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

You can flag individual tests at the it() or describe() level if you want to only run a sub-set of tests
```
describe.only("Only this suite will run", function() {
    it("This test will be run", function() {})
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

## Matchers
The following are the built-in matchers:

* equal - == equality for strings and numbers, and deep equals for arrays and tables
```
expect(squirrel.name).to.equal("Whisky Frisky")
// or
expect(squirrel.name).to.be.equal("Whisky Frisky")

// And for compatability with squirrel jasmine:
expect(squirrel.name).toBe("Whisky Frisky")
```
* truthy
```
expect(squirrel.frisky).to.be.truthy()

// And for compatability with squirrel jasmine:
expect(squirrel.frisky).toBeTruthy()
```
* falsy
```
expect(squirrel.calm).to.be.falsy()

// And for compatability with squirrel jasmine:
expect(squirrel.calm).toBeFalsy()
```
* contains - expects an array and will work for nested tables
```
expect(squirrels).to.contain("Furly Curly")
// or
expect(squirrels).contains("Furly Curly")

// And for compatability with squirrel jasmine:
expect(squirrels).toContain("Furly Curly")
```
* matches - expects a string and checks that they match the given regular expression
```
expect(squirrel.name).to.match("[A-Za-z]*")
// or
expect(squirrel.name).matches("[A-Za-z]*")

// And for compatability with squirrel jasmine:
expect(squirrel.name).toMatch("[A-Za-z]*")
```
* lessThan
```
expect(squirrelCount).to.be.lessThan(100)

// And for compatability with squirrel jasmine:
expect(squirrelCount).toBeLessThan(100)
```
* greaterThan
```
expect(squirrelCount).to.be.greaterThan(1)

// And for compatability with squirrel jasmine:
expect(squirrelCount).toBeGreaterThan(1)
```
* throws - expects an exception
```
expect(squirrelNutkinPlayingNinepins).throws("A crab apple")
// or
expect(squirrelNutkinPlayingNinepins).toThrow("A crab apple")

// And for compatability with squirrel jasmine:
expectException("A crab apple", squirrelNutkinPlayingNinepins)
```

Plus the meta-expectation *not*, which can prefix any of the above to give you the inverse, e.g.:

```
expect("Whisky Frisky").to.not.equal("Hippity Hop")
```

## Custom Matchers

You can easily add your own matchers to Nutkin. All you need to do is extend Matcher and implement two methods.

1. test - returns true if the value matches, false otherwise
```
function test(actual) { return boolean }
```
2. failureMessage - called if the test methods returns false and returns the failure message to pass to the reporter
```
function failureMessage(actual, isNegated) { return string }
```

All matchers have an *expected* variable in scope which represents the expected value (i.e. the value passed into expect() in the test).

#### Examples

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

You can use the isNegated parameter to customise your failure message for the case when the matcher is preceeded by not:
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

* isTable(thing): bool
* isArray(thing): bool
* isString(thing): bool
* prettify(thing): string - outputs a formatted value - does the right thing for nulls, arrays and tables
* arraysEqual(array1, array2): bool
* tablesEqual(table1, table2): bool
* equal: bool - generic equality checker that does a deep equal for arryas and tables
* contains(array, thing): bool
* negateIfRequired(string, bool): string - will prefix the given string with a negation (e.g. 'not ') if the second param is true

All of the built-in matchers are implemented using this method, so the best place to see and example is in the source code itself.

#### Usage

A neat way of using a custom matcher is to define a local variable in your test with a fluent name. For example:
```
local aSquirrel = SquirrelMatcher
```

Then you can chain the matcher into an expect call in a readable way:
```
expect("Nutkin").toBe(aSquirrel())

expect("Nutkin").is(aSquirrel())

expect("Old Brown").not.toBe(aSquirrel())
```

Note that all matchers can be used with the .not prefix with no extra work (apart from possibly customising the failure message).