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

### Opción B: Setup Manual (Referencia)

```
┌─────────────────────────────────────────────────────────────┐
│  ¿Dónde vas a ejecutar el experimento?                      │
└─────────────────────────────────────────────────────────────┘
              ↓                           ↓
    ┌─────────────────┐        ┌─────────────────────┐
    │  Máquina Virtual│        │  Docker (avanzado)  │
    │     (Linux)     │        │                     │
    └─────────────────┘        └─────────────────────┘
              ↓                           ↓
   Lee: GUIA_MAQUINA_VIRTUAL.md   Lee: GUIA_MAQUINA_VIRTUAL.md
                                  Sección Docker

Después de configurar el entorno:
              ↓
   Lee: INSTRUCCIONES_TERMINALES.md
```

## 📚 Guías Disponibles (Lee en Este Orden)

### 1. **README_EXPERIMENTO.md** ⭐ EMPIEZA AQUÍ
   - ¿Qué es el experimento "pkg-aware"?
   - ¿Qué mide?
   - Estado actual del setup
   - Resumen ejecutivo completo

### 2. **GUIA_MAQUINA_VIRTUAL.md** 🖥️ CONFIGURACIÓN
   - Setup completo de la máquina virtual Linux
   - Instalación de dependencias
   - Configuración con Docker (opcional)
   - Conexión entre Mac y VM

### 3. **INSTRUCCIONES_TERMINALES.md** 🚀 EJECUCIÓN
   - Comandos exactos para cada terminal
   - Qué esperar ver (éxito vs errores)
   - Verificaciones paso a paso
   - Solución de problemas

### 4. **GUIA_EXPERIMENTO_PKG_AWARE.md** 📖 REFERENCIA COMPLETA
   - Documentación detallada
   - Arquitectura del sistema
   - Análisis de resultados
   - Troubleshooting avanzado

### 5. **INSTRUCCIONES_RAPIDAS.md** ⚡ REFERENCIA RÁPIDA
   - Comandos resumidos
   - TL;DR de cada paso
   - Para consulta rápida

### 6. **CHEATSHEET.md** 📝 COMANDOS RÁPIDOS
   - Comandos más usados
   - Solución rápida de problemas
   - Monitoreo y verificación

### 7. **NOTA_HANDLERS.md** ℹ️ SOBRE HANDLERS
   - Estado actual de handlers
   - Por qué no se generaron nuevos
   - Registry existente es suficiente

### 8. **INTERPRETACION_RESULTADOS.md** 📊 ANÁLISIS
   - Cómo interpretar métricas
   - Análisis avanzado
   - Comparación entre balanceadores
   - Troubleshooting de resultados

### 9. **verify-setup.sh** ✓ VALIDACIÓN
   - Script de verificación automática
   - Ejecutar antes del experimento

### 10. **INDEX.md** 🗺️ NAVEGACIÓN
   - Índice completo por categoría
   - Búsqueda por pregunta
   - Checklist de ejecución

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
├── README_EXPERIMENTO.md      # Resumen ejecutivo
├── GUIA_MAQUINA_VIRTUAL.md    # Setup de VM y Docker
├── INSTRUCCIONES_TERMINALES.md # Comandos exactos para ejecutar
├── GUIA_EXPERIMENTO_PKG_AWARE.md # Documentación completa
├── INSTRUCCIONES_RAPIDAS.md   # Referencia rápida
│
├── run_cluster.sh            # Script para iniciar OpenLambda
├── run_workload.sh           # Script para ejecutar workload
├── olscheduler.json          # Configuración del scheduler
├── 1000handlers.json         # Configuración del workload
│
├── setup-vm.sh              # Setup automático para VM
├── setup-tunnels.sh         # Túneles SSH Mac↔VM
├── verify-setup.sh          # Verificar configuración
│
├── olscheduler-registries/  # Registros de handlers
│   └── registry_100_5.json
│
├── results-no-cache/        # Resultados sin caché
├── results-handler-cache/   # Resultados con caché
└── handler_specs/           # Especificaciones de handlers

~/olscheduler-experiment/     # Dependencias (se crean al instalar)
├── open-lambda/             # OpenLambda (clonado)
├── pipbench/                # Pipbench (clonado)
└── eval-olscheduler/        # Este repositorio (copiado a VM)

../olscheduler/              # Software que se está probando
└── bin/olscheduler          # Binario compilado ✅
```

## 🚀 Flujo de Trabajo

### Para Usuario con Máquina Virtual

```
1. En tu Mac:
   - Lee README_EXPERIMENTO.md
   - Lee GUIA_MAQUINA_VIRTUAL.md
   
2. En la VM Linux:
   - Ejecuta setup-vm.sh
   - Copia eval-olscheduler a la VM
   - Actualiza rutas en scripts
   
3. En tu Mac (opcional):
   - Configura túneles SSH con setup-tunnels.sh
   
