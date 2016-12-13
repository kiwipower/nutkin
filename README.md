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
