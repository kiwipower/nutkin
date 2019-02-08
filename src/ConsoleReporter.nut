class ConsoleReporter extends Reporter {
    indent = 0
    bold = "\x1B[1m"
    titleColour = "\x1B[34m"
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
        printer.println(padding() + message + reset + logColour)
    }

    function suiteStarted(name) {
        indent++
        print(titleColour + name)
    }

    function suiteFinished(name) {
        indent--
        print("")
    }

    function suiteError(name, error, stack = "") {
        print(failColour + bold + error)

        if(stack != "") {
            print(failColour + stack)
        }

        suiteFinished(name)
    }

    function testStarted(name) {
        indent++
    }

    function testFinished(name) {
        print(passColour + "✓ " + testColour + name)
        indent--
    }

    function testFailed(name, failure, stack = "") {
        print(failColour + "✗ " + name)
        print(failColour + bold + safeGetErrorMessage(failure))
        if (stack != "") {
            print(failColour + stack)
        }
        local desc = safeGetErrorDescription(failure)
        if (desc != "") {
            print(skipColour + desc)
        }
        indent--
    }

    function testSkipped(name) {
        indent++
        print(skipColour + "➾ " + name)
        indent--
    }

    function begin() {
        printer.println("")
    }

    function end(passed, failed, skipped, timeTaken) {
        indent++
        print(passColour + passed + " passing")
        if (failed > 0) {
            print(failColour + failed + " failing")
        }
        if (skipped > 0) {
            print(skipColour + skipped + " skipped")
        }
        printer.println(reset)
        listFailures()
        print("Took " + timeTaken)
        printer.print(reset)
        indent--
    }

    function listFailures() {
        if (testFailures.len() > 0) {
            print(failColour + "TEST FAILURES:")
            indent++
            foreach (failure in testFailures) {
                print(failColour + "✗ " + failure)
            }
            printer.println(reset)
            indent--
        }

        if(suiteErrors.len() > 0) {
            print(failColour + "SUITE ERRORS:")
            indent++
            foreach (failure in suiteErrors) {
                print(failColour + "✗ " + failure)
            }
            printer.println(reset)
            indent--
        }
    }
}
