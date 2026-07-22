*** Settings ***
Documentation    Suite for Debian package upgrade testing and config file preservation.
Resource         ../resources/common.resource
Resource         ../resources/package_keywords.resource
Resource         ../resources/service_keywords.resource
Resource         ../resources/validation_keywords.resource

Suite Setup      Prepare Test Environment
Suite Teardown   Restore Test Environment

*** Test Cases ***
TC-010 Perform Package Upgrade to Version 1.1.0
    [Documentation]    Upgrade installed package from 1.0.0 to 1.1.0 via dpkg -i.
    [Tags]             upgrade    package
    Install Debian Package                 ${PACKAGE_V1_PATH}
    Installed Package Version Should Be    ${PACKAGE_NAME}    1.0.0
    Install Debian Package                 ${PACKAGE_V2_PATH}
    Installed Package Version Should Be    ${PACKAGE_NAME}    1.1.0

TC-011 Validate Configuration Preservation After Upgrade
    [Documentation]    Verify modified configuration settings persist after package upgrade.
    [Tags]             upgrade    configuration
    # Modify local config
    Run Process                            sed    -i    s/8080/9090/g    ${CONFIG_FILE_PATH}
    Install Debian Package                 ${PACKAGE_V2_PATH}
    ${cfg}=    Validate Json Configuration    ${CONFIG_FILE_PATH}    port
    Should Be Equal As Strings             ${cfg["port"]}     9090
    # Restore original config for subsequent tests
    Run Process                            sed    -i    s/9090/8080/g    ${CONFIG_FILE_PATH}
