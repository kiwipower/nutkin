#!/usr/bin/env bash

mkdir -p build
pleasebuild src/globals.nut > build/nutkin.nut
pleasebuild src/failure.nut >> build/nutkin.nut
pleasebuild src/reporters.nut >> build/nutkin.nut
pleasebuild src/expect.nut >> build/nutkin.nut
pleasebuild src/nutkin.nut >> build/nutkin.nut

pleasebuild test/nutkin-spec.nut > build/nutkin-spec.nut

# Run the tests
sq build/nutkin-spec.nut