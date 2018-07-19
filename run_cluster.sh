#!/usr/bin/env bash

TEST_CLUSTER=c0
NUM_WORKERS=5
ADMIN=/home/ubuntu/open-lambda/bin/admin

SANDBOX='{"sandbox": "sock"}'
REGISTRY_DIR='{"registry_dir": "/home/ubuntu/pipbench/handlers_100_5/handlers"}'
PIP_MIRROR='{"pip_mirror": "http://34.198.251.213:9199/simple/"}'

$ADMIN kill -cluster=$TEST_CLUSTER
rm -r $TEST_CLUSTER

$ADMIN new -cluster=$TEST_CLUSTER
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$SANDBOX'"
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$REGISTRY_DIR'"
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$PIP_MIRROR'"

$ADMIN workers -cluster=$TEST_CLUSTER -num-workers=$NUM_WORKERS -port=8081

$ADMIN status -cluster=$TEST_CLUSTER

