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
        if (parent) {
            parent.runBefores()
        }

        if (beforeFunc) {
            beforeFunc()
        }
    }

    function runAfters() {
        if (afterFunc) {
            afterFunc()
        }

        if (parent) {
            parent.runAfters()
        }
    }

    function run(reporter, onlyMode) {
        if (onlyMode && !only) {
            return []
        }

        local explicitOnlyInChild = hasAnOnlyDescendant()
        local outcomes = []

        reporter.suiteStarted(name)

        try {
            foreach(runnable in runQueue) {
                runBefores()
                outcomes.extend(runnable.run(reporter, explicitOnlyInChild ? only : false))
                runAfters()
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