4. En la VM (3 terminales):
   - Lee INSTRUCCIONES_TERMINALES.md
   - Ejecuta Terminal 1: ./run_cluster.sh
   - Ejecuta Terminal 2: ./bin/olscheduler start
   - Ejecuta Terminal 3: ./run_workload.sh
   
5. Analiza resultados:
   - python3 analyze_results.py
```

## ✅ Estado Actual del Setup

### Completado ✅
- [x] Go 1.25.4 instalado
- [x] OLScheduler compilado
- [x] Scripts actualizados con rutas locales
- [x] Documentación completa creada
- [x] OpenLambda clonado (en ~/olscheduler-experiment)
- [x] Pipbench clonado (en ~/olscheduler-experiment)
- [x] Scripts de setup automatizado creados

### Pendiente ⏳
- [ ] OpenLambda compilado (requiere Linux/VM)
- [ ] Máquina virtual configurada (si usas VM)
- [ ] Túneles SSH configurados (si accedes desde Mac)

### Nota sobre Handlers ℹ️
- ✅ Registry de handlers ya existe (`registry_100_5.json`)
- ✅ No necesitas generar handlers nuevos
- Ver `NOTA_HANDLERS.md` para detalles

## 🛠️ Scripts Disponibles

### Setup
- `setup-vm.sh` - Setup automático en máquina virtual Linux
- `setup-tunnels.sh` - Crear túneles SSH desde Mac a VM
- `verify-setup.sh` - Verificar que todo está configurado

### Ejecución
- `run_cluster.sh` - Iniciar clúster OpenLambda
- `run_workload.sh` - Ejecutar workload de prueba
- `run_pkg_aware_experiments.sh` - Ejecutar múltiples experimentos

### Análisis
- `analyze_results.py` - Analizar logs y generar estadísticas

## 🔍 Verificar Setup

```bash
# En la VM, ejecutar:
./verify-setup.sh

# Debe mostrar:
# ✓ OpenLambda instalado
# ✓ Pipbench instalado
# ✓ Scripts configurados
# ✓ Puertos disponibles
# ✓ Todo listo para ejecutar
```

## 📊 Resultados Esperados

Después de ejecutar el experimento:
```
eval-olscheduler/
└── 1000handlers.log    # Log con tiempos de respuesta

Formato:
[timestamp] handler: hdlXX_0 status: 200 in: XXXX ms
```

## ❓ FAQ Rápido

**¿Puedo ejecutar en macOS sin VM?**
No. OpenLambda requiere Linux. Usa VM o Docker.

**¿Cuánto tiempo toma el experimento?**
5-10 minutos por configuración. 1-2 horas para todos los thresholds.

**¿Necesito Docker?**
No es obligatorio, pero ayuda con reproducibilidad.

**¿Dónde están los resultados?**
En `1000handlers.log` y carpeta `results-no-cache/`

**¿Cómo sé si funcionó?**
Verifica que `1000handlers.log` existe y tiene líneas con "status: 200"

## 🆘 Solución Rápida de Problemas

| Problema | Solución |
|----------|----------|
| OpenLambda no compila en Mac | Usa VM Linux o Docker |
| "command not found: admin" | OpenLambda no compilado en VM |
| "Workers empty" | Inicia run_cluster.sh primero |
| "Connection refused" | Inicia olscheduler antes del workload |
| Puerto ocupado | `lsof -i :8080` y mata proceso |

Ver `INSTRUCCIONES_TERMINALES.md` para más detalles.

## 📞 Próximos Pasos

1. **Primero:** Lee `README_EXPERIMENTO.md` para entender el experimento
2. **Segundo:** Lee `GUIA_MAQUINA_VIRTUAL.md` para configurar tu VM
3. **Tercero:** Lee `INSTRUCCIONES_TERMINALES.md` para ejecutar
4. **Cuarto:** Analiza resultados con `analyze_results.py`

## 🌟 Contribuciones

Este es un artefacto de evaluación para el paper sobre Package Aware Scheduler.

**Repositorios relacionados:**
- OpenLambda: https://github.com/open-lambda/open-lambda
- OLScheduler: https://github.com/disel-espol/olscheduler
- Pipbench: https://github.com/open-lambda/pipbench

---

**¿Dudas?** Consulta la guía correspondiente según tu necesidad:
- 🎯 ¿Qué es esto? → `README_EXPERIMENTO.md`
- 🖥️ Setup VM → `GUIA_MAQUINA_VIRTUAL.md`
- 🚀 Ejecutar → `INSTRUCCIONES_TERMINALES.md`
- 📊 Analizar → `INTERPRETACION_RESULTADOS.md`
- ⚡ Comandos → `CHEATSHEET.md`
- ✓ Verificar → `verify-setup.sh`
- 📖 Completo → `GUIA_EXPERIMENTO_PKG_AWARE.md`

**Archivos totales**: 13 guías + 7 scripts = 20 recursos completos

