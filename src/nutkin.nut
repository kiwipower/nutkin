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

    constructor(specName, specToRun, skipped = false) {
        Spec(specName, specToRun, suiteStack.top(), skipped)
    }
}

class SuiteBuilder {
    static function skip(suiteName, suiteToParse) {
        SuiteBuilder(suiteName, suiteToParse, true)
    }

    constructor(suiteName, suiteToParse, skipped = false) {
        Suite(suiteName, suiteToParse, suiteStack.top(), skipped).parse()
    }
}

class Spec {
    name = null
    suite = null
    spec = null
    skipped = null

    constructor(specName, specToRun, parentSuite, isSkipped = false) {
        name = specName
        suite = parentSuite
        spec = specToRun
        skipped = isSkipped

        parentSuite.queue(this)
    }

    function shouldBeSkipped() {
        return this.skipped || this.suite.shouldBeSkipped();
    }

    function run(reporter) {
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
    runQueue = null
    it = SpecBuilder
    describe = SuiteBuilder

    constructor(suiteName, suiteToParse, parentSuite = null, isSkipped = false) {
        name = suiteName
        suiteFunction = suiteToParse
        parent = parentSuite
        skipped = isSkipped
        runQueue = []

        if (parentSuite) {
            parentSuite.queue(this)
        }
    }

    function shouldBeSkipped() {
        return this.skipped || (this.parent ? this.parent.shouldBeSkipped() : false)
    }

    function queue(thing) {
        runQueue.push(thing)
    }

    function parse() {
        suiteStack.push(this)
        suiteFunction()
        suiteStack.pop()
    }

    function run(reporter) {
        reporter.suiteStarted(name)
        local outcomes = []
        try {
            foreach(thing in runQueue) {
                outcomes.extend(thing.run(reporter))
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

    constructor(reporterInstance = ConsoleReporter()) {
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
        local outcomes = rootSuite.run(reporter)
        local passed = outcomes.filter(@(index, item) item == Outcome.PASSED).len()
        local failed = outcomes.filter(@(index, item) item == Outcome.FAILED).len()
        local skipped = outcomes.filter(@(index, item) item == Outcome.SKIPPED).len()
        local stopped = clock();

        local took = ((stopped - started) * 1000) + "ms"

        reporter.end(passed, failed, skipped, took)
    }
}

reporter <- ConsoleReporter()

local env = getenv("NUTKIN_ENV");

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

    constructor(title, suite) {
        nutkin.addSuite(title, suite)
        nutkin.runTests()
    }
}
