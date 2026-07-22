# Robot Framework Linux Integration Testing

Suite automatizada de pruebas de integración para validar software distribuido mediante paquetes Debian (`.deb`) en sistemas operativos Linux.

## Por qué existe este proyecto

Este repositorio demuestra cómo estructurar y ejecutar pruebas de integración automatizadas para software empaquetado en Linux utilizando Robot Framework y Python. Valida el ciclo de vida completo de un servicio Linux: instalación de paquetes Debian, verificación de estructura de archivos en el sistema operativo, validación de esquemas de configuración, gestión de procesos Unix, respuestas de endpoints HTTP de salud, análisis de logs de ejecución, actualizaciones limpias de paquetes e in-place upgrades, y remoción de paquetes sin dejar archivos huérfanos.

> **Aclaración**: Este proyecto recrea patrones generales de prueba con los que he trabajado profesionalmente utilizando un sistema totalmente sintético. No contiene código fuente propietario, configuraciones internas, detalles de infraestructura ni datos confidenciales de ninguna empresa.

## Qué se prueba

El software bajo prueba es `satellite-telemetry`, un demonio sintético de demostración desarrollado en Python. La suite valida:

- Integridad y metadatos del paquete (dependencias declaradas, versiones).
- Instalación limpia y remoción del paquete mediante `dpkg`.
- Lectura de archivos de configuración JSON predeterminados y manejo de errores ante sintaxis JSON corrupta.
- Inicio del servicio, ciclo de vida del proceso y registro del archivo PID mediante control POSIX de servicios.
- Contrato de respuesta y consumo del endpoint de salud HTTP `GET /health`.
- Registro e inspección de logs de ejecución en `/var/log/satellite-telemetry/service.log`.
- Actualización in-place del paquete (`1.0.0` -> `1.1.0`) y preservación de configuraciones modificadas por el usuario tras la actualización.
- Recuperación del servicio tras una terminación abrupta e inesperada del proceso (`SIGKILL`).

## Arquitectura de pruebas

```text
Paquete Debian (.deb)
        │
        ▼
Entorno Linux (Debian/Ubuntu)
        │
        ▼
Instalación (dpkg -i)
        │
        ▼
Configuración (/etc/satellite-telemetry/config.json)
        │
        ▼
Servicio Daemon (/etc/init.d/satellite-telemetry)
        │
        ▼
Validación de Integración (HTTP /health, logs, PID, archivos)
        │
        ▼
Robot Framework & Librería Personalizada en Python
        │
        ▼
Evidencia de Pruebas (report.html, log.html, output.xml)
```

## Casos de prueba

| ID | Caso de Prueba | Tipo | Descripción |
|---|---|---|---|
| **TC-001** | Install Satellite Telemetry Package | Instalación | Valida la instalación limpia del paquete `.deb` v1.0.0 mediante `dpkg`. |
| **TC-002** | Validate Installed Version | Instalación | Confirma que la versión reportada por `dpkg-query` corresponda a `1.0.0`. |
| **TC-003** | Validate Installed Files Structure | Instalación | Verifica la presencia de binarios, scripts de servicio y configuraciones. |
| **TC-004** | Validate Package Dependencies Requirement | Dependencias | Comprueba que los metadatos declaren dependencias obligatorias (`python3`, `curl`). |
| **TC-005** | Validate Configuration File Schema | Configuración | Valida la sintaxis JSON y campos obligatorios en `/etc/satellite-telemetry/config.json`. |
| **TC-006** | Validate Service Startup | Servicio | Inicia el servicio y confirma la creación del proceso y archivo `.pid`. |
| **TC-007** | Validate Service Stop | Servicio | Detiene el servicio y verifica la liberación de recursos y eliminación del archivo `.pid`. |
| **TC-008** | Health Endpoint Validation | Integración | Realiza una petición HTTP `GET /health` y valida el payload JSON de respuesta (`200 OK`). |
| **TC-009** | Validate Log Generation and Formatting | Integración | Analiza el archivo `/var/log/satellite-telemetry/service.log` verificando entradas de evento. |
| **TC-010** | Perform Package Upgrade to Version 1.1.0 | Actualización | Actualiza in-place el paquete instalado a la versión v1.1.0 y valida el incremento de versión. |
| **TC-011** | Validate Configuration Preservation After Upgrade | Actualización | Confirma que los parámetros de configuración modificados por el usuario no se sobreescriban al actualizar. |
| **TC-012** | Validate Clean Package Removal | Remoción | Purga el paquete con `dpkg -P` y verifica la eliminación limpia de archivos en el sistema. |
| **TC-013** | Missing Dependency Scenario | Dependencias | Comprueba el comportamiento del gestor de paquetes al evaluar dependencias declaradas. |
| **TC-014** | Invalid Configuration Scenario | Pruebas Negativas | Valida que el servicio rehúse iniciar correctamente si el archivo de configuración está corrupto. |
| **TC-015** | Service Recovery After SIGKILL | Recuperación | Simula el cierre forzado del proceso (`SIGKILL`) y verifica la capacidad de reinicio del servicio. |

