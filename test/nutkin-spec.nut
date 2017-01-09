@include "../build/nutkin.nut"

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

describe("Nutkin", function() {
    describe("Built-in matchers", function() {

        describe("equal", function() {

            it("works with strings", function() {
                expect("A String").to.equal("A String", "strings should be equal")
            })

            it("works with numbers", function() {
                expect(123).to.equal(123, "numbers should be equal")
            })

            it("works with floats", function() {
                expect(123.456).to.equal(123.456, "numbers should be equal")
            })

            it("works with arrays", function() {
                expect([1, 2, 3]).to.equal([1, 2, 3], "arrays should be equal")
            })

            it("works with tables", function() {
                expect({
                    foo = "bar",
                    baz = 101
                }).to.equal({
                    foo = "bar",
                    baz = 101
                }, "tables should be equal")
            })

            it("to.be.equal is an alias for to.equal", function() {
                expect("A String").to.be.equal("A String")
            })

            it("toBe is an alias for to.equal", function() {
                expect("A String").toBe("A String")
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
                expect(false).to.be.truthy()
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
                expect(true).to.be.falsy()
            })
        })

        describe("Number", function() {

            it("Works for integers", function() {
                expect(1).to.be.a.number()
                expect(0).to.be.a.number()
                expect(-1).to.be.a.number()
                expect(0x0012).to.be.a.number()
                expect(075).to.be.a.number()
                expect('w').to.be.a.number()
            })

            it("Works for floats", function() {
                expect(0.1245).to.be.a.number()
            })

            it("Works with not", function() {
                expect(true).not.to.be.a.number()
            })

            it("Fails as expected", function() {
                expectReportedFailure("Expected '1' to be a number")

                expect("1").to.be.a.number()
            })
        })

        describe("Type", function() {

            it("Works for all types", function() {
                expect(1).to.be.ofType("integer")
                expect(0x0012).to.be.ofType("integer")
                expect(075).to.be.ofType("integer")
                expect('w').to.be.ofType("integer")
                expect(1.34634).to.be.ofType("float")
                expect("a string").to.be.ofType("string")
                expect(true).to.be.ofType("bool")
                expect([]).to.be.ofType("array")
                expect({}).to.be.ofType("table")
                expect(null).to.be.ofType("null")
                expect(function() {}).to.be.ofType("function")
                expect(TypeMatcher()).to.be.ofType("instance")
            })

            it("Works with not", function() {
                expect(true).not.to.be.ofType("number")
            })

            it("Fails as expected", function() {
                expectReportedFailure("Expected (null) to be of type function")

                expect(null).to.be.ofType("function")
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
                expect([1, 2, 3]).to.contain(4)
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
                expect("a").to.match("[1-9]")
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
                expect(10).to.be.lessThan(4)
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
                expect(5).to.be.greaterThan(10)
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

    describe("Reporters", function() {

        describe("TeamCity Reporter", function() {
    
            local printer = TestPrinter()
            local tcReporter = TeamCityReporter(printer)

            beforeEach(function() {
                printer.reset()
            })
    
            it("Outputs a correctly formatted suite started message", function() {
                tcReporter.suiteStarted("A Suite")
    
                expect(printer.lastLine()).to.equal("##teamcity[testSuiteStarted name='A Suite']\n")
            })
    
            it("Outputs a correctly formatted suite finished message", function() {
                tcReporter.suiteFinished("A Suite")
    
                expect(printer.lastLine()).to.equal("##teamcity[testSuiteFinished name='A Suite']\n")
            })
    
            it("Outputs a correctly formatted suite finished message with an error", function() {
                tcReporter.suiteFinished("A Suite", "An error", "A stack trace" )
    
                local lines = printer.getLines()
                expect(lines.len()).to.equal(2)
                expect(lines[0]).to.equal("##teamcity[testSuiteFinished name='A Suite']\n")
                expect(lines[1]).to.equal("##teamcity[message text='An error' status='ERROR' errorDetails='A stack trace']\n")
            })
    
            it("Outputs a correctly formatted test started message", function() {
                tcReporter.testStarted("A Test")
    
                expect(printer.lastLine()).to.equal("##teamcity[testStarted name='A Test'] captureStandardOutput='true'\n")
            })
    
            it("Outputs a correctly formatted test finished message", function() {
                tcReporter.testFinished("A Test")
    
                expect(printer.lastLine()).to.equal("##teamcity[testFinished name='A Test']\n")
            })
    
            it("Outputs a correctly formatted test skipped message", function() {
                tcReporter.testSkipped("A Test")
    
                expect(printer.lastLine()).to.equal("##teamcity[testIgnored name='A Test']\n")
            })
    
            it("Outputs a correctly formatted test failed message", function() {
                tcReporter.testFailed("A Test", "String failure", "A stack")
    
                local lines = printer.getLines()
                expect(lines.len()).to.equal(2)
                expect(lines[0]).to.equal("##teamcity[testFailed name='A Test' message='String failure' details='']\n")
                expect(lines[1]).to.equal("##teamcity[testFinished name='A Test']\n")
            })
    
            it("Outputs a correctly formatted test failed message with a Failure", function() {
                local failure = Failure("Failure", "details")
                tcReporter.testFailed("A Test", failure, "A stack")
    
                local lines = printer.getLines()
                expect(lines.len()).to.equal(2)
                expect(lines[0]).to.equal("##teamcity[testFailed name='A Test' message='Failure' details='details']\n")
                expect(lines[1]).to.equal("##teamcity[testFinished name='A Test']\n")
            })
    
            it("Outputs nothing for begin", function() {
                tcReporter.begin()
    
                local lines = printer.getLines()
                expect(lines.len()).to.equal(0)
            })
    
            it("Outputs nothing for end", function() {
                tcReporter.end(0, 0, 0, 0)
    
                local lines = printer.getLines()
                expect(lines.len()).to.equal(0)
            })
        })

        describe("Console Reporter", function() {
            local printer = TestPrinter()
            local reporter = ConsoleReporter(printer)

            afterEach(function() {
                printer.reset()
            })
            
            it("Outputs a correctly formatted suite started message", function() {
                reporter.suiteStarted("A Suite")
                
                expect(printer.lastLine()).to.equal("  \x1B[30mA Suite\x1B[0m\x1B[36m\n")
            })
            
            it("Outputs a correctly formatted suite finished message", function() {
                reporter.suiteFinished("A Suite")
                
                expect(printer.lastLine()).to.equal("\x1B[0m\x1B[36m\n")
            })
            
            it("Outputs a correctly formatted suite finished message with an error", function() {
                reporter.suiteFinished("A Suite", "An error", "A stack trace" )

                expect(printer.lastLine()).to.equal("\x1B[0m\x1B[36m\n")
            })
            
            it("Outputs nothing for test started", function() {
                reporter.testStarted("A Test")
                
                expect(printer.getLines().len()).to.equal(0)
            })
            
            it("Outputs a correctly formatted test finished message", function() {
                reporter.testFinished("A Test")

                expect(printer.lastLine()).to.equal("\x1B[32m✓ \x1B[38;5;240mA Test\x1B[0m\x1B[36m\n")
            })
            
            it("Outputs a correctly formatted test skipped message", function() {
                reporter.testSkipped("A Test")

                expect(printer.lastLine()).to.equal("\x1B[33m➾ A Test\x1B[0m\x1B[36m\n")
            })
            
            it("Outputs a correctly formatted test failed string message", function() {
                reporter.testFailed("A Test", "String failure")

                local lines = printer.getLines()
                expect(lines.len()).to.equal(2)
                expect(lines[0]).to.equal("\x1B[31m✗ A Test\x1B[0m\x1B[36m\n")
                expect(lines[1]).to.equal("\x1B[31m\x1B[1mString failure\x1B[0m\x1B[36m\n")
            })

            it("Outputs a correctly formatted test failed string message with a stack trace", function() {
                reporter.testFailed("A Test", "String failure", "A stack")

                local lines = printer.getLines()
                expect(lines.len()).to.equal(3)
                expect(lines[0]).to.equal("\x1B[31m✗ A Test\x1B[0m\x1B[36m\n")
                expect(lines[1]).to.equal("\x1B[31m\x1B[1mString failure\x1B[0m\x1B[36m\n")
                expect(lines[2]).to.equal("\x1B[31mA stack\x1B[0m\x1B[36m\n")
            })

            it("Outputs a correctly formatted Failure", function() {
                local failure = Failure("Failure", "details")
                reporter.testFailed("A Test", failure)

                local lines = printer.getLines()
                expect(lines.len()).to.equal(3)
                expect(lines[0]).to.equal("\x1B[31m✗ A Test\x1B[0m\x1B[36m\n")
                expect(lines[1]).to.equal("\x1B[31m\x1B[1mFailure\x1B[0m\x1B[36m\n")
                expect(lines[2]).to.equal("\x1B[33mdetails\x1B[0m\x1B[36m\n")
            })

            it("Outputs a correctly formatted Failure with stack", function() {
                local failure = Failure("Failure", "details")
                reporter.testFailed("A Test", failure, "A stack")

                local lines = printer.getLines()
                expect(lines.len()).to.equal(4)
                expect(lines[0]).to.equal("\x1B[31m✗ A Test\x1B[0m\x1B[36m\n")
                expect(lines[1]).to.equal("\x1B[31m\x1B[1mFailure\x1B[0m\x1B[36m\n")
                expect(lines[2]).to.equal("\x1B[31mA stack\x1B[0m\x1B[36m\n")
                expect(lines[3]).to.equal("\x1B[33mdetails\x1B[0m\x1B[36m\n")
            })

            it("Outputs an empty line for begin", function() {
                reporter.begin()

                expect(printer.lastLine()).to.equal("\n")
            })
            
            it("Outputs stats summary on end", function() {
                reporter.end(5, 3, 1, "300ms")
                
                local lines = printer.getLines()
                expect(lines.len()).to.equal(6)
                expect(lines[0]).to.equal("\x1B[32m5 passing\x1B[0m\x1B[36m\n")
                expect(lines[1]).to.equal("\x1B[31m3 failing\x1B[0m\x1B[36m\n")
                expect(lines[2]).to.equal("\x1B[33m1 skipped\x1B[0m\x1B[36m\n")
                expect(lines[3]).to.equal("\x1B[0m\n")
                expect(lines[4]).to.equal("Took 300ms\x1B[0m\x1B[36m\n")
                expect(lines[5]).to.equal("\x1B[0m")
            })

            it("Omits failures from stats summary on end if there are none", function() {
                reporter.end(5, 0, 1, "300ms")

                local lines = printer.getLines()
                expect(lines.len()).to.equal(5)
                expect(lines[0]).to.equal("\x1B[32m5 passing\x1B[0m\x1B[36m\n")
                expect(lines[1]).to.equal("\x1B[33m1 skipped\x1B[0m\x1B[36m\n")
                expect(lines[2]).to.equal("\x1B[0m\n")
                expect(lines[3]).to.equal("Took 300ms\x1B[0m\x1B[36m\n")
                expect(lines[4]).to.equal("\x1B[0m")
            })

            it("Omits skipped from stats summary on end if there are none", function() {
                reporter.end(5, 3, 0, "300ms")

                local lines = printer.getLines()
                expect(lines.len()).to.equal(5)
                expect(lines[0]).to.equal("\x1B[32m5 passing\x1B[0m\x1B[36m\n")
                expect(lines[1]).to.equal("\x1B[31m3 failing\x1B[0m\x1B[36m\n")
                expect(lines[2]).to.equal("\x1B[0m\n")
                expect(lines[3]).to.equal("Took 300ms\x1B[0m\x1B[36m\n")
                expect(lines[4]).to.equal("\x1B[0m")
            })
        })
    })

    describe("before & after", function() {
        local rootBeforeCallCount = 0
        local rootAfterCallCount = 0
        local nestedBeforeCallCount = 0
        local nestedAfterCallCount = 0

        before(function() {
            rootBeforeCallCount++
        })

        after(function() {
            rootAfterCallCount++
        })

        describe("Nested before & after", function() {

            before(function() {
                nestedBeforeCallCount++
            })

            after(function() {
                nestedAfterCallCount++
            })

            it("before is applied once per describe", function() {
                expect(nestedBeforeCallCount).to.equal(1)
                expect(nestedAfterCallCount).to.equal(0)
                expect(rootBeforeCallCount).to.equal(1)
                expect(rootAfterCallCount).to.equal(0)
            })

            it("before and after do not delegate up the suite chain when called", function() {
                expect(nestedBeforeCallCount).to.equal(1)
                expect(nestedAfterCallCount).to.equal(0)
                expect(rootBeforeCallCount).to.equal(1)
                expect(rootAfterCallCount).to.equal(0)
            })
        })

        it("after is not applied until after all specs for the describe have executed", function() {
            expect(nestedBeforeCallCount).to.equal(1)
            expect(nestedAfterCallCount).to.equal(1)
            expect(rootBeforeCallCount).to.equal(1)
            expect(rootAfterCallCount).to.equal(0)
        })
    })

    describe("beforeEach & afterEach", function() {
        local rootBeforeEachCalled = false
        local nestedAfterEachCalled = false
        local nestedBeforeEachCalled = false
        local beforeEachState = 0
        local afterEachState = 0

        beforeEach(function() {
            rootBeforeEachCalled = true
            nestedBeforeEachCalled = false
            beforeEachState = 1
        })

        afterEach(function() {
            rootBeforeEachCalled = false
            afterEachState = 1
        })

        describe("Nested beforeEach & afterEach", function() {

            beforeEach(function() {
                nestedBeforeEachCalled = true
                beforeEachState = 2
            })

            afterEach(function() {
                nestedBeforeEachCalled = false
                nestedAfterEachCalled = true
                afterEachState = 2
            })

            it("beforeEach chain is called starting at highest level and working down", function() {
                expect(rootBeforeEachCalled).to.be.truthy("Root beforeEach should have been called before this test");
                expect(nestedBeforeEachCalled).to.be.truthy("Nested beforeEach should have been called before this test");
                expect(nestedAfterEachCalled).to.be.falsy("Nested afterEach should not have been called yet");
            })

            it("beforeEach is called before each enclosed test", function() {
                expect(nestedAfterEachCalled).to.be.truthy("Nested afterEach should have been called after previous test");
                expect(nestedBeforeEachCalled).to.be.truthy("Nested beforeEach should have been called before this test");
                expect(rootBeforeEachCalled).to.be.truthy("Root beforeEach should have been called before this test");

                nestedAfterEachCalled = false
            })

            it("beforeEaches are applied from root to test", function() {
                expect(beforeEachState).to.equal(2);
            })
        })

        it("afterEaches are applied from test to root", function() {
            expect(beforeEachState).to.equal(1);
            expect(afterEachState).to.equal(1);

            expect(rootBeforeEachCalled).to.be.truthy("Root beforeEach should have been called");
            expect(nestedBeforeEachCalled).to.be.falsy("Nested beforeEach should not have been called");
        })
    })

    describe("Clock handling", function() {
        it("Uses the clock to calculate the time taken", function() {
            local timestamp = nutkin.getTimeInMillis()
            local timeTaken = nutkin.calculateTimeTaken(0)

            expect(timestamp).to.be.a.number()
            expect(timeTaken).to.match("\\d+\\.\\d+ms")
        })

        it("Deals with the clock being a variable not a function", function() {
            local actualClock = clock;
            clock = 123

            local timeTaken = nutkin.calculateTimeTaken(0)

            expect(timeTaken).to.equal("123ms")
            clock = actualClock
        })

        it("Reports time taken in seconds if greater than 1000ms", function() {
            local actualClock = clock;
            clock = 11534

            local timeTaken = nutkin.calculateTimeTaken(0)

            expect(timeTaken).to.equal("11.534s")
            clock = actualClock
        })

        it("Deals with the clock not being defined", function() {
            local actualClock = clock;
            clock = null

            local timeTaken = nutkin.calculateTimeTaken(-1)

            expect(timeTaken).to.equal("")
            clock = actualClock
        })
    })
})
