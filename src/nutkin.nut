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
                local stack = ""
                if (typeof e == typeof "") {
                    e = Failure(e)
                    stack = "\nStack: " + ::stackTrace()
                }
                if (reporter.testFailed(name, e, stack)) {
                    return [Outcome.FAILED]
                } else {
                    return [Outcome.PASSED]
                }
            }
        }
    }
}

class Suite {
    name = null
    suiteBody = null
    parent = null
    beforeFunc = null
    afterFunc = null
    beforeEachFunc = null
    afterEachFunc = null
    skipped = null
    only = null
    runQueue = null
    it = SpecBuilder
    describe = SuiteBuilder

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

    function before(beforeImpl) {
        if (typeof beforeImpl != "function") {
            throw "before() takes a function argument"
        }

        beforeFunc = beforeImpl
    }

    function after(afterImpl) {
        if (typeof afterImpl != "function") {
            throw "after() takes a function argument"
        }

        afterFunc = afterImpl
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

    function runBefores() {
        if (beforeFunc) {
            beforeFunc()
        }
    }

    function runAfters() {
        if (afterFunc) {
            afterFunc()
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

    function run(reporter, onlyMode) {
        if (onlyMode && !only) {
            return []
        }

        local explicitOnlyInChild = hasAnOnlyDescendant()
        local outcomes = []

        reporter.suiteStarted(name)
        runBefores()

        try {
            foreach(runnable in runQueue) {
                runBeforeEaches()
                outcomes.extend(runnable.run(reporter, explicitOnlyInChild ? only : false))
                runAfterEaches()
            }

            runAfters()
            reporter.suiteFinished(name, "")
        } catch (e) {
            reporter.suiteFinished(name, e, ::stackTrace())
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
                return clock() * 1000
            } else {
                return clock
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
