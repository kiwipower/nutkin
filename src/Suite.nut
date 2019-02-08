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
