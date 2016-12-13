#!/usr/bin/env bash

./build.sh

# Run the tests
export NUTKIN_ENV=NUTKIN_TEST
sq build/nutkin-spec.nut