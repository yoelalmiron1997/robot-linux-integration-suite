*** Settings ***
Documentation    Keywords for controlling and inspecting Linux services and HTTP endpoints.
Resource         common.resource

*** Keywords ***
Start Service
    [Arguments]    ${service_name}
    [Documentation]    Starts the specified Linux service via init.d script.
    ${result}=    Run Process    /etc/init.d/${service_name}    start    stderr=STDOUT
    Log    Service start output: ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0    msg=Failed to start service ${service_name}

Stop Service
    [Arguments]    ${service_name}
    [Documentation]    Stops the specified Linux service.
    ${result}=    Run Process    /etc/init.d/${service_name}    stop    stderr=STDOUT
    Log    Service stop output: ${result.stdout}

Service Should Be Running
    [Arguments]    ${service_name}
    [Documentation]    Verifies that the Linux service status is running.
    ${result}=    Run Process    /etc/init.d/${service_name}    status    stderr=STDOUT
    Log    Service status output: ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0    msg=Service ${service_name} is not running
    File Should Exist    ${PID_FILE_PATH}

Service Should Be Stopped
    [Arguments]    ${service_name}
    [Documentation]    Verifies that the service is stopped and PID file is removed.
    ${result}=    Run Process    /etc/init.d/${service_name}    status    stderr=STDOUT
    Should Not Be Equal As Integers    ${result.rc}    0
    File Should Not Exist    ${PID_FILE_PATH}

Query Health Endpoint
    [Documentation]    Sends a GET HTTP request to the /health endpoint with retry logic for port readiness.
    Create Session    telemetry_session    ${SERVICE_URL}    verify=False    disable_warnings=1
    ${response}=    Wait Until Keyword Succeeds    5x    1s    GET On Session    telemetry_session    /health
    RETURN    ${response}
