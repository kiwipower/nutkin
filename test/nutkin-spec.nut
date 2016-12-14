@include "../build/nutkin.nut"

//function addCustomMatcher(name, matcher) {
//    Expectation.newmember(name, matcher.test)
//::println(Expectation["aSquirrel"])
//::println(Expectation["equal"])
//}
//
//addCustomMatcher("aSquirrel", SquirrelMatcher())

describe("Nutkin expectations", function() {

    describe("equal", function() {

        it("works with strings", function() {
            expect("A String").to.equal("A String", "strings should be equal");
        })

        it("works with numbers", function() {
            expect(123).to.equal(123, "numbers should be equal");
        })

        it("works with floats", function() {
            expect(123.456).to.equal(123.456, "numbers should be equal");
        })

        it("works with arrays", function() {
            expect([1, 2, 3]).to.equal([1, 2, 3], "arrays should be equal");
        })

        it("works with tables", function() {
            expect({
                foo = "bar",
                baz = 101
            }).to.equal({
                foo = "bar",
                baz = 101
            }, "tables should be equal");
        })

        it("to.be.equal is an alias for to.equal", function() {
            expect("A String").to.be.equal("A String");
        })

        it("toBe is an alias for to.equal", function() {
            expect("A String").toBe("A String");
        })

        it("toBeNull is an alias for to.equal(null)", function() {
            expect(null).toBeNull()
        })

        it("can be used with not", function() {
            expect("A String").to.not.equal("Another String")
        })

        it("shows expect message in failure", function() {
            expectReportedFailure("Expected 'A' to equal 'B': Some message")
            expect("A").to.equal("B", "Some message")
        })

        it("fails as expected for strings", function() {
            expectReportedFailure("Expected 'A' to equal 'B'")
            expect("A").to.equal("B")
        })

        it("fails as expected for null", function() {
            expectReportedFailure("Expected 1 to equal (null)")
            expect(1).to.equal(null)
        })

        it("fails as expected for numbers", function() {
            expectReportedFailure("Expected 1 to equal 2")
            expect(1).to.equal(2)
        })

        it("fails as expected for booleans", function() {
            expectReportedFailure("Expected true to equal false")
            expect(true).to.equal(false)
        })

        it("fails as expected for arrays", function() {
            expectReportedFailure("Expected [1, 2, 3] to equal [1, 2, 4]")
            expect([1, 2, 3]).to.equal([1, 2, 4])
        })

        it("fails as expected for tables", function() {
            expectReportedFailure("Expected {foo: 'bar'} to equal {foo: 'baz'}")
            expect({foo = "bar"}).to.equal({foo = "baz"})
        })
    })

    describe("Truthy", function() {

        it("works for true", function() {
            expect(true).to.be.truthy()
        })

        it("works for 1", function() {
            expect(1).to.be.truthy()
        })

        it("works for a string", function() {
            expect("").to.be.truthy()
        })

        it("works for an array", function() {
            expect([]).to.be.truthy()
        })

        it("works for a table", function() {
            expect({}).to.be.truthy()
        })

        it("can be used with not", function() {
            expect(false).to.not.be.truthy()
        })

        it("toBeTruthy is an alias for truthy", function() {
            expect(true).toBeTruthy()
        })

        it("fails as expected", function() {
            expectReportedFailure("Expected false to be truthy")
            expect(false).to.be.truthy();
        })
    })

    describe("Falsy", function() {

        it("works for false", function() {
            expect(false).to.be.falsy()
        })

        it("works for 0", function() {
            expect(0).to.be.falsy()
        })

        it("works for null", function() {
            expect(null).to.be.falsy()
        })

        it("can be used with not", function() {
            expect(true).to.not.be.falsy()
        })

        it("toBeFalsy is an alias for truthy", function() {
            expect(false).toBeFalsy()
        })

        it("fails as expected", function() {
            expectReportedFailure("Expected true to be falsy")
            expect(true).to.be.falsy();
        })
    })

    describe("Contains", function() {

        it("works for arrays", function() {
            expect([1, 2, 3]).to.contain(2)
            expect(["1", "2", "3"]).to.contain("3")
            expect([true, false]).to.contain(true)
            expect([{a = 1}, {b = 2}]).to.contain({b = 2})
        })

        it("contains is an alias for contain", function() {
            expect([1, 2, 3]).contains(2)
        })

        it("toContain is an alias for contain", function() {
            expect([1, 2, 3]).toContain(2)
        })

        it("works with not", function() {
            expect([1, 2, 3]).to.not.contain(4)
        })

        it("fails as expected", function() {
            expectReportedFailure("Expected [1, 2, 3] to contain 4")
            expect([1, 2, 3]).to.contain(4);
        })
    })

    describe("Match", function() {

        it("matches given regular expression against value", function() {
            expect("a").to.match("[a-z]")
            expect("aA").to.match("[a-zA-Z]+")
        })

        it("matches is an alias for contain", function() {
            expect("a").matches("[a-z]")
        })

        it("toMatch is an alias for contain", function() {
            expect("a").toMatch("[a-z]")
        })

        it("works with not", function() {
            expect("a").to.not.match("[1-9]")
        })

        it("fails as expected", function() {
            expectReportedFailure("Expected 'a' to match: [1-9]")
            expect("a").to.match("[1-9]");
        })
    })

    describe("Less than", function() {

        it("works with numbers", function() {
            expect(3).to.be.lessThan(4)
        })

        it("toBeLessThan is an alias for lessThan", function() {
            expect(3).toBeLessThan(4)
        })

        it("works with not", function() {
            expect(3).to.not.be.lessThan(1)
        })

        it("fails as expected", function() {
            expectReportedFailure("Expected 10 to be less than 4")
            expect(10).to.be.lessThan(4);
        })
    })

    describe("Greater than", function() {

        it("works with numbers", function() {
            expect(3).to.be.greaterThan(2)
        })

        it("toBeGreaterThan is an alias for greaterThan", function() {
            expect(3).toBeGreaterThan(2)
        })

        it("works with not", function() {
            expect(3).to.not.be.greaterThan(4)
        })

        it("fails as expected", function() {
            expectReportedFailure("Expected 5 to be greater than 10")
            expect(5).to.be.greaterThan(10);
        })
    })

    describe("Skipping a test", function() {
        it.skip("This test will be skipped and should show in the output", function() {})
    })

    describe.skip("Skipping a suite", function() {
        it("This test will be skipped and should show in the output", function() {})
        it("This test will also be skipped and should show in the output", function() {})
    })

    describe("Throws", function() {

        it("asserts that an exception was thrown", function() {
            expect(function() { throw "BANG!" }).throws("BANG!")
        })

        it("toThrow is an alias for throws", function() {
            expect(function() { throw "BANG!" }).toThrow("BANG!")
        })

        it("expectException is an alias for throws", function() {
            expectException("BANG!", function() { throw "BANG!" })
        })

        it("works with not but still getting an exception", function() {
            expect(function() { throw "BOOM!" }).not.toThrow("BANG!")
        })

        it("works with not and no exception", function() {
            expect(function() { return 1 }).not.toThrow("BANG!")
        })
    })

    describe("Reporting failures", function() {

        it("A Failure is reported with failure message and commentary", function() {
            expectReportedFailure("Expected false to be truthy: Optional comment")
            expect(false).to.be.truthy("Optional comment")
        })

        it("A Failure is reported with failure message only if no commentary provided", function() {
            expectReportedFailure("Expected false to be truthy")
            expect(false).to.be.truthy()
        })

        it("Exceptions are trapped at the test level and reported as a failure with a stack trace", function() {
            expectReportedFailure("the index 'noMethod' does not exist")
            expect(noMethod()).to.equal("WAT")
        })
    })
})

