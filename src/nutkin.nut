class Nutkin {
    reporter = null
    runningSuites = 0
    passed = 0
    failed = 0
    skipped = 0
    skipNextSuite = false

    constructor(reporterInstance = ConsoleReporter()) {
        reporter = reporterInstance
    }

    function reset() {
        runningSuites = 0
        passed = 0
        failed = 0
        skipped = 0
        skipNextSuite = false
    }

    function runSuite(name, suite) {
        runningSuites++
        reporter.suiteStarted(name)

        try {
            suite()
            reporter.suiteFinished(name, "")
        } catch (e) {
            reporter.suiteFinished(name, e, ::stackTrace())
        }

        runningSuites--
        skipNextSuite = false

        if (runningSuites == 0) {
            local timeTaken = time() - startTime
            reporter.stats(passed, failed, skipped, timeTaken)
            reset();
        }
    }

    function runSpec(name, spec) {
        if (skipNextSuite) {
            skipSpec(name)
        } else {
            reporter.testStarted(name)
            try {
                spec()
                passed++
                reporter.testFinished(name)
            } catch (e) {
                local stack = ""
                if (typeof e == typeof "") {
                    e = Failure(e)
                    stack = "\nStack: " + ::stackTrace()
                }
                if (reporter.testFailed(name, e, stack)) {
                    failed++
                } else {
                    passed++
                }
            }
        }
    }

    function skipSpec(name) {
        skipped++
        reporter.testSkipped(name)
    }

    function skipSuite(name) {
        skipNextSuite = true;
    }
}

reporter <- ConsoleReporter()

local env = getenv("NUTKIN_ENV");

try {
    if (env && env != "" && reporters[env]) {
        reporter <- reporters[env]
    }
} catch (e) {
    throw "ERROR: Invalid NUTKIN_ENV: " + env
}

nutkin <- Nutkin(reporter)
startTime <- time()

class describe {

    static function skip(title, suite) {
        nutkin.skipSuite(title);
        describe(title, suite)
    }

    constructor(title, suite) {
        nutkin.runSuite(title, suite)
    }
}

class it {

    static function skip(title, spec) {
        nutkin.skipSpec(title);
    }

    constructor(title, spec) {
        nutkin.runSpec(title, spec)
    }
}