## Estructura del proyecto

```text
robot-linux-integration-suite/
├── README.md
├── requirements.txt
├── Dockerfile
├── data/
│   ├── configs/
│   │   ├── valid_config.json
│   │   └── invalid_config.json
│   └── packages/                      # Archivos .deb generados
├── demo_service/
│   ├── src/satellite_telemetry.py    # Demonio sintético en Python
│   ├── debian_1.0.0/                 # Estructura del paquete v1.0.0
│   └── debian_1.1.0/                 # Estructura del paquete v1.1.0
├── libraries/
│   └── LinuxPackageLibrary.py        # Custom Library de Robot Framework en Python
├── resources/
│   ├── common.resource
│   ├── package_keywords.resource
│   ├── service_keywords.resource
│   └── validation_keywords.resource
├── tests/                            # Suites de prueba de Robot Framework
├── scripts/
│   ├── build_deb.sh                  # Script Bash para empaquetar los .deb
│   └── run_tests.sh                  # Script de ejecución unificada
├── docs/                             # Caso de estudio técnico (Portfolio Web)
└── .github/workflows/robot-tests.yml # Pipeline de CI/CD
```

## Ejecución local

### Requisitos previos
- Sistema operativo Linux (Debian, Ubuntu o WSL2 en Windows)
- Python 3.10+
- Herramientas de empaquetado `dpkg` y `dpkg-deb`

### Pasos de ejecución
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/yoelalmiron1997/robot-linux-integration-suite.git
   cd robot-linux-integration-suite
   ```
2. Instalar dependencias de Python:
   ```bash
   pip install -r requirements.txt
   ```
3. Construir los paquetes `.deb` localmente:
   ```bash
   ./scripts/build_deb.sh
   ```
4. Ejecutar la suite de prueba (requiere permisos de superusuario `sudo` para operaciones de `dpkg`):
   ```bash
   sudo ./scripts/run_tests.sh
   ```

## Ejecución con Docker

Docker permite reproducir de manera aislada y determinística el entorno Debian sin afectar el sistema operativo anfitrión.

```bash
# Construir la imagen de Docker
docker build -t robot-linux-suite .

# Ejecutar la suite de pruebas y montar la carpeta output/ para extraer evidencias
docker run --rm -v $(pwd)/output:/app/output robot-linux-suite
```

## Evidencia de pruebas

Al finalizar la ejecución, Robot Framework genera archivos de evidencia gráfica y estructurada en el directorio `output/`:

- `output/report.html`: Reporte visual en HTML con métricas generales de ejecución y tasa de aprobación.
- `output/log.html`: Registro detallado paso a paso con timestamps, argumentos y valores retornados por cada keyword.
- `output/output.xml`: Resultados en formato XML para integración con dashboards de CI/CD.

## Integración Continua (CI)

GitHub Actions ejecuta automáticamente la suite en cada `push` o `pull request`. El pipeline:

1. Aprovisiona un contenedor con Ubuntu/Debian.
2. Instala dependencias y Robot Framework.
3. Empaqueta los archivos `.deb` sintéticos (versiones `1.0.0` y `1.1.0`).
4. Ejecuta la suite de pruebas bajo permisos de root.
5. Publica los artefactos `log.html`, `report.html` y `output.xml` disponibles para descarga.

## Tecnologías

- **Robot Framework**: Runner de pruebas automatizadas guiadas por keywords.
- **Python 3**: Implementación de la librería personalizada de keywords y demonio del servicio sintético.
- **Linux Debian Packaging**: `.deb`, `dpkg`, `dpkg-deb`, `apt`.
- **Docker**: Entorno aislado y reproducible de ejecución.
- **GitHub Actions**: Pipeline de integración continua.
