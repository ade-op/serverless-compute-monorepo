#!/usr/bin/env bash
set -e

mkdir -p build

cd app/ingest_lambda
zip -r ../../build/ingest_lambda.zip .
cd ../worker_lambda
zip -r ../../build/worker_lambda.zip .
cd ../../