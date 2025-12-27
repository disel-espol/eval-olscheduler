# Guía de Contribución

¡Gracias por tu interés en contribuir al proyecto OLScheduler Evaluation! Esta guía te ayudará a realizar contribuciones de calidad que beneficien a toda la comunidad.

## Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [Cómo Contribuir](#cómo-contribuir)
- [Tipos de Contribuciones](#tipos-de-contribuciones)
- [Proceso de Desarrollo](#proceso-de-desarrollo)
- [Estándares de Código](#estándares-de-código)
- [Testing](#testing)
- [Documentación](#documentación)
- [Pull Requests](#pull-requests)

## Código de Conducta

Al participar en este proyecto, te comprometes a:

- Ser respetuoso y considerado con otros contribuyentes
- Aceptar críticas constructivas
- Enfocarte en lo que es mejor para la comunidad
- Mostrar empatía hacia otros miembros de la comunidad

## Cómo Contribuir

### 1. Reportar Problemas

Si encuentras un bug o tienes una sugerencia:

1. **Verifica** que el issue no exista ya
2. **Abre un nuevo issue** con:
   - Título descriptivo
   - Descripción detallada del problema
   - Pasos para reproducir (si es un bug)
   - Comportamiento esperado vs actual
   - Versiones de software (OS, Docker, Go, Python)
   - Logs relevantes

**Ejemplo de buen issue:**

```markdown
### Descripción
Los workers de OpenLambda no inician correctamente cuando se usa sandbox docker en Ubuntu 22.04.

### Pasos para Reproducir
1. Ejecutar `./docker/run_cluster_modern.sh`
2. Observar error en logs

### Comportamiento Esperado
Los 5 workers deberían iniciar y responder en sus puertos.

### Comportamiento Actual
Solo 3 de 5 workers inician. Workers 8082 y 8084 fallan con error:
```
Error: cannot create docker container: permission denied
```

### Entorno
- OS: Ubuntu 22.04 LTS
- Docker: 24.0.5
- Go: 1.21.5
- OpenLambda: commit abc123
```

### 2. Proponer Mejoras

Para sugerir nuevas funcionalidades:

1. **Abre un issue** describiendo:
   - Qué problema resuelve
   - Cómo lo usarían los usuarios
   - Posibles alternativas consideradas
2. **Espera feedback** antes de implementar
3. **Discute el diseño** con los maintainers

### 3. Contribuir Código

#### Fork y Clone

```bash
# Fork el repositorio en GitHub
# Luego clona tu fork:
git clone https://github.com/TU-USUARIO/eval-olscheduler.git
cd eval-olscheduler

# Añade el repositorio original como upstream
git remote add upstream https://github.com/disel-espol/eval-olscheduler.git
```

#### Crear Branch

```bash
# Actualiza tu main
git checkout main
git pull upstream main

# Crea un branch descriptivo
git checkout -b feature/mejora-descripcion
# o
git checkout -b fix/corregir-bug-especifico
```

**Convención de nombres:**
- `feature/` - Nueva funcionalidad
- `fix/` - Corrección de bug
- `docs/` - Solo documentación
- `refactor/` - Refactorización sin cambios de funcionalidad
- `test/` - Añadir o mejorar tests

## Tipos de Contribuciones

### Scripts y Automatización

Si contribuyes scripts:

✅ **DO:**
- Incluir comentarios explicativos
- Añadir manejo de errores
- Verificar prerequisitos antes de ejecutar
- Usar variables de entorno para configuración
- Incluir mensajes informativos de progreso
- Hacer el script ejecutable (`chmod +x`)

❌ **DON'T:**
- Hardcodear paths específicos de tu máquina
- Asumir que herramientas están instaladas sin verificar
- Ignorar errores (`|| true` sin justificación)
- Usar comandos no portables sin alternativas

**Ejemplo:**

```bash
#!/bin/bash
# Script para inicializar el entorno del experimento
# Prerequisitos: Docker, Go 1.21+, Python 3.8+

set -e  # Salir en caso de error

# Verificar prerequisitos
command -v docker >/dev/null 2>&1 || { 
    echo "Error: Docker no está instalado"
    exit 1
}

# Usar variables de entorno con defaults
BASE_DIR=${EXPERIMENT_BASE_DIR:-/tmp/ol-experiment}

# Informar al usuario del progreso
echo "Inicializando entorno en: ${BASE_DIR}"
mkdir -p "${BASE_DIR}"
```

### Configuraciones

Al añadir archivos de configuración:

- Usa formato JSON con indentación de 2 espacios
- Añade comentarios explicativos (en archivos de ejemplo)
- Proporciona valores razonables por defecto
- Documenta cada campo en README o comentarios

### Documentación

Contribuciones de documentación son muy valoradas:

- Corregir typos o errores
- Mejorar claridad de instrucciones
- Añadir ejemplos
- Traducir a otros idiomas
- Actualizar información desactualizada

**Estructura de documentación:**
```markdown
# Título Claro

## Resumen breve de qué trata

## Prerequisitos
- Lista de requisitos

## Instrucciones Paso a Paso
1. Primer paso con comando
   ```bash
   comando ejemplo
   ```
2. Segundo paso

## Troubleshooting
### Error X
**Causa:** Explicación
**Solución:** Pasos para resolver

## Referencias
- Links útiles
```

## Proceso de Desarrollo

### 1. Desarrollo Local

```bash
# Crear branch
git checkout -b feature/mi-contribucion

# Realizar cambios
# ... editar archivos ...

# Probar localmente
./docker/run_cluster_modern.sh
# Verificar que todo funciona

# Commit con mensaje descriptivo
git add .
git commit -m "feat: añadir soporte para N workers configurables

- Añadir variable NUM_WORKERS en scripts
- Actualizar documentación
- Añadir validación de entrada"
```

### 2. Convención de Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(<scope>): <descripción corta>

[cuerpo opcional con más detalles]

[footer opcional con referencias]
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Solo documentación
- `style`: Formateo, sin cambios de código
- `refactor`: Refactorización
- `test`: Añadir tests
- `chore`: Tareas de mantenimiento

**Ejemplos:**

```
feat(docker): añadir soporte para arquitectura ARM64

fix(scripts): corregir detección de puertos ocupados

docs(readme): actualizar instrucciones de instalación

refactor(workload): simplificar lógica de retry
```

### 3. Testing

Antes de enviar tu PR, verifica:

#### Scripts de Shell

```bash
# Verificar sintaxis
bash -n tu_script.sh

# Ejecutar en ambiente limpio
docker run -it --rm -v $(pwd):/workspace ubuntu:20.04 bash
cd /workspace
./tu_script.sh
```

#### Configuraciones JSON

```bash
# Validar sintaxis JSON
python3 -m json.tool config.json
# o
jq . config.json
```

#### Experimento Completo

```bash
# Ejecutar experimento de principio a fin
cd docker
./start_experiment.sh

# Verificar que las métricas sean razonables
cat /tmp/experiment_results.log
```

**Checklist de Testing:**
- [ ] Script ejecuta sin errores
- [ ] Manejo de errores funciona (probar con inputs inválidos)
- [ ] Mensajes informativos son claros
- [ ] Documentación refleja los cambios
- [ ] Funciona en ambiente limpio (Docker)
- [ ] Compatible con diferentes arquitecturas (si aplica)

## Estándares de Código

### Bash Scripts

```bash
#!/bin/bash
# Descripción breve del script
# Autor: Tu Nombre
# Fecha: 2024-01-15

# Configuración estricta
set -e          # Salir en error
set -u          # Error en variables no definidas
set -o pipefail # Error en pipes

# Constantes en MAYÚSCULAS
readonly BASE_DIR="/tmp/experiment"
readonly NUM_WORKERS=5

# Variables en minúsculas
worker_count=0

# Funciones con nombres descriptivos
check_prerequisites() {
    local all_ok=true
    
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker no encontrado"
        all_ok=false
    fi
    
    if [ "$all_ok" = false ]; then
        return 1
    fi
    
    return 0
}

# Llamada a función principal
main() {
    check_prerequisites || exit 1
    # ... resto de lógica
}

# Ejecutar main si es el script principal
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
```

### Python Scripts

```python
#!/usr/bin/env python3
"""
Descripción breve del script.

Este módulo/script hace X, Y, Z.
"""

import sys
import json
from typing import Dict, List

def process_config(config_path: str) -> Dict:
    """
    Procesa el archivo de configuración.
    
    Args:
        config_path: Path al archivo JSON de configuración
        
    Returns:
        Dict con la configuración parseada
        
    Raises:
        FileNotFoundError: Si el archivo no existe
        json.JSONDecodeError: Si el JSON es inválido
    """
    with open(config_path, 'r') as f:
        return json.load(f)

def main():
    """Función principal."""
    if len(sys.argv) < 2:
        print("Usage: script.py <config_file>", file=sys.stderr)
        sys.exit(1)
    
    config = process_config(sys.argv[1])
    # ... resto de lógica

if __name__ == "__main__":
    main()
```

### JSON/Configuración

```json
{
  "field_name": "value",
  "_field_name_comment": "Explicación del campo",
  
  "numeric_value": 100,
  "_numeric_value_note": "Rango recomendado: 50-200",
  
  "nested": {
    "key": "value"
  }
}
```

## Documentación

### README Updates

Al cambiar funcionalidad, actualiza el README:

1. Describe el cambio en la sección apropiada
2. Añade ejemplos si es relevante
3. Actualiza tabla de contenidos si añades secciones
4. Verifica que los links funcionen

### Inline Comments

```bash
# ✅ Bueno: Explica el POR QUÉ
# Usamos Docker sandbox porque sock requiere cgroups nativos
config['sandbox'] = 'docker'

# ❌ Malo: Solo repite el QUÉ
# Configurar sandbox a docker
config['sandbox'] = 'docker'
```

## Pull Requests

### Antes de Enviar

- [ ] Código funciona localmente
- [ ] Tests pasan
- [ ] Documentación actualizada
- [ ] Commits siguen convención
- [ ] Branch actualizado con main

```bash
# Actualizar con cambios upstream
git fetch upstream
git rebase upstream/main

# Push a tu fork
git push origin feature/mi-contribucion
```

### Crear el PR

1. Ve a GitHub y crea el Pull Request
2. Usa el template (si existe)
3. Título descriptivo siguiendo convención de commits
4. Descripción detallada:
   - Qué cambia
   - Por qué es necesario
   - Cómo probarlo
   - Screenshots/logs si aplica

**Template de PR:**

```markdown
## Descripción
Breve descripción del cambio y su motivación.

## Tipo de Cambio
- [ ] Bug fix (cambio que corrige un issue)
- [ ] Nueva funcionalidad (cambio que añade funcionalidad)
- [ ] Breaking change (cambio que rompe compatibilidad)
- [ ] Documentación

## Cómo Probar
1. Paso 1
2. Paso 2
3. Resultado esperado

## Checklist
- [ ] Mi código sigue el estilo del proyecto
- [ ] He realizado self-review
- [ ] He comentado código complejo
- [ ] He actualizado documentación
- [ ] Mis cambios no generan warnings
- [ ] He probado que funciona

## Screenshots/Logs
(Si aplica)
```

### Review Process

1. **Maintainers revisarán** tu código
2. **Responde a comentarios** de manera constructiva
3. **Realiza cambios** solicitados
4. **Push updates** al mismo branch

```bash
# Hacer cambios basados en review
git add .
git commit -m "fix: aplicar sugerencias de review"
git push origin feature/mi-contribucion
```

5. Una vez aprobado, **tu PR será merged**

## Contexto del Proyecto

### Historia de la Modernización

Este proyecto originalmente usaba scripts diseñados para una versión antigua de OpenLambda (≤2020). En 2024, se realizó una modernización completa:

- **Problema:** Comandos antiguos (`admin new -cluster`, `admin setconf`) ya no funcionaban
- **Solución:** Reescribir scripts usando API moderna (`worker init`, `worker up`)
- **Validación:** Experimento ejecutado exitosamente con latencia promedio de 5.9ms
- **Documentación:** Creación de guías exhaustivas de migración y uso

Tus contribuciones ayudan a que otros investigadores y estudiantes puedan reproducir estos experimentos sin los obstáculos que encontramos nosotros.

### Commit que Valida la Funcionalidad

El código corregido que usamos como base está en:
- [https://github.com/disel-espol/olscheduler/commit/e57033b293ca242737f7cd636fcccadd1a7013b5](https://github.com/disel-espol/olscheduler/commit/e57033b293ca242737f7cd636fcccadd1a7013b5)

## Preguntas Frecuentes

### ¿Puedo contribuir si soy nuevo en el proyecto?

¡Absolutamente! Contribuciones de documentación, mejoras de mensajes de error, o simplemente reportar issues son muy valiosas.

### ¿Cuánto tiempo toma revisar un PR?

Típicamente 1-7 días. Si no hay respuesta en una semana, puedes hacer un ping cortés.

### ¿Necesito experiencia con OpenLambda?

No necesariamente. Muchas contribuciones (scripts, documentación, configuraciones) no requieren conocimiento profundo de OpenLambda.

### ¿Qué pasa si mi PR es rechazado?

Recibirás feedback explicando por qué. Puedes hacer cambios y reenviar, o discutir alternativas.

## Recursos

- [OpenLambda Repository](https://github.com/open-lambda/open-lambda)
- [OLScheduler Repository](https://github.com/disel-espol/olscheduler)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Bash Best Practices](https://github.com/progrium/bashstyle)

## Contacto

- **Issues:** GitHub Issues en el repositorio
- **Discussions:** GitHub Discussions para preguntas generales
- **Email:** (Si existe contacto oficial del proyecto)

---

¡Gracias por hacer que este proyecto sea mejor! 🚀

