class TestReporter extends ConsoleReporter {
    expectedFailure = null


    function compareMessages(expected, actual) {
        
        local unformat = function(str) {
            // Removing all the return/etc characters
            local noSpecials = split(str, "\n\t\r");
            // Reduce back to a string
            noSpecials = noSpecials.reduce(@(p, c) p + c);

            // Remove all the whitespace characters
            local noWhitespace = split(noSpecials, " ");

            // Reduce back to a string with a single space
            local singleSpace = noWhitespace.reduce(@(p, c) p + " " + c);

            // Strip whitespace from start and end
            singleSpace = strip(singleSpace);

            return singleSpace;
        }

        return (unformat(expected) == unformat(actual));
    }

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
        if (expectedFailure && compareMessages(failure.tostring(), expectedFailure)) {
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

reporters["NUTKIN_TEST"] <- TestReporter(Printer())
