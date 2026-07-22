*** Settings ***
Documentation    Suite for log generation and log format assertions.
Resource         ../resources/common.resource
Resource         ../resources/service_keywords.resource

Suite Setup      Start Service And Verify
Suite Teardown   Stop Service     ${PACKAGE_NAME}

*** Keywords ***
Start Service And Verify
    Start Service                ${PACKAGE_NAME}
    Service Should Be Running    ${PACKAGE_NAME}

*** Test Cases ***
TC-009 Validate Log Generation and Formatting
    [Documentation]    Verify that log file is created and contains service startup messages.
    [Tags]             integration    logs
    Query Health Endpoint
    Service Log Should Contain    ${LOG_FILE_PATH}    Starting Satellite Telemetry Service
    Service Log Should Contain    ${LOG_FILE_PATH}    HTTP GET /health - 200 OK
