class Nutkin {
    reporter = null
    runningSuites = 0
    passed = 0
    failed = 0
    skipped = 0

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

        if (runningSuites == 0) {
            local timeTaken = time() - startTime
            reporter.stats(passed, failed, skipped, timeTaken)
        }
    }

    function runSpec(name, spec) {
        reporter.testStarted(name)
        try {
            spec()
            passed++;
            reporter.testFinished(name)
        } catch (e) {
            failed++;
            reporter.testFailed(name, e)
            throw e
        }
    }
}

reporter <- getenv("NUTKIN_ENV") == "TEAM_CITY" ? TeamCityReporter() : ConsoleReporter()
nutkin <- Nutkin(reporter)
startTime <- time()

function describe(title, suite) {
    nutkin.runSuite(title, suite)
}

function it(title, spec) {
    nutkin.runSpec(title, spec)
}