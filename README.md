# Experimento Package Aware Scheduler (pkg-aware)

## ⚠️ IMPORTANTE: Scripts Modernizados Disponibles

**Si es tu primera vez ejecutando este experimento, usa los scripts modernizados en el directorio `docker/`.**

Los scripts en el directorio raíz del repositorio usan comandos obsoletos de OpenLambda que ya no funcionan. Hemos creado scripts modernizados y completamente funcionales:

### ✅ Ruta Recomendada (Scripts Modernos)

**Para usuarios nuevos o si los scripts antiguos no funcionan:**

👉 **[Ir directamente a docker/README.md](docker/README.md)** - Guía completa de setup con scripts modernizados

**Ventajas:**
- ✅ Usa comandos actuales de OpenLambda (`ol worker init/up`)
- ✅ Configuración via `config.json` (estándar moderno)
- ✅ Compatible con macOS (ARM64 y x86_64) y Linux
- ✅ Validado en experimento real (latencia promedio: 5.9ms)
- ✅ Script orquestador automático (`start_experiment.sh`)

### 📚 Documentación Nueva

- **[docker/README.md](docker/README.md)** - Guía completa para ejecutar el experimento con scripts modernos
- **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** - Comparativa de comandos antiguos vs modernos
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guía para contribuir al proyecto

### 🗂️ Ruta Alternativa (Scripts Antiguos - Referencia Histórica)

Si tienes un setup existente con los scripts antiguos y necesitas mantener compatibilidad, consulta las guías originales a continuación. **Nota:** Estos scripts requieren versiones antiguas de OpenLambda y pueden no funcionar con versiones recientes.

---

## 🎯 Inicio Rápido - ¿Por Dónde Empezar?

### Opción A: Scripts Modernos (Recomendado) 🆕

```
1. Instalar Docker Desktop (macOS/Windows) o Docker Engine (Linux)
2. Seguir la guía: docker/README.md
3. Ejecutar: docker/start_experiment.sh
   → Todo automatizado, resultado en minutos
```

### Opción B: Consultar Documentación de Referencia

Para entender los cambios y la evolución del proyecto:
- **MIGRATION_GUIDE.md** - Comparativa de comandos antiguos vs modernos
- **CONTRIBUTING.md** - Guía para contribuir al proyecto

## 🎓 ¿Qué es el Experimento "pkg-aware"?

**Package Aware Scheduler** es un algoritmo de balanceo de carga inteligente que:
- Agrupa funciones serverless con dependencias Python similares
- Reutiliza paquetes ya instalados
- Reduce tiempos de cold start
- Compara rendimiento vs otros algoritmos

**Mide:**
- Tiempo de respuesta (mean, median, percentiles)
- Cold starts vs Warm starts
- Distribución de carga entre workers
- Impacto del load-threshold

## ⚠️ Requisitos Importantes

### Sistema Operativo
- **OpenLambda REQUIERE Linux** (Ubuntu 20.04+ recomendado)
- En macOS necesitas:
  - Máquina virtual Linux, O
  - Docker con Linux container

### Dependencias
- Go 1.18+ ✅ (ya instalado)
- Python 3.8+ ✅ (ya instalado)
- OpenLambda (requiere Linux)
- Pipbench (instalado en ~/olscheduler-experiment)
- OLScheduler ✅ (compilado)

## 📁 Estructura del Proyecto

```
eval-olscheduler/              # Este repositorio (artefacto de evaluación)
├── README.md                  # ⭐ Este archivo (índice principal)
├── CONTRIBUTING.md            # Guía de contribución
├── MIGRATION_GUIDE.md         # Guía de migración de comandos
│
├── docker/                    # 🆕 Scripts modernos
│   ├── README.md              # Guía completa de setup
│   ├── Dockerfile.modern      # Imagen Docker optimizada
│   ├── run_cluster_modern.sh  # Iniciar workers modernos
│   ├── run_workload_modern.sh # Ejecutar workload
│   ├── start_experiment.sh    # Orquestador automático
│   └── config-examples/       # Ejemplos de configuración
│       ├── worker-docker.json
│       └── olscheduler-docker.json
│
├── run_cluster.sh             # Script antiguo (obsoleto)
├── run_workload.sh            # Script antiguo (obsoleto)
├── olscheduler.json           # Configuración del scheduler
├── 1000handlers.json          # Configuración del workload
│
├── olscheduler-registries/    # Registros de handlers
│   └── registry_100_5.json
│
├── results-no-cache/          # Resultados sin caché
├── results-handler-cache/     # Resultados con caché
└── handler_specs/             # Especificaciones de handlers
```

## 🚀 Flujo de Trabajo

### Ejecución Moderna (Recomendado)

Para la forma más simple y actualizada de ejecutar el experimento:

👉 **Sigue la guía completa en [docker/README.md](docker/README.md)**

El script `docker/start_experiment.sh` automatiza todo el proceso:
1. Construcción de OpenLambda
2. Configuración de 5 workers
3. Inicio del scheduler con pkg-aware
4. Ejecución del workload
5. Análisis de resultados

### Scripts Antiguos (Referencia Histórica)

Los scripts `run_cluster.sh` y `run_workload.sh` en el directorio raíz usan comandos obsoletos de OpenLambda. Se mantienen por referencia pero incluyen advertencias claras. Ver [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) para entender las diferencias.

## 📊 Resultados Esperados

Después de ejecutar el experimento verás:
```
Latencia promedio: ~5-10ms
Cold starts: primeras ejecuciones
Warm starts: ejecuciones subsecuentes
Distribución de carga entre 5 workers
```

**¿Dónde están los resultados?**
En `1000handlers.log` y carpeta `results-no-cache/`

**¿Cómo sé si funcionó?**
Verifica que `1000handlers.log` existe y tiene líneas con "status: 200"

## 🆘 Solución Rápida de Problemas

| Problema | Solución |
|----------|----------|
| OpenLambda no compila en Mac | Usa Docker (ver `docker/README.md`) |
| "command not found: admin" | Comandos obsoletos, usa scripts en `docker/` |
| Workers no inician | Ver `MIGRATION_GUIDE.md` para comandos modernos |
| "Connection refused" | Verifica que todos los servicios estén corriendo |
| Puerto ocupado | `lsof -i :8080` y termina proceso |

Ver `docker/README.md` para guía completa de troubleshooting.

## 📞 Próximos Pasos

1. **Ejecutar el experimento:** Sigue [docker/README.md](docker/README.md)
2. **Entender los cambios:** Lee [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
3. **Contribuir:** Consulta [CONTRIBUTING.md](CONTRIBUTING.md)

## 🌟 Contribuciones

Este es un artefacto de evaluación para el paper sobre Package Aware Scheduler.

**Repositorios relacionados:**
- OpenLambda: https://github.com/open-lambda/open-lambda
- OLScheduler: https://github.com/disel-espol/olscheduler
- Pipbench: https://github.com/open-lambda/pipbench

**¿Preguntas o problemas?** Abre un issue en este repositorio o consulta la documentación en el directorio `docker/`.

