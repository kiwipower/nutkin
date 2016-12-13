# Nutkin

Nutkin is a testing framework for the Squirrel programming language.
It is very similar to the Mocha and Chai JavaScript frameworks.

## About Squirrel
If you're new to Squirrel, it's probably best to start with the Electric Imp [Squirrel Programming Guide](https://electricimp.com/docs/squirrel/squirrelcrib/). Please also read the [Developer Guides](https://electricimp.com/docs/resources/).

## Getting Started
To build Nutkin you require the Builder module and the squirrel compiler. These instructions assume that you already have [Note/NPM](http://nodejs.org) and [brew](http://brew.sh/) installed.
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

Expectations can be negated:
```
it("has a negated expectation", function() {
    expect("Whisky Frisky").to.not.equal("Hippity Hop")
})
```

Expectations all take an optional comment that will be included in the output on failure:
```
it("has an assert comment", function() {
    expect(thing).to.equal(otherThing, "Things should have been equal")
})
```
