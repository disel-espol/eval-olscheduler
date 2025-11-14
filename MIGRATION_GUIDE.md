# Guía de Migración: Scripts Antiguos → Scripts Modernos

Esta guía explica las diferencias entre los scripts antiguos del repositorio y los scripts modernos en el directorio `docker/`, y cómo migrar tu código o configuración.

## Tabla de Contenidos

- [Por Qué Migrar](#por-qué-migrar)
- [Cambios en OpenLambda](#cambios-en-openlambda)
- [Tabla Comparativa de Comandos](#tabla-comparativa-de-comandos)
- [Cambios en Configuración](#cambios-en-configuración)
- [Migración de Scripts Personalizados](#migración-de-scripts-personalizados)
- [FAQ](#faq)

## Por Qué Migrar

Los scripts en el directorio raíz del repositorio fueron escritos para una versión antigua de OpenLambda que usaba comandos CLI diferentes. **Estos comandos ya no existen en versiones modernas de OpenLambda.**

### Problemas con Scripts Antiguos

```bash
# Estos comandos YA NO FUNCIONAN:
$ADMIN new -cluster=c0                    # ❌ Error: unknown flag: -cluster
$ADMIN setconf -cluster=c0 '...'          # ❌ Error: unknown command: setconf
$ADMIN workers -cluster=c0 -num-workers=5 # ❌ Error: unknown flag: -num-workers
$ADMIN status -cluster=c0                 # ❌ Error: unknown flag: -cluster
```

### Ventajas de Scripts Modernos

- ✅ Compatibles con OpenLambda actual
- ✅ Configuración declarativa via JSON
- ✅ Mejor manejo de errores
- ✅ Soporte para Docker-in-Docker
- ✅ Validados en experimentos reales

## Cambios en OpenLambda

### Arquitectura Antigua vs Moderna

**Antigua (≤2020):**
- Gestión centralizada de clusters
- Configuración via CLI con múltiples comandos
- Un comando `admin` maneja múltiples workers
- Sandbox principal: `sock` con cgroups directos

**Moderna (2021+):**
- Gestión individual de workers
- Configuración via archivo `config.json`
- Cada worker se gestiona independientemente
- Sandbox principal: `docker` (Docker-in-Docker)

## Tabla Comparativa de Comandos

### Crear Cluster/Workers

| Script Antiguo | Script Moderno | Notas |
|----------------|----------------|-------|
| `$ADMIN new -cluster=c0` | `$ADMIN worker init --path=./worker-8081` | Ahora se inicializa cada worker individualmente |
| `$ADMIN workers -cluster=c0 -num-workers=5 -port=8081` | Se crean 5 workers separados con `init` | No hay concepto de "cluster", solo workers independientes |

**Ejemplo Antiguo:**
```bash
ADMIN=/path/to/admin
ADMIN new -cluster=c0
$ADMIN workers -cluster=c0 -num-workers=5 -port=8081
```

**Equivalente Moderno:**
```bash
OL=/path/to/admin
PORTS=(8081 8082 8083 8084 8085)

for port in ${PORTS[@]}; do
    worker_dir="/tmp/ol-workers/worker-${port}"
    mkdir -p "${worker_dir}"
    cd "${worker_dir}"
    ${OL} worker init --path=.
done
```

### Configurar Workers

| Script Antiguo | Script Moderno | Notas |
|----------------|----------------|-------|
| `$ADMIN setconf -cluster=c0 '{"sandbox": "sock"}'` | Editar `config.json` de cada worker | La configuración ahora es declarativa |
| `eval "$ADMIN setconf ..."` | `python3 -c "import json; ..."` | Se modifica el JSON directamente |

**Ejemplo Antiguo:**
```bash
SANDBOX='{"sandbox": "sock", "handler_cache_size": 0}'
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$SANDBOX'"
```

**Equivalente Moderno:**
```bash
python3 -c "
import json
with open('${worker_dir}/config.json', 'r+') as f:
    config = json.load(f)
    config['sandbox'] = 'docker'
    config['features']['import_cache'] = False
    f.seek(0)
    json.dump(config, f, indent=2)
    f.truncate()
"
```

### Iniciar Workers

| Script Antiguo | Script Moderno | Notas |
|----------------|----------------|-------|
| `$ADMIN workers -cluster=c0 ...` (inicia automáticamente) | `$ADMIN worker up --path=. --detach` | Comando explícito para iniciar |

**Ejemplo Antiguo:**
```bash
# Los workers se iniciaban automáticamente con el comando workers
$ADMIN workers -cluster=c0 -num-workers=5 -port=8081
```

**Equivalente Moderno:**
```bash
for port in ${PORTS[@]}; do
    worker_dir="/tmp/ol-workers/worker-${port}"
    cd "${worker_dir}"
    ${OL} worker up --path=. --detach > worker-${port}.log 2>&1 &
done
```

### Detener Workers

| Script Antiguo | Script Moderno | Notas |
|----------------|----------------|-------|
| `$ADMIN kill -cluster=c0` | `$ADMIN worker down` (en cada directorio) | Se detiene cada worker individualmente |

**Ejemplo Antiguo:**
```bash
$ADMIN kill -cluster=$TEST_CLUSTER
rm -r $TEST_CLUSTER
```

**Equivalente Moderno:**
```bash
for port in ${PORTS[@]}; do
    worker_dir="/tmp/ol-workers/worker-${port}"
    if [ -d "${worker_dir}" ]; then
        cd "${worker_dir}"
        ${OL} worker down > /dev/null 2>&1 || true
    fi
done
rm -rf /tmp/ol-workers/*
```

### Verificar Estado

| Script Antiguo | Script Moderno | Notas |
|----------------|----------------|-------|
| `$ADMIN status -cluster=c0` | `curl http://localhost:8081/status` | Ahora se verifica via HTTP |

**Ejemplo Antiguo:**
```bash
$ADMIN status -cluster=$TEST_CLUSTER
```

**Equivalente Moderno:**
```bash
for port in 8081 8082 8083 8084 8085; do
    status=$(curl -s http://localhost:${port}/status)
    echo "Worker ${port}: ${status}"
done
```

## Cambios en Configuración

### Sandbox: sock vs docker

**Antiguo (sock):**
```json
{
  "sandbox": "sock",
  "sock_base_path": "/path/to/base",
  "cg_pool_size": 10,
  "handler_cache_size": 0,
  "import_cache_size": 0
}
```

Requiere:
- Cgroups nativos del sistema
- Permisos root o configuración especial
- Solo funciona en Linux con cgroups v1/v2

**Moderno (docker):**
```json
{
  "sandbox": "docker",
  "docker": {
    "runtime": "",
    "base_image": "ol-min"
  },
  "features": {
    "import_cache": false
  }
}
```

Requiere:
- Docker instalado y corriendo
- Docker-in-Docker si se ejecuta en contenedor
- Funciona en cualquier plataforma con Docker

**⚠️ Importante:** `import_cache` **DEBE SER `false`** cuando se usa sandbox `docker`.

### Registry de Handlers

**Antiguo:**
```bash
REGISTRY_DIR='{"registry_dir": "/path/to/handlers"}'
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$REGISTRY_DIR'"
```

**Moderno:**
```json
{
  "registry": "file:///path/to/registry"
}
```

La configuración ahora va en `config.json` de cada worker.

### Pip Mirror

**Antiguo:**
```bash
PIP_MIRROR='{"pip_mirror": "http://localhost:9199/simple/"}'
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$PIP_MIRROR'"
```

**Moderno:**
```json
{
  "pip_mirror": "http://localhost:9199/simple/"
}
```

## Migración de Scripts Personalizados

Si has creado tus propios scripts basados en los antiguos, aquí está el patrón de migración:

### Patrón General

```bash
# =====================================
# SCRIPT ANTIGUO
# =====================================
#!/bin/bash

ADMIN=/path/to/admin
TEST_CLUSTER=c0
NUM_WORKERS=5

# Crear cluster
$ADMIN new -cluster=$TEST_CLUSTER

# Configurar
SANDBOX='{"sandbox": "sock", "..."}'
eval "$ADMIN setconf -cluster=$TEST_CLUSTER '$SANDBOX'"

# Iniciar workers
$ADMIN workers -cluster=$TEST_CLUSTER -num-workers=$NUM_WORKERS -port=8081

# Verificar
$ADMIN status -cluster=$TEST_CLUSTER

# =====================================
# SCRIPT MODERNO EQUIVALENTE
# =====================================
#!/bin/bash

OL=/path/to/admin
BASE_DIR=/tmp/ol-workers
PORTS=(8081 8082 8083 8084 8085)

# Detener workers existentes
for port in ${PORTS[@]}; do
    worker_dir="${BASE_DIR}/worker-${port}"
    [ -d "${worker_dir}" ] && cd "${worker_dir}" && ${OL} worker down || true
done

# Limpiar
rm -rf "${BASE_DIR}"/*

# Inicializar cada worker
for port in ${PORTS[@]}; do
    worker_dir="${BASE_DIR}/worker-${port}"
    mkdir -p "${worker_dir}"
    cd "${worker_dir}"
    ${OL} worker init --path=.
    
    # Configurar via config.json
    python3 -c "
import json
with open('${worker_dir}/config.json', 'r+') as f:
    config = json.load(f)
    config['worker_port'] = str(${port})
    config['sandbox'] = 'docker'
    config['features']['import_cache'] = False
    f.seek(0)
    json.dump(config, f, indent=2)
    f.truncate()
"
done

# Iniciar workers
for port in ${PORTS[@]}; do
    worker_dir="${BASE_DIR}/worker-${port}"
    cd "${worker_dir}"
    ${OL} worker up --path=. --detach &
done

# Esperar y verificar
sleep 10
for port in ${PORTS[@]}; do
    curl -s http://localhost:${port}/status
done
```

### Checklist de Migración

Al migrar tu script, verifica:

- [ ] Reemplazar `$ADMIN new -cluster=...` con `${OL} worker init`
- [ ] Reemplazar `$ADMIN setconf` con modificación de `config.json`
- [ ] Cambiar de sandbox `sock` a `docker`
- [ ] Configurar `import_cache: false` para docker
- [ ] Inicializar cada worker en su propio directorio
- [ ] Cambiar verificación de estado a HTTP con `curl`
- [ ] Actualizar paths a absolutos o relativos apropiados
- [ ] Añadir manejo de errores (`set -e`, verificaciones)

## FAQ

### ¿Puedo seguir usando los scripts antiguos?

No, los comandos antiguos ya no existen en OpenLambda moderno. Debes migrar a los scripts modernos en `docker/`.

### ¿Qué pasa si tengo un setup existente con los scripts antiguos?

Necesitarás detener todos los workers antiguos y reiniciar con los scripts modernos:

```bash
# Detener workers antiguos (si todavía funcionan)
/path/to/old/admin kill -cluster=c0

# Limpiar
rm -rf c0/

# Usar scripts modernos
cd docker/
./run_cluster_modern.sh
```

### ¿Puedo usar sandbox `sock` con los scripts modernos?

Técnicamente sí, pero es más complicado:
- Requiere configurar cgroups en el host
- Puede necesitar permisos especiales
- No funciona bien en Docker-in-Docker
- **Recomendación:** Usa sandbox `docker` que es más portable

### ¿Los scripts modernos funcionan en mi VM Linux antigua?

Sí, siempre que:
- Tengas Docker instalado
- OpenLambda esté compilado correctamente
- Los puertos 8080-8085 estén disponibles

### ¿Puedo contribuir mis mejoras?

¡Sí! Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para ver cómo contribuir al proyecto.

### ¿Dónde están los ejemplos completos?

Revisa:
- `docker/run_cluster_modern.sh` - Script completo de workers
- `docker/run_workload_modern.sh` - Script de workload
- `docker/start_experiment.sh` - Orquestador completo
- `docker/README.md` - Guía detallada de uso

## Recursos Adicionales

- [docker/README.md](docker/README.md) - Guía completa para usar scripts modernos
- [REPORTE_EXPERIMENTO_EJECUTADO.md](REPORTE_EXPERIMENTO_EJECUTADO.md) - Resultados de experimento validado
- [OpenLambda Documentation](https://github.com/open-lambda/open-lambda)
- [OLScheduler Repository](https://github.com/disel-espol/olscheduler)

## Changelog de OpenLambda (Relevante)

| Fecha | Cambio | Impacto |
|-------|--------|---------|
| 2021+ | Eliminación de comandos `admin new`, `admin workers`, `admin setconf` | ❌ Scripts antiguos dejan de funcionar |
| 2021+ | Introducción de `worker init` y `worker up` | ✅ Nueva forma de gestionar workers |
| 2021+ | Configuración via `config.json` | ✅ Configuración declarativa más clara |
| 2022+ | Sandbox `docker` como recomendado | ✅ Mejor portabilidad entre plataformas |

---

**¿Necesitas ayuda con la migración?** Abre un issue en el repositorio con tu caso específico.

