class PredicateSuite {
    describe = null;

    constructor(condition) {
        if(condition) {
            describe = SuiteBuilder
        } else {
            describe = NotApplicableSuite
        }
    }
}
