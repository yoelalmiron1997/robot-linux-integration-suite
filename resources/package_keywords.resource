*** Settings ***
Documentation    Keywords for managing Debian packages (dpkg / apt).
Resource         common.resource

*** Keywords ***
Install Debian Package
    [Arguments]    ${package_path}
    [Documentation]    Installs a local Debian .deb package using dpkg.
    File Should Exist    ${package_path}
    ${result}=    Run Process    dpkg    -i    --force-downgrade    ${package_path}    stderr=STDOUT
    Log    dpkg install output: ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0    msg=Failed to install .deb package ${package_path}

Remove Debian Package
    [Arguments]    ${package_name}
    [Documentation]    Purges a Debian package from the Linux environment.
    ${result}=    Run Process    dpkg    -P    ${package_name}    stderr=STDOUT
    Log    dpkg purge output: ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0    msg=Failed to remove package ${package_name}

Installed Package Version Should Be
    [Arguments]    ${package_name}    ${expected_version}
    [Documentation]    Verifies installed package version matches expected value.
    ${actual_version}=    Get Installed Package Version    ${package_name}
    Should Be Equal As Strings    ${actual_version}    ${expected_version}

Package Should Have Declared Dependency
    [Arguments]    ${package_path}    ${expected_dependency}
    [Documentation]    Validates that a package metadata declares expected dependency.
    ${deps}=    Get Package Dependencies    ${package_path}
    Should Contain    ${deps}    ${expected_dependency}
