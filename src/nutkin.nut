suiteStack <- []

enum Outcome {
    PASSED,
    FAILED,
    SKIPPED
}

class SpecBuilder {
    static function skip(specName, spec) {
        SpecBuilder(specName, spec, true)
    }

    static function only(specName, spec) {
        SpecBuilder(specName, spec, false, true)
    }

    constructor(specName, spec, skipped = false, only = false) {
        Spec(specName, spec, suiteStack.top(), skipped, only)
    }
}

class SuiteBuilder {
    static function skip(suiteName, suite) {
        SuiteBuilder(suiteName, suite, true)
    }

    static function only(suiteName, suite) {
        SuiteBuilder(suiteName, suite, false, true)
    }

    constructor(suiteName, suite, skipped = false, only = false) {
        Suite(suiteName, suite, suiteStack.top(), skipped, only).parse()
    }
}

class NotApplicableSuite {
    static function skip(suiteName, suite) {
        NotApplicableSuite(suiteName, suite)
    }

    static function only(suiteName, suite) {
        NotApplicableSuite(suiteName, suite)
    }

    constructor(suiteName, suite) {
        reporter.print("Not applicable suite: "+ suiteName)
    }
}

class Spec {
    name = null
    suite = null
    specBody = null
    skipped = null
    only = null

    constructor(specName, spec, parentSuite, isSkipped = false, isOnly = false) {
        name = specName
        suite = parentSuite
        specBody = spec
        skipped = isSkipped
        only = isOnly

        parentSuite.queue(this)

        if (only) {
            parentSuite.markOnly()
        }
    }

    function shouldBeSkipped() {
        return skipped || suite.shouldBeSkipped()
    }

    function isOnly() {
        return only
    }

    function reportTestFailed(reporter, e, stack) {
        reporter.testHasFailed(name, e, stack)
    }

    function run(reporter, onlyMode) {
        if (onlyMode && !only) return []

        if (shouldBeSkipped()) {
            reporter.testSkipped(name)
            return [Outcome.SKIPPED]
        } else {
            reporter.testStarted(name)
            try {
                specBody()
                reporter.testFinished(name)
                return [Outcome.PASSED]
            } catch (e) {
                // When an exception has been caught, the relevant stack has already been unwound, so stackTrace() doesn't help us
                local stack = ""
                if (typeof e == typeof "") {
                    e = Failure(e)
                    stack = "\nStack: " + ::stackTrace()
                }
                reporter.testHasFailed(name, e, stack)
                if (reporter.doNotReportIndividualTestFailures()) {
                    return [Outcome.PASSED]
                } else {
                    return [Outcome.FAILED]
                }
            }
        }
    }
}

class PredicateSuite {
    describe = null;

    constructor(condition) {
        if(condition) {
            describe = SuiteBuilder
        } else {
            describe = NotApplicableSuite
        }
    }
}

class Suite {
    name = null
    suiteBody = null
    parent = null
    beforeAllFunc = null
    afterAllFunc = null
    beforeEachFunc = null
    afterEachFunc = null
    skipped = null
    only = null
    runQueue = null
    it = SpecBuilder
    describe = SuiteBuilder
    onlyIf = PredicateSuite

    constructor(suiteName, suite, parentSuite = null, isSkipped = false, isOnly = false) {
        name = suiteName
        suiteBody = suite
        parent = parentSuite
        skipped = isSkipped
        only = isOnly
        runQueue = []

        if (parentSuite) {
            parentSuite.queue(this)
        }

        if (only) {
            parentSuite.markOnly()
        }
    }

    function beforeAll(beforeAllImpl) {
        if (typeof beforeAllImpl != "function") {
            throw "before() takes a function argument"
        }

        beforeAllFunc = beforeAllImpl
    }

    function afterAll(afterAllImpl) {
        if (typeof afterAllImpl != "function") {
            throw "after() takes a function argument"
        }

        afterAllFunc = afterAllImpl
    }

    function beforeEach(beforeEachImpl) {
        if (typeof beforeEachImpl != "function") {
            throw "beforeEach() takes a function argument"
        }

        beforeEachFunc = beforeEachImpl
    }

    function afterEach(afterEachImpl) {
        if (typeof afterEachImpl != "function") {
            throw "afterEach() takes a function argument"
        }

        afterEachFunc = afterEachImpl
    }

    function shouldBeSkipped() {
        return skipped || (parent ? parent.shouldBeSkipped() : false)
    }

    function markOnly() {
        only = true
        if (parent) {
            parent.markOnly()
        }
    }

    function queue(runnable) {
        runQueue.push(runnable)
    }

    function parse() {
        suiteStack.push(this)
        suiteBody()
        suiteStack.pop()
    }

    function hasAnOnlyDescendant() {
        foreach(runnable in runQueue) {
            if (runnable.only) {
                return true
            }
        }
        return false
    }

    function runBeforeAlls() {
        if (beforeAllFunc) {
            beforeAllFunc()
        }
    }

    function runAfterAlls() {
        if (afterAllFunc) {
            afterAllFunc()
        }
    }

    function runBeforeEaches() {
        if (parent) {
            parent.runBeforeEaches()
        }

        if (beforeEachFunc) {
            beforeEachFunc()
        }
    }

    function runAfterEaches() {
        if (afterEachFunc) {
            afterEachFunc()
        }

        if (parent) {
            parent.runAfterEaches()
        }
    }

    function reportTestFailed(reporter, e, stack) {
        foreach(runnable in runQueue) {
            runnable.reportTestFailed(reporter, e, stack)
        }
    }

    function run(reporter, onlyMode) {
        if (onlyMode && !only) {
            return []
        }

        local explicitOnlyInChild = hasAnOnlyDescendant()
        local outcomes = []
        local suiteError = null
        local suiteStack = null

        reporter.suiteStarted(name)

        try {
            runBeforeAlls()

            foreach(runnable in runQueue) {
                try {
                    runBeforeEaches()
                    outcomes.extend(runnable.run(reporter, explicitOnlyInChild ? only : false))
                    runAfterEaches()
                } catch (e) {
                    suiteError = e
                    suiteStack = "\nStack: " + ::stackTrace()
                    runnable.reportTestFailed(reporter, e, suiteStack)
                }
            }

            runAfterAlls()
            reporter.suiteFinished(name)
        } catch (e) {
            suiteError = e
            suiteStack = "\nStack: " + ::stackTrace()
        }

        if (suiteError != null) {
            reporter.suiteErrorDetected(name, suiteError, suiteStack)
        }

        return outcomes
    }
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
        rootSuite = Suite(name, suite, null, skipped)
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

reporter <- ConsoleReporter()

local env = getenv("NUTKIN_ENV")

try {
    if (env && env != "" && reporters[env]) {
        reporter <- reporters[env]
    }
} catch (e) {
    throw "ERROR: Invalid NUTKIN_ENV: " + env
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
