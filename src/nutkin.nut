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
                failed++
                reporter.testFailed(name, e)
                throw e
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

reporter <- getenv("NUTKIN_ENV") == "TEAM_CITY" ? TeamCityReporter() : ConsoleReporter()
nutkin <- Nutkin(reporter)
startTime <- time()

function describe(title, suite) {
    nutkin.runSuite(title, suite)
}

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
