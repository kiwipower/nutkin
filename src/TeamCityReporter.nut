class TeamCityReporter extends Reporter {

    function suiteStarted(name) {
        print("##teamcity[testSuiteStarted name='" + name + "']")
    }

    function suiteFinished(name) {
        print("##teamcity[testSuiteFinished name='" + name + "']")
    }

    function suiteError(name, error, stack = "") {
        print("##teamcity[message text='suiteError: " + error + "' status='ERROR' errorDetails='" + stack + "']")
        suiteFinished(name)
    }

    function testStarted(name) {
        print("##teamcity[testStarted name='" + name + "'] captureStandardOutput='true'")
    }

    function testFinished(name) {
        print("##teamcity[testFinished name='" + name + "']")
    }

    function testFailed(name, failure, stack = "") {
        print("##teamcity[testFailed name='" + name + "' message='" + safeGetErrorMessage(failure) + "' details='" + safeGetErrorDescription(failure) + "']")
        testFinished(name)
    }

    function doNotReportIndividualTestFailures() {
        return true
    }

    function testSkipped(name) {
        print("##teamcity[testIgnored name='" + name + "']")
    }
}

reporters["TEAM_CITY"] <- TeamCityReporter()
