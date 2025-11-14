#!/usr/bin/env bash

# ⚠️ OBSOLETO - ESTE SCRIPT ES PARA SETUP ANTIGUO
# ⚠️ Por favor usa: docker/run_workload_modern.sh
# ⚠️ Ver: docker/README.md para instrucciones actualizadas

echo "======================================================================"
echo "⚠️  ADVERTENCIA: Este script es para el setup antiguo"
echo ""
echo "✅  USA EN SU LUGAR: docker/run_workload_modern.sh"
echo "✅  Ver guía completa: docker/README.md"
echo "======================================================================"
echo ""
echo "Presiona Ctrl+C para cancelar, o espera 5 segundos para continuar..."
sleep 5

PIPBENCH_WORKLOAD=/root/olscheduler-experiment/pipbench/evaluation/run_workload.py
echo $PIPBENCH_WORKLOAD

python3 $PIPBENCH_WORKLOAD ./1000handlers.json

