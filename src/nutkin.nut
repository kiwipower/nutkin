suiteStack <- []

enum Outcome {
    PASSED,
    FAILED,
    SKIPPED
}

class SpecBuilder {
    static function skip(specName, specToRun) {
        SpecBuilder(specName, specToRun, true)
    }

    static function only(specName, specToRun) {
        SpecBuilder(specName, specToRun, false, true)
    }

    constructor(specName, specToRun, skipped = false, only = false) {
        Spec(specName, specToRun, suiteStack.top(), skipped, only)
    }
}

class SuiteBuilder {
    static function skip(suiteName, suiteToParse) {
        SuiteBuilder(suiteName, suiteToParse, true)
    }

    static function only(suiteName, suiteToParse) {
        SuiteBuilder(suiteName, suiteToParse, false, true)
    }

    constructor(suiteName, suiteToParse, skipped = false, only = false) {
        Suite(suiteName, suiteToParse, suiteStack.top(), skipped, only).parse()
    }
}

class Spec {
    name = null
    suite = null
    spec = null
    skipped = null
    only = null

    constructor(specName, specToRun, parentSuite, isSkipped = false, isOnly = false) {
        name = specName
        suite = parentSuite
        spec = specToRun
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
                spec()
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
    suiteFunction = null
    parent = null
    skipped = null
    only = null
    runQueue = null
    it = SpecBuilder
    describe = SuiteBuilder

    constructor(suiteName, suiteToParse, parentSuite = null, isSkipped = false, isOnly = false) {
        name = suiteName
        suiteFunction = suiteToParse
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

    function shouldBeSkipped() {
        return skipped || (parent ? parent.shouldBeSkipped() : false)
    }

    function markOnly() {
        only = true
        if (parent) {
            parent.markOnly()
        }
    }

    function queue(thing) {
        runQueue.push(thing)
    }

    function parse() {
        suiteStack.push(this)
        suiteFunction()
        suiteStack.pop()
    }

    function run(reporter, onlyMode) {
        if (onlyMode && !only) return []

        local explicitOnlyInChild = false
        foreach(thing in runQueue) {
            if (thing.only) explicitOnlyInChild = true
        }

        reporter.suiteStarted(name)
        local outcomes = []
        try {
            foreach(thing in runQueue) {
                outcomes.extend(thing.run(reporter, explicitOnlyInChild ? only : false))
            }
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

    function runTests() {
        reporter.begin()
        local started = clock()
        local outcomes = rootSuite.run(reporter, false)
        local passed = outcomes.filter(@(index, item) item == Outcome.PASSED).len()
        local failed = outcomes.filter(@(index, item) item == Outcome.FAILED).len()
        local skipped = outcomes.filter(@(index, item) item == Outcome.SKIPPED).len()
        local stopped = clock()

        local took = ((stopped - started) * 1000) + "ms"

        reporter.end(passed, failed, skipped, took)
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
