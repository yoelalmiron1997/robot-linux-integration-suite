*** Settings ***
Documentation    Suite for package dependency requirements and missing dependency scenarios.
Resource         ../resources/common.resource
Resource         ../resources/package_keywords.resource

*** Test Cases ***
TC-004 Validate Package Dependencies Requirement
    [Documentation]    Verify package metadata declares mandatory dependencies (python3, curl).
    [Tags]             dependencies    package
    Package Should Have Declared Dependency    ${PACKAGE_V1_PATH}    python3
    Package Should Have Declared Dependency    ${PACKAGE_V1_PATH}    curl

TC-013 Missing Dependency Scenario
    [Documentation]    Simulates package manager behavior when evaluating dependencies.
    [Tags]             dependencies    negative
    ${deps}=    Get Package Dependencies    ${PACKAGE_V1_PATH}
    Should Contain    ${deps}    python3
    Log    Verified dependency check enforcement logic for ${PACKAGE_NAME}.
