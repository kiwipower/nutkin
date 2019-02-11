class SuiteBuilder {
    static function skip(suiteName, suite) {
        SuiteBuilder(suiteName, suite, true)
    }

    static function only(suiteName, suite) {
        SuiteBuilder(suiteName, suite, false, true)
    }

    constructor(suiteName, suite, skipped = false, only = false) {
        Suite(suiteName, suite, suiteStack.top(), skipped, only, testPattern).parse()
    }
}
