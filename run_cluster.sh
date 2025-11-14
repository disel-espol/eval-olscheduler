#!/usr/bin/env bash

# ⚠️ OBSOLETO - ESTE SCRIPT USA COMANDOS QUE YA NO EXISTEN EN OPENLAMBDA MODERNO
# ⚠️ Por favor usa los scripts modernizados en: docker/run_cluster_modern.sh
# ⚠️ Ver: docker/README.md para instrucciones actualizadas
# ⚠️ Ver: MIGRATION_GUIDE.md para entender los cambios

echo "======================================================================"
echo "⚠️  ADVERTENCIA: Este script usa comandos obsoletos de OpenLambda"
echo "⚠️  Los comandos 'admin new' y 'admin workers' ya no existen"
echo ""
echo "✅  USA EN SU LUGAR: docker/run_cluster_modern.sh"
echo "✅  Ver guía completa: docker/README.md"
echo "======================================================================"
echo ""
echo "Presiona Ctrl+C para cancelar, o espera 5 segundos para continuar..."
sleep 5

TEST_CLUSTER=c0
NUM_WORKERS=5
ADMIN=/root/olscheduler-experiment/open-lambda/bin/admin

SANDBOX='{"sandbox": "sock", "handler_cache_size": 0, "import_cache_size": 0, "cg_pool_size": 10, "sock_base_path": "./c0/base"}'
REGISTRY_DIR='{"registry_dir": "/root/olscheduler-experiment/pipbench/handlers"}'
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

