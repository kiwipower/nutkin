class SpecBuilder {
    static function skip(specName, spec) {
        SpecBuilder(specName, spec, true)
    }

    static function only(specName, spec) {
        SpecBuilder(specName, spec, false, true)
    }

    constructor(specName, spec, skipped = false, only = false) {
        Spec(specName, spec, suiteStack.top(), skipped, only)
    }
}