class SquirrelMatcher extends Matcher {

    function test(actual) {
        return actual == "Nutkin"
    }

    function failureMessage(actual, isNegated) {
        if (isNegated) {
            return actual + " IS a squirrel"
        }
        return actual + " is not a squirrel"
    }
}

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

local aSquirrel = SquirrelMatcher
local called = NameMatcher

describe("Custom matchers", function() {

    describe("No-arg matchers", function() {
        it("Work for positive outcomes", function() {
            expect("Nutkin").is(aSquirrel())
        })

        it("Work for negative outcomes", function() {
            expectReportedFailure("Fluffball is not a squirrel")
            expect("Fluffball").is(aSquirrel())
        })

        it("Works with not", function() {
            expect("Fluffball").not.is(aSquirrel())
        })

        it("Works with failing not", function() {
            expectReportedFailure("Nutkin IS a squirrel")
            expect("Nutkin").not.is(aSquirrel())
        })
    })

    describe("Expected arg matchers", function() {
        it("Work for positive outcomes", function() {
            expect("Nutkin").is(called("Nutkin"))
        })

        it("Work for negative outcomes", function() {
            expectReportedFailure("Fluffball is not called Nutkin")
            expect("Fluffball").is(called("Nutkin"))
        })

        it("Works with not", function() {
            expect("Fluffball").not.is(called("Nutkin"))
        })

        it("Works with failing not", function() {
            expectReportedFailure("Fluffball IS called Fluffball")
            expect("Fluffball").not.is(called("Fluffball"))
        })
    })

    it("toBe works as an alias for is", function() {
        expect("Fluffball").toBe(called("Fluffball"))
        expect("Fluffball").not.toBe(called("Nutkin"))
    })

    it("custom matchers can take a failure comment", function() {
        expectReportedFailure("Fluffball is not called Nutkin: Names are important")
        expect("Fluffball").toBe(called("Nutkin", "Names are important"))
    })

    it("custom matchers can take a failure comment when notted", function() {
        expectReportedFailure("Fluffball IS called Fluffball: Names are important")
        expect("Fluffball").not.toBe(called("Fluffball", "Names are important"))
    })
})

