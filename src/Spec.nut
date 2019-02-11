class Spec {
    name = null
    suite = null
    specBody = null
    skipped = null
    only = null
    _pattern = null

    constructor(specName, spec, parentSuite, isSkipped = false, isOnly = false, testPattern = "") {
        name = specName
        suite = parentSuite
        specBody = spec
        skipped = isSkipped
        only = isOnly
        _pattern = testPattern

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
