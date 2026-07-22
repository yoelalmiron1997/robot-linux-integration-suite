*** Settings ***
Documentation    Suite for service lifecycle management: start, stop, and process recovery.
Resource         ../resources/common.resource
Resource         ../resources/service_keywords.resource

Test Setup       Prepare Test Environment
Test Teardown    Restore Test Environment

*** Test Cases ***
TC-006 Validate Service Startup
    [Documentation]    Start service and verify process status and PID creation.
    [Tags]             service    smoke
    Start Service             ${PACKAGE_NAME}
    Service Should Be Running  ${PACKAGE_NAME}

TC-007 Validate Service Stop
    [Documentation]    Stop service and verify process termination and PID file removal.
    [Tags]             service
    Start Service             ${PACKAGE_NAME}
    Service Should Be Running  ${PACKAGE_NAME}
    Stop Service              ${PACKAGE_NAME}
    Service Should Be Stopped  ${PACKAGE_NAME}

TC-015 Service Recovery After SIGKILL
    [Documentation]    Simulate ungraceful crash (SIGKILL) and verify recovery restart.
    [Tags]             service    recovery
    Start Service             ${PACKAGE_NAME}
    Service Should Be Running  ${PACKAGE_NAME}
    ${pid}=                   Get Process Id By Name    satellite-telemetry
    Run Process               kill    -9    ${pid}
    Sleep                     1s
    Start Service             ${PACKAGE_NAME}
    Service Should Be Running  ${PACKAGE_NAME}
