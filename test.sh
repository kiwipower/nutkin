#!/usr/bin/env bash

export NUTKIN_ENV=NUTKIN_TEST

./build.sh

# Run the tests
sq build/nutkin-spec.nut