class Reporter {
    printer = null
    testFailures = null
    suiteErrors = null

    constructor(printerImpl = Printer()) {
        printer = printerImpl
        testFailures = []
        suiteErrors = []
    }

    function isFailure(thing) {
        return thing instanceof Failure
    }

    function safeGetErrorMessage(thing) {
        local message = thing
        if (isFailure(thing)) {
            message = thing.message
        }
        return message
    }

    function safeGetErrorDescription(thing) {
        local description = ""
        if (isFailure(thing)) {
            description = thing.description
        }
        return description
    }

    function print(message) {
        printer.println(message)
    }

    function testHasFailed(name, failure, stack = "") {
        testFailed(name, failure, stack)

        if (!doNotReportIndividualTestFailures()) {
            testFailures.append(name)
        }
    }

    function suiteErrorDetected(name, error, stack = "") {
        suiteErrors.append(name)
        suiteError(name, error, stack)
    }

    // Subclasses to implement these methods
    function suiteStarted(name) {}
    function suiteFinished(name) {}
    function suiteError(name, error, stack = "")
    function testStarted(name) {}
    function testFinished(name) {}
    function testFailed(name, failure, stack = "") {}
    function doNotReportIndividualTestFailures() { return false }
    function testSkipped(name) {}
    function begin() {}
    function end(passed, failed, skipped, timeTaken) {}
    function listFailures() {}
}
