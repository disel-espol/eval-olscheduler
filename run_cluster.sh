#!/usr/bin/env bash

TEST_CLUSTER=c0
NUM_WORKERS=5
ADMIN=/home/ubuntu/open-lambda/bin/admin

SANDBOX='{"sandbox": "sock", "handler_cache_size": 0, "import_cache_size": 0, "cg_pool_size": 10, "sock_base_path": "/home/ubuntu/c0/base"}'
REGISTRY_DIR='{"registry_dir": "/home/ubuntu/pipbench/handlers_100_5/handlers"}'
# PIP_MIRROR='{"pip_mirror": "http://18.211.241.59:9199/simple/"}'
# PIP_MIRROR='{"pip_mirror": "http://18.211.241.59:9199/simple/ --trusted-host 18.211.241.59"}'
PIP_MIRROR='{"pip_mirror": "http://localhost:9199/simple/"}'

$ADMIN kill -cluster=$TEST_CLUSTER
rm -r $TEST_CLUSTER

$ADMIN new -cluster=$TEST_CLUSTER
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$SANDBOX'"
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$REGISTRY_DIR'"
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$PIP_MIRROR'"

$ADMIN workers -cluster=$TEST_CLUSTER -num-workers=$NUM_WORKERS -port=8081

$ADMIN status -cluster=$TEST_CLUSTER

chmod 777 -R $TEST_CLUSTER

