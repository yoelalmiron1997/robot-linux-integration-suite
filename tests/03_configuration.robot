*** Settings ***
Documentation    Suite for configuration file validation and negative invalid syntax testing.
Resource         ../resources/common.resource
Resource         ../resources/service_keywords.resource
Resource         ../resources/validation_keywords.resource

Test Setup       Prepare Test Environment
Test Teardown    Restore Test Environment

*** Test Cases ***
TC-005 Validate Configuration File Schema
    [Documentation]    Validate that the installed JSON config file contains valid keys and default values.
    [Tags]             configuration    linux
    Validate Configuration Content    1.0.0

TC-014 Invalid Configuration Scenario
    [Documentation]    Verify that service fails to start gracefully when config file contains invalid JSON.
    [Tags]             configuration    negative    service
    Set Configuration File           ${INVALID_CONFIG_SRC}
    ${result}=    Run Process        /usr/bin/satellite-telemetry    run    --config    ${CONFIG_FILE_PATH}    stderr=STDOUT
    Should Not Be Equal As Integers  ${result.rc}    0
    Should Contain                   ${result.stdout}    CRITICAL
    # Restore valid config for subsequent tests
    Set Configuration File           ${VALID_CONFIG_SRC}
