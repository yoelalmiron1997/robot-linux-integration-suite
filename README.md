# Robot Framework Linux Integration Testing

Automated integration testing suite for validating software distributed as Debian (`.deb`) packages on Linux operating systems.

## Why this project exists

This repository demonstrates how to structure and run automated integration tests for Linux software packages using Robot Framework and Python. It validates the full lifecycle of a Linux service: Debian package installation, file layout, configuration schema validation, process management, HTTP health endpoint response, log inspection, clean package upgrades, and package removal.

> **Disclaimer**: This project recreates general testing patterns I have worked with professionally using a fully synthetic system. It does not contain proprietary source code, internal configurations, infrastructure details or company data.

## What is tested

The target software under test is `satellite-telemetry`, a synthetic demonstration daemon. The suite validates:

- Package integrity and metadata (dependencies, versions).
- Clean package installation and removal via `dpkg`.
- Default configuration file parsing and invalid configuration error handling.
- Service startup, process lifecycle, and PID tracking via POSIX service management.
- HTTP `/health` API contract response parsing.
- Service execution logging and log formatting.
- In-place package upgrades (`1.0.0` -> `1.1.0`) and configuration preservation across upgrades.
- Process recovery following abrupt process termination (`SIGKILL`).

## Test architecture

```text
Debian Package (.deb)
        │
        ▼
Linux Environment (Debian/Ubuntu)
        │
        ▼
Installation (dpkg -i)
        │
        ▼
Configuration (/etc/satellite-telemetry/config.json)
        │
        ▼
Service Daemon (/etc/init.d/satellite-telemetry)
        │
        ▼
Integration Validation (HTTP /health, logs, PID, files)
        │
        ▼
Robot Framework & Custom Python Library
        │
        ▼
Test Evidence (report.html, log.html, output.xml)
```

## Test cases

| ID | Test Case | Type | Description |
|---|---|---|---|
| **TC-001** | Install Satellite Telemetry Package | Installation | Validates clean installation of the `.deb` package v1.0.0. |
| **TC-002** | Validate Installed Version | Installation | Verifies installed version reported by `dpkg-query` matches `1.0.0`. |
| **TC-003** | Validate Installed Files Structure | Installation | Confirms executables, configuration, and log directories exist. |
| **TC-004** | Validate Package Dependencies Requirement | Dependencies | Verifies declared dependencies (`python3`, `curl`). |
| **TC-005** | Validate Configuration File Schema | Configuration | Validates JSON schema and default values in `/etc/satellite-telemetry/config.json`. |
| **TC-006** | Validate Service Startup | Service | Starts service and confirms running state and PID creation. |
| **TC-007** | Validate Service Stop | Service | Stops service and confirms process termination and PID file cleanup. |
| **TC-008** | Health Endpoint Validation | Integration | Performs HTTP GET request to `/health` and asserts `200 OK` JSON body. |
| **TC-009** | Validate Log Generation and Formatting | Integration | Inspects `/var/log/satellite-telemetry/service.log` for expected log entries. |
| **TC-010** | Perform Package Upgrade to Version 1.1.0 | Upgrade | Upgrades installed package to v1.1.0 and checks updated version. |
| **TC-011** | Validate Configuration Preservation After Upgrade | Upgrade | Asserts user-modified configuration fields persist across upgrades. |
| **TC-012** | Validate Clean Package Removal | Removal | Purges package via `dpkg -P` and checks system file cleanup. |
| **TC-013** | Missing Dependency Scenario | Dependencies | Checks package dependency declaration logic. |
| **TC-014** | Invalid Configuration Scenario | Negative | Asserts service fails to start gracefully with malformed JSON config. |
| **TC-015** | Service Recovery After SIGKILL | Recovery | Kills daemon process with `SIGKILL` and verifies service restart capability. |

## Project structure

```text
robot-linux-integration-suite/
├── README.md
├── requirements.txt
├── Dockerfile
├── data/
│   ├── configs/
│   │   ├── valid_config.json
│   │   └── invalid_config.json
│   └── packages/                      # Built .deb artifacts
├── demo_service/
│   ├── src/satellite_telemetry.py    # Synthetic Python daemon
│   ├── debian_1.0.0/                 # Package structure v1.0.0
│   └── debian_1.1.0/                 # Package structure v1.1.0
├── libraries/
│   └── LinuxPackageLibrary.py        # Custom Robot Framework Python Library
├── resources/
│   ├── common.resource
│   ├── package_keywords.resource
│   ├── service_keywords.resource
│   └── validation_keywords.resource
├── tests/                            # Robot Framework Test Suites
├── scripts/
│   ├── build_deb.sh                  # Builds .deb packages locally
│   └── run_tests.sh                  # Executes full test suite
├── docs/                             # Engineering Case Study Portfolio
└── .github/workflows/robot-tests.yml # CI/CD Pipeline
```

## Running locally

### Prerequisites
- Linux OS (Debian, Ubuntu, or WSL2)
- Python 3.10+
- `dpkg-deb` and `dpkg` package management tools

### Execution Steps
1. Clone repository:
   ```bash
   git clone https://github.com/your-username/robot-linux-integration-suite.git
   cd robot-linux-integration-suite
   ```
2. Install Python requirements:
   ```bash
   pip install -r requirements.txt
   ```
3. Build `.deb` packages:
   ```bash
   ./scripts/build_deb.sh
   ```
4. Execute Robot Framework test suite (requires root privileges for `dpkg` installation tests):
   ```bash
   sudo ./scripts/run_tests.sh
   ```

## Running with Docker

Docker provides a fully isolated Debian container without modifying your local host operating system.

```bash
# Build Docker image
docker build -t robot-linux-suite .

# Run test suite and mount output directory for evidence artifacts
docker run --rm -v $(pwd)/output:/app/output robot-linux-suite
```

## Test evidence

After execution, Robot Framework generates evidence artifacts in the `output/` directory:

- `output/report.html`: High-level HTML summary report with pass/fail ratios and execution metrics.
- `output/log.html`: Detailed step-by-step execution log with exact keyword outputs, arguments, and timestamps.
- `output/output.xml`: Machine-readable XML results file suitable for CI/CD parsing.

## CI

GitHub Actions automatically executes the suite on push or pull requests. The workflow:

1. Provisions a clean Ubuntu environment.
2. Installs dependencies.
3. Builds synthetic Debian packages (`v1.0.0` and `v1.1.0`).
4. Executes the full Robot Framework test suite under root permissions.
5. Uploads `log.html`, `report.html`, and `output.xml` as workflow artifacts.

## Technologies

- **Robot Framework**: Keyword-driven test automation runner.
- **Python 3**: Custom keyword library and synthetic daemon implementation.
- **Linux Debian Packaging**: `.deb`, `dpkg`, `dpkg-deb`, `apt`.
- **Docker**: Isolated test execution environment.
- **GitHub Actions**: Continuous Integration pipeline.
