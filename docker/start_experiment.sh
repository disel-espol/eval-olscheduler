#!/bin/bash
# Script orquestador master para el experimento Package Aware Scheduler
# Este script automatiza todo el flujo: setup, inicio de workers, scheduler y workload

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   Experimento Package Aware Scheduler (pkg-aware)         ║"
echo "║   Script Orquestador Master                                ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Configuración
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OL_ADMIN=${OL_ADMIN:-/root/olscheduler-experiment/open-lambda/bin/admin}
OLSCHEDULER_BIN=${OLSCHEDULER_BIN:-/tmp/olscheduler-build/bin/olscheduler}
OLSCHEDULER_CONFIG=${OLSCHEDULER_CONFIG:-/tmp/olscheduler.json}
WORKLOAD_FILE=${WORKLOAD_FILE:-/tmp/1000handlers.json}
NUM_REQUESTS=${NUM_REQUESTS:-100}

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables de estado
WORKERS_STARTED=false
SCHEDULER_STARTED=false
SCHEDULER_PID=""

# Función de limpieza
cleanup() {
    echo ""
    echo -e "${YELLOW}Limpiando recursos...${NC}"
    
    # Detener OLScheduler
    if [ ! -z "$SCHEDULER_PID" ]; then
        echo "Deteniendo OLScheduler (PID: $SCHEDULER_PID)..."
        kill $SCHEDULER_PID 2>/dev/null || true
        wait $SCHEDULER_PID 2>/dev/null || true
    fi
    
    # Detener workers
    if [ "$WORKERS_STARTED" = true ]; then
        echo "Deteniendo workers de OpenLambda..."
        for port in 8081 8082 8083 8084 8085; do
            worker_dir="/tmp/ol-workers/worker-${port}"
            if [ -d "${worker_dir}" ]; then
                cd "${worker_dir}" && ${OL_ADMIN} worker down > /dev/null 2>&1 || true
            fi
        done
    fi
    
    echo -e "${GREEN}✓ Recursos liberados${NC}"
}

# Configurar trap para limpieza al salir
trap cleanup EXIT INT TERM

# Función para verificar prerequisitos
check_prerequisites() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}PASO 1: Verificando prerequisitos${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local all_ok=true
    
    # Verificar OpenLambda admin
    if [ -f "${OL_ADMIN}" ]; then
        echo -e "${GREEN}✓${NC} OpenLambda admin encontrado: ${OL_ADMIN}"
    else
        echo -e "${RED}✗${NC} OpenLambda admin no encontrado: ${OL_ADMIN}"
        all_ok=false
    fi
    
    # Verificar OLScheduler
    if [ -f "${OLSCHEDULER_BIN}" ]; then
        echo -e "${GREEN}✓${NC} OLScheduler encontrado: ${OLSCHEDULER_BIN}"
    else
        echo -e "${RED}✗${NC} OLScheduler no encontrado: ${OLSCHEDULER_BIN}"
        all_ok=false
    fi
    
    # Verificar archivo de configuración
    if [ -f "${OLSCHEDULER_CONFIG}" ]; then
        echo -e "${GREEN}✓${NC} Configuración de OLScheduler: ${OLSCHEDULER_CONFIG}"
    else
        echo -e "${RED}✗${NC} Configuración no encontrada: ${OLSCHEDULER_CONFIG}"
        all_ok=false
    fi
    
    # Verificar archivo de workload
    if [ -f "${WORKLOAD_FILE}" ]; then
        echo -e "${GREEN}✓${NC} Archivo de workload: ${WORKLOAD_FILE}"
    else
        echo -e "${RED}✗${NC} Archivo de workload no encontrado: ${WORKLOAD_FILE}"
        all_ok=false
    fi
    
    # Verificar Python3
    if command -v python3 > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Python3 disponible"
    else
        echo -e "${RED}✗${NC} Python3 no encontrado"
        all_ok=false
    fi
    
    # Verificar módulo requests
    if python3 -c "import requests" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Módulo Python 'requests' instalado"
    else
        echo -e "${RED}✗${NC} Módulo Python 'requests' no encontrado"
        all_ok=false
    fi
    
    # Verificar puertos disponibles
    local ports_ok=true
    for port in 8080 8081 8082 8083 8084 8085; do
        if lsof -i :${port} > /dev/null 2>&1; then
            echo -e "${RED}✗${NC} Puerto ${port} está en uso"
            ports_ok=false
            all_ok=false
        fi
    done
    if [ "$ports_ok" = true ]; then
        echo -e "${GREEN}✓${NC} Todos los puertos requeridos están disponibles (8080-8085)"
    fi
    
    echo ""
    
    if [ "$all_ok" = false ]; then
        echo -e "${RED}ERROR: Faltan prerequisitos. Por favor, completa el setup antes de continuar.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Todos los prerequisitos están satisfechos${NC}"
    echo ""
}

