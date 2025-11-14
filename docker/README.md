# Experimento Package Aware Scheduler - Docker (Moderno)

Esta guía te ayudará a ejecutar el experimento **Package Aware Scheduler (pkg-aware)** usando Docker con scripts modernizados que funcionan con la versión actual de OpenLambda.

## Tabla de Contenidos

- [Por Qué Usar Esta Versión](#por-qué-usar-esta-versión)
- [Prerequisitos](#prerequisitos)
- [Guía Rápida](#guía-rápida)
- [Guía Detallada](#guía-detallada)
- [Personalización](#personalización)
- [Troubleshooting](#troubleshooting)
- [Diferencias con Scripts Antiguos](#diferencias-con-scripts-antiguos)

## Por Qué Usar Esta Versión

Los scripts en este directorio (`docker/`) son **modernizados y funcionales** con la versión actual de OpenLambda. Los scripts en el directorio raíz del repositorio usan comandos obsoletos que ya no funcionan.

**Ventajas de esta versión:**
- ✅ Usa comandos actuales de OpenLambda (`ol worker init/up`)
- ✅ Configuración via `config.json` (estándar moderno)
- ✅ Soporte para Docker-in-Docker
- ✅ Compatible con macOS (ARM64 y x86_64) y Linux
- ✅ Scripts validados en experimento real (latencia promedio: 5.9ms)
- ✅ Manejo automático de errores y verificaciones

## Prerequisitos

### 1. Docker Desktop (macOS/Windows) o Docker Engine (Linux)

**macOS:**
```bash
# Descargar Docker Desktop desde:
# https://www.docker.com/products/docker-desktop

# Verificar instalación:
docker --version
# Debe mostrar: Docker version 20.x.x o superior
```

**Linux:**
```bash
# Instalar Docker Engine:
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Verificar instalación:
docker --version
```

### 2. Recursos Mínimos

- **CPU:** 4 cores (recomendado: 8)
- **RAM:** 8 GB (recomendado: 16 GB)
- **Disco:** 20 GB libres

### 3. Archivos del Repositorio

Necesitas tener clonados tanto `eval-olscheduler` como `olscheduler`:

```bash
git clone https://github.com/disel-espol/eval-olscheduler.git
git clone https://github.com/disel-espol/olscheduler.git
```

## Guía Rápida

Si tienes Docker funcionando y los repositorios clonados, ejecuta:

```bash
# 1. Construir la imagen Docker
cd eval-olscheduler
docker build -f docker/Dockerfile.modern -t olscheduler-experiment:latest .

# 2. Crear y ejecutar el contenedor
docker run -itd --privileged \
  --name ol-experiment \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8080-8085:8080-8085 \
  olscheduler-experiment:latest

# 3. Copiar archivos de configuración
docker cp . ol-experiment:/root/olscheduler-experiment/eval-olscheduler
docker cp ../olscheduler ol-experiment:/root/olscheduler-experiment/olscheduler

# 4. Compilar OLScheduler dentro del contenedor
docker exec -it ol-experiment bash -c "
  cd /tmp && 
  git clone https://github.com/disel-espol/olscheduler.git olscheduler-build && 
  cd olscheduler-build && 
  go build -o bin/olscheduler .
"

# 5. Preparar archivos de configuración
docker exec -it ol-experiment bash -c "
  cp /root/olscheduler-experiment/eval-olscheduler/olscheduler.json /tmp/olscheduler.json &&
  mkdir -p /tmp/olscheduler-registries &&
  cp /root/olscheduler-experiment/eval-olscheduler/olscheduler-registries/registry_100_5.json /tmp/olscheduler-registries/ &&
  cp /root/olscheduler-experiment/eval-olscheduler/1000handlers.json /tmp/1000handlers.json
"

# 6. Ejecutar el experimento completo
docker exec -it ol-experiment bash -c "
  cd /root/olscheduler-experiment/eval-olscheduler/docker &&
  ./start_experiment.sh
"
```

## Guía Detallada

### Paso 1: Construir la Imagen Docker

La imagen incluye Ubuntu 20.04, Go, Python, Docker CLI, OpenLambda y Pipbench precompilados.

```bash
cd eval-olscheduler
docker build -f docker/Dockerfile.modern -t olscheduler-experiment:latest .
```

**Tiempo estimado:** 5-10 minutos (primera vez)

**Salida esperada:**
```
Successfully built <image_id>
Successfully tagged olscheduler-experiment:latest
```

### Paso 2: Crear el Contenedor

```bash
docker run -itd --privileged \
  --name ol-experiment \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8080-8085:8080-8085 \
  olscheduler-experiment:latest
```

**Explicación de parámetros:**
- `--privileged`: Necesario para Docker-in-Docker
- `-v /var/run/docker.sock:/var/run/docker.sock`: Monta el socket de Docker
- `-p 8080-8085:8080-8085`: Expone puertos del scheduler y workers

**Verificar que está corriendo:**
```bash
docker ps | grep ol-experiment
```

### Paso 3: Copiar Archivos de Configuración

```bash
# Copiar eval-olscheduler
docker cp . ol-experiment:/root/olscheduler-experiment/eval-olscheduler

# Copiar olscheduler (ajusta la ruta según tu estructura)
docker cp ../olscheduler ol-experiment:/root/olscheduler-experiment/olscheduler
```

### Paso 4: Compilar OLScheduler

```bash
docker exec -it ol-experiment bash -c "
  cd /tmp && 
  git clone https://github.com/disel-espol/olscheduler.git olscheduler-build && 
  cd olscheduler-build && 
  go build -o bin/olscheduler .
"
```

**Verificar compilación:**
```bash
docker exec -it ol-experiment /tmp/olscheduler-build/bin/olscheduler --help
```

### Paso 5: Preparar Configuraciones

```bash
docker exec -it ol-experiment bash -c "
  # Copiar configuración de OLScheduler
  cp /root/olscheduler-experiment/eval-olscheduler/olscheduler.json /tmp/olscheduler.json &&
  
  # Copiar registry de handlers
  mkdir -p /tmp/olscheduler-registries &&
  cp /root/olscheduler-experiment/eval-olscheduler/olscheduler-registries/registry_100_5.json /tmp/olscheduler-registries/ &&
  
  # Copiar archivo de workload
  cp /root/olscheduler-experiment/eval-olscheduler/1000handlers.json /tmp/1000handlers.json
"
```

### Paso 6: Ejecutar el Experimento

#### Opción A: Script Automatizado (Recomendado)

```bash
docker exec -it ol-experiment bash -c "
  cd /root/olscheduler-experiment/eval-olscheduler/docker &&
  ./start_experiment.sh
"
```

Este script orquesta todo el flujo automáticamente:
1. Verifica prerequisitos
2. Inicia 5 workers de OpenLambda
3. Inicia OLScheduler con balancer `pkg-aware`
4. Ejecuta workload de 100 requests
5. Muestra estadísticas finales

**Salida esperada:**
```
╔════════════════════════════════════════════════════════════╗
║   Experimento Package Aware Scheduler (pkg-aware)         ║
╚════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PASO 1: Verificando prerequisitos
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ OpenLambda admin encontrado
✓ OLScheduler encontrado
✓ Configuración de OLScheduler
✓ Archivo de workload
✓ Python3 disponible
✓ Módulo Python 'requests' instalado
✓ Todos los puertos requeridos disponibles

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PASO 2: Iniciando Workers de OpenLambda
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
...
✓ Cluster iniciado exitosamente (5/5 workers)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PASO 3: Iniciando OLScheduler
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ OLScheduler iniciado (PID: xxxx)
✓ OLScheduler responde en http://localhost:8080

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PASO 4: Ejecutando Workload del Experimento
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Progress: 10/100 requests completed
...
Progress: 100/100 requests completed

ESTADÍSTICAS DEL EXPERIMENTO
Total de requests:       100
Requests exitosos:       100 (100.0%)
Requests con error:      0 (0.0%)

LATENCIAS:
  Promedio:              5.9 ms
  Mediana:               6 ms
  Mínima:                4 ms
  Máxima:                9 ms
  Percentil 95:          8 ms
  Percentil 99:          9 ms

✓ EXPERIMENTO COMPLETADO EXITOSAMENTE
```

#### Opción B: Ejecución Manual (Más Control)

Si prefieres ejecutar cada componente manualmente:

**Terminal 1: Workers**
```bash
docker exec -it ol-experiment bash
cd /root/olscheduler-experiment/eval-olscheduler/docker
./run_cluster_modern.sh
```

**Terminal 2: OLScheduler**
```bash
docker exec -it ol-experiment bash
cd /tmp/olscheduler-build
./bin/olscheduler start -c /tmp/olscheduler.json
```

**Terminal 3: Workload**
```bash
docker exec -it ol-experiment bash
cd /root/olscheduler-experiment/eval-olscheduler/docker
./run_workload_modern.sh
```

### Paso 7: Ver Resultados

```bash
# Ver resultados del experimento
docker exec -it ol-experiment cat /tmp/experiment_results.log

# Ver logs de OLScheduler
docker exec -it ol-experiment cat /tmp/olscheduler.log

# Ver logs de un worker específico
docker exec -it ol-experiment cat /tmp/ol-workers/worker-8081/worker.out
```

## Personalización

### Cambiar el Número de Requests

```bash
export NUM_REQUESTS=500
docker exec -it ol-experiment bash -c "
  export NUM_REQUESTS=500 &&
  cd /root/olscheduler-experiment/eval-olscheduler/docker &&
  ./run_workload_modern.sh
"
```

### Cambiar el Algoritmo de Balanceo

Edita `/tmp/olscheduler.json` dentro del contenedor y cambia el campo `balancer`:

```json
{
  "balancer": "least-loaded"  // Opciones: pkg-aware, least-loaded, round-robin, random
}
```

Luego reinicia OLScheduler.

### Cambiar el Load Threshold

Para el algoritmo `pkg-aware`, puedes ajustar el `load-threshold`:

```json
{
  "balancer": "pkg-aware",
  "load-threshold": 50  // Valores comunes: 5, 50, 100, 150
}
```

## Troubleshooting

### Error: "Cannot connect to Docker daemon"

**Causa:** El socket de Docker no está montado correctamente.

**Solución:**
```bash
# Detener el contenedor
docker stop ol-experiment
docker rm ol-experiment

# Recrear con el socket montado
docker run -itd --privileged \
  --name ol-experiment \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8080-8085:8080-8085 \
  olscheduler-experiment:latest
```

### Error: "Port already in use"

**Causa:** Los puertos 8080-8085 están ocupados.

**Solución:**
```bash
# Ver qué proceso usa el puerto
lsof -i :8080

# Matar el proceso (reemplaza <PID> con el ID del proceso)
kill -9 <PID>

# O usar puertos diferentes al crear el contenedor
docker run -itd --privileged \
  --name ol-experiment \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 9080-9085:8080-8085 \
  olscheduler-experiment:latest
```

### Workers no inician correctamente

**Verificar logs:**
```bash
docker exec -it ol-experiment bash -c "
  for port in 8081 8082 8083 8084 8085; do
    echo '=== Worker $port ==='
    cat /tmp/ol-workers/worker-\${port}/worker.out
  done
"
```

**Reiniciar workers:**
```bash
docker exec -it ol-experiment bash -c "
  cd /root/olscheduler-experiment/eval-olscheduler/docker &&
  ./run_cluster_modern.sh
"
```

### OLScheduler no responde

**Verificar que está corriendo:**
```bash
docker exec -it ol-experiment ps aux | grep olscheduler
```

**Ver logs:**
```bash
docker exec -it ol-experiment cat /tmp/olscheduler.log
```

**Reiniciar OLScheduler:**
```bash
# Encontrar el PID
docker exec -it ol-experiment ps aux | grep olscheduler

# Matar el proceso
docker exec -it ol-experiment kill -9 <PID>

# Iniciar de nuevo
docker exec -it ol-experiment bash -c "
  cd /tmp/olscheduler-build &&
  ./bin/olscheduler start -c /tmp/olscheduler.json &
"
```

### Latencias muy altas

**Verificar carga del sistema:**
```bash
docker stats ol-experiment
```

**Reducir el número de requests concurrentes:**
```bash
export DELAY_MS=1000  # Aumentar delay entre requests
```

## Diferencias con Scripts Antiguos

| Aspecto | Scripts Antiguos (raíz) | Scripts Modernos (docker/) |
|---------|-------------------------|----------------------------|
| **Comandos OpenLambda** | `admin new -cluster`, `admin workers` | `ol worker init`, `ol worker up` |
| **Configuración** | Via CLI con `setconf` | Via `config.json` |
| **Sandbox** | `sock` (requiere cgroups) | `docker` (Docker-in-Docker) |
| **Estado** | ❌ Obsoletos, no funcionan | ✅ Actuales, funcionales |
| **Validación** | Sin validar | ✅ Validado en experimento real |
| **Documentación** | Mínima | ✅ Completa con ejemplos |

Para más detalles sobre la migración, consulta [MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md) en el directorio raíz.

## Soporte

Si encuentras problemas:

1. Revisa la sección [Troubleshooting](#troubleshooting)
2. Consulta [MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md)
3. Revisa los logs detallados en el contenedor
4. Abre un issue en el repositorio con los logs relevantes

## Referencias

- [OpenLambda Repository](https://github.com/open-lambda/open-lambda)
- [OLScheduler Repository](https://github.com/disel-espol/olscheduler)
- [Reporte del Experimento Validado](../REPORTE_EXPERIMENTO_EJECUTADO.md)

