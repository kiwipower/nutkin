#!/usr/bin/env bash

./build.sh
pleasebuild test/nutkin.spec.nut > build/nutkin.spec.nut
sq build/nutkin.spec.nut
sq build/nutkin.spec.nut pattern
