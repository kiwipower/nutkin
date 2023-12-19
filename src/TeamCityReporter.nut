class TeamCityReporter extends Reporter {

    function escapeText(text) {
        // Team city needs messages to be escaped
        // escaped_value uses substitutions: '->|', [->|[, ]->|], |->||, newline->|n

        local subs = {
            "'": "|'",
            "[": "|[",
            "]": "|[",
            "|": "||",
            "\n": "|n"
        }

        local escaped = "";
        for (local index = 0; index < text.len(); index++) {
            // Can't use the char value as its literally a uint8 - not so good as a string
            local substr = text.slice(index, index + 1);
            if (substr in subs) {
                escaped += subs[substr];
            } else {
                escaped += substr;
            }
        }
        return escaped;
    }

    function suiteStarted(name) {
        print("##teamcity[testSuiteStarted name='" + escapeText(name) + "']")
    }

    function suiteFinished(name) {
        print("##teamcity[testSuiteFinished name='" + escapeText(name) + "']")
    }

    function suiteError(name, error, stack = "") {
        print("##teamcity[message text='suiteError: " + escapeText(error) + "' status='ERROR' errorDetails='" + escapeText(stack) + "']")
        suiteFinished(name)
    }

    function testStarted(name) {
        print("##teamcity[testStarted name='" + escapeText(name) + "'] captureStandardOutput='true'")
    }

    function testFinished(name) {
        print("##teamcity[testFinished name='" + escapeText(name) + "']")
    }

    function testFailed(name, failure, stack = "") {
        print("##teamcity[testFailed name='" + escapeText(name) + "' message='" + escapeText(safeGetErrorMessage(failure)) + "' details='" + escapeText(safeGetErrorDescription(failure)) + "']")
        testFinished(name)
    }

    function doNotReportIndividualTestFailures() {
        return true
    }

    function testSkipped(name) {
        print("##teamcity[testIgnored name='" + escapeText(name) + "']")
    }
}

reporters["TEAM_CITY"] <- TeamCityReporter()
