#!/usr/bin/env bash

export NUTKIN_ENV="NUTKIN_TEST"

./build.sh
pleasebuild test/testPrinter.nut >> build/nutkin.nut

pleasebuild test/nutkin-spec.nut > build/nutkin-spec.nut

# Run the tests
sq build/nutkin-spec.nut