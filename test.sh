#!/usr/bin/env bash

if [ "$NUTKIN_ENV" = "" ]
then
    export NUTKIN_ENV="NUTKIN_TEST"
fi

./build.sh
pleasebuild test/testPrinter.nut >> build/nutkin.nut

pleasebuild test/nutkin-spec.nut > build/nutkin-spec.nut

# Run the tests
sq build/nutkin-spec.nut