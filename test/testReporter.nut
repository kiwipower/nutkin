class TestReporter extends ConsoleReporter {
    expectedFailure = null

    function expectFailure(expected) {
        expectedFailure = expected
    }

    function testFailed(name, failure, stack = "") {
        if (expectedFailure && failure.tostring() == expectedFailure) {
            base.testFinished(name)
            return false
        }

        base.testFailed(name, failure, stack)
        return true
    }
}

function expectReportedFailure(message) {
    reporter.expectFailure(message)
}

reporters["NUTKIN_TEST"] <- TestReporter()

