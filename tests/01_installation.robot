*** Settings ***
Documentation    Suite for validating Debian package installation and initial file structure.
Resource         ../resources/common.resource
Resource         ../resources/package_keywords.resource
Resource         ../resources/validation_keywords.resource

Suite Setup      Prepare Test Environment
Suite Teardown   Restore Test Environment

*** Test Cases ***
TC-001 Install Satellite Telemetry Package
    [Documentation]    Validate clean installation of the Debian package v1.0.0.
    [Tags]             installation    smoke    linux    package
    Install Debian Package            ${PACKAGE_V1_PATH}
    Package Should Be Installed       ${PACKAGE_NAME}

TC-002 Validate Installed Version
    [Documentation]    Verify installed package version matches expected baseline version 1.0.0.
    [Tags]             installation    package
    Installed Package Version Should Be    ${PACKAGE_NAME}    1.0.0

TC-003 Validate Installed Files Structure
    [Documentation]    Verify presence of executables, configuration files, and log directories.
    [Tags]             installation    files
    Validate Package Files Installed
