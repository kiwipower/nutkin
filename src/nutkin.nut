@include once "src/globals.nut"
@include once "src/SpecBuilder.nut"
@include once "src/Spec.nut"
@include once "src/SuiteBuilder.nut"
@include once "src/NotApplicableSuite.nut"
@include once "src/PredicateSuite.nut"
@include once "src/Suite.nut"
@include once "src/Printer.nut"
@include once "src/Failure.nut"
@include once "src/Reporter.nut"
@include once "src/TeamCityReporter.nut"
@include once "src/ConsoleReporter.nut"
@include once "src/Matcher.nut"
@include once "src/Expectation.nut"
@include once "src/mock/mock.stub.nut"

@include once "src/libraries/JSONParser.class.nut"
@include once "src/libraries/JSONEncoder.class.nut"

suiteStack <- []

reporter <- ConsoleReporter()

try {
    if (env && env != "" && reporters[env]) {
        reporter <- reporters[env]
    }
} catch (e) {
    throw "ERROR: Invalid NUTKIN_ENV: " + env
}

class Nutkin {
    reporter = null
    rootSuite = null

    constructor(reporterInstance) {
        reporter = reporterInstance
    }

    function skipSuite(name, suite) {
        addSuite(name, suite, true)
    }

    function addSuite(name, suite, skipped = false) {
        rootSuite = Suite(name, suite, null, skipped, false, testPattern)
        rootSuite.parse()
    }

    function getTimeInMillis() {
        try {
            if (typeof clock == "function") {
                return clock() * 1000.0
            } else {
                return clock * 1.0 // To ensure it's a float
            }
        } catch (e) {
            // Target env has no clock (e.g. device stub)
            return -1
        }
    }

    function calculateTimeTaken(started) {
        if (started < 0) {
            // No clock
            return ""
        }

        local stopped = getTimeInMillis()
        local timeTaken = stopped - started

        if (timeTaken > 1000) {
            return (timeTaken / 1000) + "s"
        }

        return timeTaken + "ms"
    }

    function runTests() {
        local started = getTimeInMillis()
        reporter.begin()

        local outcomes = rootSuite.run(reporter, false)

        local passed = outcomes.filter(@(index, item) item == Outcome.PASSED).len()
        local failed = outcomes.filter(@(index, item) item == Outcome.FAILED).len()
        local skipped = outcomes.filter(@(index, item) item == Outcome.SKIPPED).len()

        reporter.end(passed, failed, skipped, calculateTimeTaken(started))
    }
}

nutkin <- Nutkin(reporter)

class it {

    static function skip(title, ...) {
        throw "it() must be used inside a describe()"
    }

    constructor(title, ...) {
        throw "it() must be used inside a describe()"
    }
}

class describe {

    static function skip(title, suite) {
        nutkin.skipSuite(title, suite)
        nutkin.runTests()
    }

    static function only(title, suite) {
        describe(title, suite)
    }

    constructor(title, suite) {
        nutkin.addSuite(title, suite)
        nutkin.runTests()
    }
}
