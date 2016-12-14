class TestReporter extends ConsoleReporter {
    expectedFailure = null

    function expectFailure(expected) {
        expectedFailure = expected
    }

    function testStarted(name) {
        expectedFailure = null
        base.testStarted(name)
    }

    function testFinished(name) {
        if (expectedFailure) {
            base.testFailed(name, "Expected failure message but did not get one: " + expectedFailure)
        } else {
            base.testFinished(name)
        }
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

