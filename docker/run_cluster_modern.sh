#!/bin/bash
# Script modernizado para iniciar múltiples workers de OpenLambda
# Compatible con OpenLambda versión moderna (ol worker init/up commands)
# Usa sandbox Docker con Docker-in-Docker

set -e

echo "================================================"
echo "  Iniciando Cluster de OpenLambda (Moderno)"
echo "================================================"
echo ""

# Configuración
OL=${OL_ADMIN:-/root/olscheduler-experiment/open-lambda/bin/admin}
BASE_DIR=${OL_BASE_DIR:-/tmp/ol-workers}
PORTS=(8081 8082 8083 8084 8085)

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar que el binario de OpenLambda existe
if [ ! -f "${OL}" ]; then
    echo -e "${RED}Error: OpenLambda admin no encontrado en ${OL}${NC}"
    echo "Asegúrate de haber compilado OpenLambda primero."
    exit 1
fi

echo -e "${BLUE}1. Deteniendo workers existentes...${NC}"
for port in ${PORTS[@]}; do
    worker_dir="${BASE_DIR}/worker-${port}"
    if [ -d "${worker_dir}" ]; then
        echo "   Deteniendo worker en puerto ${port}..."
        cd "${worker_dir}" && ${OL} worker down > /dev/null 2>&1 || true
    fi
done
echo -e "${GREEN}✓ Workers detenidos${NC}"
echo ""

echo -e "${BLUE}2. Limpiando directorios de workers...${NC}"
rm -rf "${BASE_DIR}"/*
echo -e "${GREEN}✓ Directorios limpiados${NC}"
echo ""

echo -e "${BLUE}3. Inicializando workers...${NC}"
for port in ${PORTS[@]}; do
    worker_dir="${BASE_DIR}/worker-${port}"
    mkdir -p "${worker_dir}"
    echo "   Inicializando worker-${port}..."
    cd "${worker_dir}"
    ${OL} worker init --path=. > /dev/null 2>&1
    
    # Actualizar config.json para usar el puerto correcto y sandbox docker
    python3 -c "
import json
config_path = '${worker_dir}/config.json'
with open(config_path, 'r') as f:
    config = json.load(f)
    
# Configurar puerto
config['worker_port'] = str(${port})

# Configurar sandbox docker
config['sandbox'] = 'docker'

# Deshabilitar import_cache para sandbox docker (requerido)
if 'features' not in config:
    config['features'] = {}
config['features']['import_cache'] = False

# Guardar configuración
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)
" || {
        echo -e "${RED}Error configurando worker ${port}${NC}"
        exit 1
    }
    
    echo -e "   ${GREEN}✓ Worker ${port} configurado${NC}"
done
echo ""

echo -e "${BLUE}4. Iniciando workers en background...${NC}"
for port in ${PORTS[@]}; do
    worker_dir="${BASE_DIR}/worker-${port}"
    echo "   Iniciando worker en puerto ${port}..."
    cd "${worker_dir}"
    ${OL} worker up --path=. --detach > worker-${port}.log 2>&1 &
done
echo -e "${GREEN}✓ Todos los workers iniciados${NC}"
echo ""

echo -e "${YELLOW}⏳ Esperando 10 segundos para que los workers se inicialicen...${NC}"
sleep 10
echo ""

echo -e "${BLUE}5. Verificando estado de los workers...${NC}"
SUCCESS_COUNT=0
for port in ${PORTS[@]}; do
    status_output=$(curl -s http://localhost:${port}/status 2>/dev/null || echo "ERROR")
    if echo "$status_output" | grep -q "ready"; then
        echo -e "   ${GREEN}✓ Worker ${port}: http://localhost:${port}/status => ready${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "   ${RED}✗ Worker ${port}: http://localhost:${port}/status => ERROR${NC}"
        echo "      Log: $(tail -3 "${BASE_DIR}/worker-${port}/worker.out" 2>/dev/null || echo 'No log available')"
    fi
done
echo ""

echo -e "${BLUE}6. Verificando puertos en uso:${NC}"
if command -v lsof > /dev/null 2>&1; then
    lsof -i :8081-8085 2>/dev/null | grep LISTEN || echo "   (No se pudo verificar con lsof)"
else
    echo "   (lsof no disponible para verificación)"
fi
echo ""

echo "================================================"
if [ $SUCCESS_COUNT -eq 5 ]; then
    echo -e "${GREEN}✓ Cluster iniciado exitosamente (5/5 workers)${NC}"
    echo ""
    echo "Puedes verificar el estado con:"
    echo "  curl http://localhost:8081/status"
    echo "  curl http://localhost:8082/status"
    echo "  ... (etc)"
else
    echo -e "${YELLOW}⚠ Cluster iniciado parcialmente (${SUCCESS_COUNT}/5 workers)${NC}"
    echo ""
    echo "Revisa los logs en:"
    echo "  ${BASE_DIR}/worker-*/worker.out"
fi
echo "================================================"
echo ""

