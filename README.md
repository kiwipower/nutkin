# Nutkin

Nutkin is a testing framework for the Squirrel programming language.
It is very similar to the Mocha and Chai JavaScript frameworks.

It is currently being developed for use with the [Electric Imp](https://electricimp.com) flavour of Squirrel but should be (mostly) applicable to any use case.

## About Squirrel
If you're new to Squirrel, it's probably best to start with the Electric Imp [Squirrel Programming Guide](https://electricimp.com/docs/squirrel/squirrelcrib/). Please also read the [Developer Guides](https://electricimp.com/docs/resources/).

## Getting Started
To build Nutkin you require the Builder module and the squirrel compiler. These instructions assume that you already have [Node/NPM](http://nodejs.org) and [brew](http://brew.sh/) installed.
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
This will output the final built file to /build/nutkin.nut and run the tests. If all is green you may continue.

Copy the nutkin.nut file somewhere useful to use and import it as required:
```
@import "path/to/nutkin.nut"
```
How you trigger the tests is up to you. One way would be to run the test files using sq in a script.

#### Continous Integration
Nutkin includes a test reporter for [TeamCity](TeamCityReporter) that outputs test information in a format that will let TeamCity automatically show information about the tests run and correctly detect a failure.
To enable this reporter you need to set the following environment variable in your build:
```
NUTKIN_ENV=TEAM_CITY
```

#### Console Output
By default, Nutkin will output test information using a console reporter. This will output test details to stdout, coloured for clarity:

![Console reporter example](https://raw.githubusercontent.com/kiwipower/nutkin/master/docs/console_reporter_example.png)

## Examples

A simple example:
```
describe("A test suite", function() {
   it("contains this test", function() {
        expect(true).to.be.truthy()
   })
})
```

Suites can be nested:
```
describe("A test suite", function() {
    describe("A nested suite", function() {
        it("contains this test", function() {
            expect(false).to.be.falsy()
        })
    })
})
```

Expectations all take an optional comment that will be included in the output on failure:
```
it("has an assert comment", function() {
    expect(thing).to.equal(otherThing, "Things should have been equal")
})
```

You can skip tests or suites for later implementation:
```
describe.skip("Skipped suite", function() {
    it("This test will be skipped", function() {})
})

describe("Skipped test", function() {
    it.skip("This test will be skipped", function() {})
    it("This test will NOT be skipped", function() {})
})
```

## Expectations
The following are the built-in expectations:

* equal - == equality for strings and numbers, and deep equals for arrays and tables
```
expect(squirrel.name).to.equal("Whisky Frisky")
// or
expect(squirrel.name).to.be.equal("Whisky Frisky")

// And for compatability with squirrel jasmine:
expect(squirrel.name).toBe("Whisky Frisky")
```
* truthy - true, 1, any string, any array and any table are truthy
```
expect(squirrel.frisky).to.be.truthy()

// And for compatability with squirrel jasmine:
expect(squirrel.frisky).toBeTruthy()
```
* falsy - false, 0 and null are falsy
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
expect(squirrelNutkinPlayingNinepins).to.throw("A crab apple")
// or
expect(squirrelNutkinPlayingNinepins).throws("A crab apple")

// And for compatability with squirrel jasmine:
expectException("A crab apple", squirrelNutkinPlayingNinepins)
```

Plus the meta-expectation *not*, which can prefix any of the above to give you the inverse, e.g.:

```
expect("Whisky Frisky").to.not.equal("Hippity Hop")
```