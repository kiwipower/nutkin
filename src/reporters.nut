class BasicReporter {

    function safeGetErrorMessage(thing) {
        local message = thing
        if (typeof thing == typeof {}) {
            message = thing.message
        }
        return message
    }

    function safeGetErrorDescription(thing) {
        local description = ""
        if (typeof thing == typeof {}) {
            description = thing.description
        }
        return description
    }

    function print(message) {
        ::println(message)
    }

    function suiteStarted(name) {
        print("Test Suite started: " + name)
    }

    function suiteFinished(name, error = "", details = "") {
        if (error == "") {
            print("Test Suite finished: " + name)
        } else {
            print("")
            print("Test Suite FAILED: " + name)
            print("Error: " + error)
            if (details != "") {
                print(details)
            }
        }
        print("")
    }

    function testStarted(name) {
        print("Test started: " + name)
    }

    function testFinished(name) {
        print("Test finished: " + name)
    }

    function testFailed(name, failure) {
        print("Test failed: " + name + ", error: " + safeGetErrorMessage(failure) + ", details: " + safeGetErrorDescription(failure))
    }

    function testSkipped(name) {
        print("Test skipped: " + name)
    }

    function stats(passed, failed, skipped, timeTaken) {
        print("Passed: " + passed + ", failed: " + failed + ", skipped: " + skipped + " (" + timeTaken + "ms)")
    }
}

class ConsoleReporter extends BasicReporter {
    indent = 0
    bold = "\x1B[1m"
    titleColour = "\x1B[30m"
    testColour = "\x1B[38;5;240m"
    passColour = "\x1B[32m"
    failColour = "\x1B[31m"
    skipColour = "\x1B[33m"
    errorColour = "\x1B[1;31m"
    logColour = "\x1B[36m"
    reset = "\x1B[0m"

    function padding() {
        local output = ""
        for (local i=0;i<indent;i+=1){
            output += "  "
        }
        return output
    }

    function print(message) {
        ::println(padding() + message + reset + logColour)
    }

    function suiteStarted(name) {
        indent ++;
        print("")
        print(titleColour + name)
    }

    function suiteFinished(name, error = "", details = "") {
        indent --;
    }

    function testStarted(name) {
        indent ++;
    }

    function testFinished(name) {
        print(passColour + "✓ " + testColour + name)
        indent --;
    }

    function testFailed(name, failure) {
        print(failColour + "✗ " + name)
        print(failColour + bold + safeGetErrorMessage(failure))
        local desc = safeGetErrorDescription(failure)
        if (desc != "") {
            print(skipColour + desc)
        }
        indent --;
    }

    function testSkipped(name) {
        indent++;
        print(skipColour + "➾ " + name)
        indent--;
    }

    function stats(passed, failed, skipped, timeTaken) {
        indent++
        print("")
        print(passColour + passed + " passing")
        if (failed > 0) {
            print(failColour + failed + " failing")
        }
        if (skipped > 0) {
            print(skipColour + skipped + " skipped")
        }
        ::println(reset)
        ::println("Done in " + timeTaken + "ms")
    }
}

class TeamCityReporter extends BasicReporter {

    function suiteStarted(name) {
        print("##teamcity[testSuiteStarted name='" + name + "']")
    }

    function suiteFinished(name, error = "", details = "") {
        print("##teamcity[testSuiteFinished name='" + name + "']")

        if (error != "") {
            print("##teamcity[message text='" + error + "' status='ERROR' errorDetails='" + details + "']")
        }
    }

    function testStarted(name) {
        print("##teamcity[testStarted name='" + name + "']")
    }

    function testFinished(name) {
        print("##teamcity[testFinished name='" + name + "']")
    }

    function testFailed(name, failure) {
        print("##teamcity[testFailed name='" + name + "' message='" + safeGetErrorMessage(failure) + "' details='" + safeGetErrorDescription(failure) + "']")
        testFinished(name)
    }

    function testSkipped(name) {
        print("##teamcity[testIgnored name='" + name + "']")
    }

    function stats(passed, failed, skipped, timeTaken) {
        // TeamCity does this for us
    }
}
