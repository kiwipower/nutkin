class NotApplicableSuite {
    static function skip(suiteName, suite) {
        NotApplicableSuite(suiteName, suite)
    }

    static function only(suiteName, suite) {
        NotApplicableSuite(suiteName, suite)
    }

    constructor(suiteName, suite) {
        reporter.print("Not applicable suite: "+ suiteName)
    }
}