# Función para iniciar workers
start_workers() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}PASO 2: Iniciando Workers de OpenLambda${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ -f "${SCRIPT_DIR}/run_cluster_modern.sh" ]; then
        ${SCRIPT_DIR}/run_cluster_modern.sh
        WORKERS_STARTED=true
    else
        echo -e "${RED}ERROR: Script de workers no encontrado: ${SCRIPT_DIR}/run_cluster_modern.sh${NC}"
        exit 1
    fi
    
    echo ""
}

# Función para iniciar OLScheduler
start_scheduler() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}PASO 3: Iniciando OLScheduler${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo "Iniciando OLScheduler en background..."
    cd $(dirname ${OLSCHEDULER_BIN})
    ${OLSCHEDULER_BIN} start -c ${OLSCHEDULER_CONFIG} > /tmp/olscheduler.log 2>&1 &
    SCHEDULER_PID=$!
    SCHEDULER_STARTED=true
    
    echo "Esperando 5 segundos para que OLScheduler se inicialice..."
    sleep 5
    
    # Verificar que está corriendo
    if ps -p $SCHEDULER_PID > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OLScheduler iniciado (PID: $SCHEDULER_PID)${NC}"
        
        # Verificar endpoint
        if curl -s http://localhost:8080/status > /dev/null 2>&1; then
            echo -e "${GREEN}✓ OLScheduler responde en http://localhost:8080${NC}"
        else
            echo -e "${YELLOW}⚠ OLScheduler está corriendo pero no responde en el puerto 8080${NC}"
        fi
    else
        echo -e "${RED}✗ OLScheduler falló al iniciar${NC}"
        echo "Ver logs en: /tmp/olscheduler.log"
        tail -20 /tmp/olscheduler.log
        exit 1
    fi
    
    echo ""
}

# Función para ejecutar workload
run_workload() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}PASO 4: Ejecutando Workload del Experimento${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ -f "${SCRIPT_DIR}/run_workload_modern.sh" ]; then
        export NUM_REQUESTS=${NUM_REQUESTS}
        export WORKLOAD_FILE=${WORKLOAD_FILE}
        ${SCRIPT_DIR}/run_workload_modern.sh
    else
        echo -e "${RED}ERROR: Script de workload no encontrado: ${SCRIPT_DIR}/run_workload_modern.sh${NC}"
        exit 1
    fi
    
    echo ""
}

# Función principal
main() {
    echo -e "${CYAN}Inicio del experimento: $(date)${NC}"
    echo ""
    
    # Paso 1: Verificar prerequisitos
    check_prerequisites
    
    # Paso 2: Iniciar workers
    start_workers
    
    # Paso 3: Iniciar scheduler
    start_scheduler
    
    # Paso 4: Ejecutar workload
    run_workload
    
    # Resumen final
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ EXPERIMENTO COMPLETADO EXITOSAMENTE${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Resultados guardados en: /tmp/experiment_results.log"
    echo "Logs de OLScheduler: /tmp/olscheduler.log"
    echo "Logs de Workers: /tmp/ol-workers/worker-*/worker.out"
    echo ""
    echo -e "${CYAN}Fin del experimento: $(date)${NC}"
    echo ""
}

# Ejecutar función principal
main

