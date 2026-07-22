*** Settings ***
Documentation    Suite for package removal/purge testing and clean filesystem validation.
Resource         ../resources/common.resource
Resource         ../resources/package_keywords.resource
Resource         ../resources/service_keywords.resource
Resource         ../resources/validation_keywords.resource

*** Test Cases ***
TC-012 Validate Clean Package Removal
    [Documentation]    Purge package using dpkg -P and verify binaries and init scripts are removed.
    [Tags]             removal    package    clean
    Install Debian Package            ${PACKAGE_V1_PATH}
    Package Should Be Installed       ${PACKAGE_NAME}
    Remove Debian Package             ${PACKAGE_NAME}
    Package Should Not Be Installed   ${PACKAGE_NAME}
    Validate Package Files Removed
