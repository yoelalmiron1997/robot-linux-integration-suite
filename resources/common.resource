*** Settings ***
Documentation    Common test suite setup, teardown and global variables.
Library          OperatingSystem
Library          Process
Library          RequestsLibrary
Library          ../libraries/LinuxPackageLibrary.py

*** Variables ***
${PACKAGE_NAME}         satellite-telemetry
${PACKAGE_V1_PATH}      ${CURDIR}/../data/packages/satellite-telemetry_1.0.0_all.deb
${PACKAGE_V2_PATH}      ${CURDIR}/../data/packages/satellite-telemetry_1.1.0_all.deb
${CONFIG_FILE_PATH}     /etc/satellite-telemetry/config.json
${LOG_FILE_PATH}        /var/log/satellite-telemetry/service.log
${PID_FILE_PATH}        /var/run/satellite-telemetry.pid
${VALID_CONFIG_SRC}     ${CURDIR}/../data/configs/valid_config.json
${INVALID_CONFIG_SRC}   ${CURDIR}/../data/configs/invalid_config.json
${SERVICE_URL}          http://127.0.0.1:8080

*** Keywords ***
Prepare Test Environment
    [Documentation]    Ensures clean baseline before suite execution.
    Log    Preparing test environment for ${PACKAGE_NAME}...    console=True
    Remove File    ${PID_FILE_PATH}
    
Restore Test Environment
    [Documentation]    Cleans up any running processes or temporary artifacts.
    Log    Restoring test environment...    console=True
    Run Keyword And Ignore Error    Stop Service    ${PACKAGE_NAME}
