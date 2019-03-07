#!/bin/bash

rm -rf ./node_modules/@theforeman
mkdir -p ./node_modules/@theforeman

ln -s ../../../foreman-js/packages/vendor-core ./node_modules/@theforeman/vendor-core
ln -s ../../../foreman-js/packages/vendor-dev ./node_modules/@theforeman/vendor-dev
ln -s ../../../foreman-js/packages/vendor ./node_modules/@theforeman/vendor
