#!/bin/bash
# Script modernizado para ejecutar workload del experimento
# Usa requests (sin grequests) para máxima compatibilidad

set -e

echo "================================================"
echo "  Ejecutando Workload del Experimento"
echo "================================================"
echo ""

# Configuración
OLSCHEDULER_URL=${OLSCHEDULER_URL:-http://localhost:8080}
WORKLOAD_FILE=${WORKLOAD_FILE:-/tmp/1000handlers.json}
NUM_REQUESTS=${NUM_REQUESTS:-100}
RESULTS_FILE=${RESULTS_FILE:-/tmp/experiment_results.log}
DELAY_MS=${DELAY_MS:-500}

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar que OLScheduler está disponible
echo -e "${BLUE}1. Verificando conexión con OLScheduler...${NC}"
if curl -s "${OLSCHEDULER_URL}/status" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ OLScheduler disponible en ${OLSCHEDULER_URL}${NC}"
else
    echo -e "${RED}✗ No se puede conectar con OLScheduler en ${OLSCHEDULER_URL}${NC}"
    echo "Asegúrate de que OLScheduler esté ejecutándose."
    exit 1
fi
echo ""

# Verificar que existe el archivo de workload
if [ ! -f "${WORKLOAD_FILE}" ]; then
    echo -e "${RED}✗ Archivo de workload no encontrado: ${WORKLOAD_FILE}${NC}"
    echo "Asegúrate de tener el archivo de configuración del workload."
    exit 1
fi

echo -e "${BLUE}2. Ejecutando workload...${NC}"
echo "   Archivo: ${WORKLOAD_FILE}"
echo "   Requests: ${NUM_REQUESTS}"
echo "   Delay: ${DELAY_MS}ms entre requests"
echo "   Resultados: ${RESULTS_FILE}"
echo ""

# Ejecutar workload con Python
python3 << EOF
import requests
import time
import json
import sys

# Configuración
config_path = "${WORKLOAD_FILE}"
num_requests = ${NUM_REQUESTS}
results_file = "${RESULTS_FILE}"
delay_seconds = ${DELAY_MS} / 1000.0
base_url = "${OLSCHEDULER_URL}"

# Cargar configuración de handlers
try:
    with open(config_path, "r") as f:
        config = json.load(f)
    handlers = config.get("handlers", [])
    
    if not handlers:
        print("ERROR: No se encontraron handlers en el archivo de configuración")
        sys.exit(1)
        
    print(f"Cargados {len(handlers)} handlers del archivo de configuración")
    print("")
except Exception as e:
    print(f"ERROR: No se pudo cargar el archivo de configuración: {e}")
    sys.exit(1)

# Estadísticas
success_count = 0
error_count = 0
latencies = []

print("Iniciando ejecución del workload...")
print("-" * 80)

# Ejecutar requests
with open(results_file, "w") as f_out:
    for i in range(num_requests):
        handler_name = handlers[i % len(handlers)]
        start_time = time.time()
        
        try:
            response = requests.post(
                f"{base_url}/run/{handler_name}",
                timeout=30
            )
            end_time = time.time()
            latency = int((end_time - start_time) * 1000)
            latencies.append(latency)
            
            # Registrar resultado
            timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
            log_line = f"[{timestamp}] handler: {handler_name} status: {response.status_code} latency: {latency} ms"
            
            # Mostrar cada 10 requests
            if (i + 1) % 10 == 0:
                print(f"Progress: {i + 1}/{num_requests} requests completed")
            
            f_out.write(log_line + "\\n")
            f_out.flush()
            
            if 200 <= response.status_code < 300 or response.status_code == 404:
                success_count += 1
            else:
                error_count += 1
                
        except requests.exceptions.RequestException as e:
            end_time = time.time()
            latency = int((end_time - start_time) * 1000)
            latencies.append(latency)
            error_count += 1
            
            timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
            log_line = f"[{timestamp}] handler: {handler_name} status: ERROR ({str(e)[:50]}) latency: {latency} ms"
            
            if (i + 1) % 10 == 0:
                print(f"Progress: {i + 1}/{num_requests} requests completed (errors: {error_count})")
            
            f_out.write(log_line + "\\n")
            f_out.flush()
        
        # Pequeño delay para no saturar
        if delay_seconds > 0:
            time.sleep(delay_seconds)

print("-" * 80)
print("")
print("Workload completado!")
print("")

# Calcular estadísticas
if latencies:
    latencies.sort()
    avg_latency = sum(latencies) / len(latencies)
    min_latency = min(latencies)
    max_latency = max(latencies)
    median_latency = latencies[len(latencies) // 2]
    p95_latency = latencies[int(len(latencies) * 0.95)]
    p99_latency = latencies[int(len(latencies) * 0.99)]
    
    print("=" * 80)
    print("ESTADÍSTICAS DEL EXPERIMENTO")
    print("=" * 80)
    print(f"Total de requests:       {num_requests}")
    print(f"Requests exitosos:       {success_count} ({success_count * 100 / num_requests:.1f}%)")
    print(f"Requests con error:      {error_count} ({error_count * 100 / num_requests:.1f}%)")
    print("")
    print("LATENCIAS:")
    print(f"  Promedio:              {avg_latency:.2f} ms")
    print(f"  Mediana:               {median_latency} ms")
    print(f"  Mínima:                {min_latency} ms")
    print(f"  Máxima:                {max_latency} ms")
    print(f"  Percentil 95:          {p95_latency} ms")
    print(f"  Percentil 99:          {p99_latency} ms")
    print("=" * 80)
    print("")
    print(f"Resultados detallados guardados en: {results_file}")
else:
    print("No se pudieron recopilar métricas de latencia")
    sys.exit(1)
EOF

echo ""
echo "================================================"
echo -e "${GREEN}✓ Workload completado exitosamente${NC}"
echo "================================================"
echo ""

