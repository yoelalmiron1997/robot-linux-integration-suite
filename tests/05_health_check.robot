*** Settings ***
Documentation    Integration test suite for HTTP /health REST endpoint validation.
Resource         ../resources/common.resource
Resource         ../resources/service_keywords.resource

Suite Setup      Start Service And Verify
Suite Teardown   Stop Service     ${PACKAGE_NAME}

*** Keywords ***
Start Service And Verify
    Start Service                ${PACKAGE_NAME}
    Service Should Be Running    ${PACKAGE_NAME}

*** Test Cases ***
TC-008 Health Endpoint Validation
    [Documentation]    Validate HTTP GET /health returns 200 OK with expected JSON payload.
    [Tags]             integration    health    service
    ${response}=                 Query Health Endpoint
    Should Be Equal As Integers  ${response.status_code}    200
    ${json}=                     Set Variable               ${response.json()}
    Should Be Equal As Strings   ${json["status"]}          ok
    Should Be Equal As Strings   ${json["service"]}         satellite-telemetry
    Should Be Equal As Strings   ${json["version"]}         1.0.0
