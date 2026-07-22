*** Settings ***
Documentation    Keywords for configuration, log, and filesystem validations.
Resource         common.resource

*** Keywords ***
Validate Package Files Installed
    [Documentation]    Verifies expected binaries and directories are present after installation.
    File Should Exist    /usr/bin/satellite-telemetry
    File Should Exist    /etc/init.d/satellite-telemetry
    File Should Exist    ${CONFIG_FILE_PATH}
    Directory Should Exist    /var/log/satellite-telemetry

Validate Package Files Removed
    [Documentation]    Verifies binaries and configuration files are removed after package purge.
    File Should Not Exist    /usr/bin/satellite-telemetry
    File Should Not Exist    /etc/init.d/satellite-telemetry

Validate Configuration Content
    [Arguments]    ${expected_version}
    [Documentation]    Validates key fields in the service configuration file.
    ${cfg}=    Validate Json Configuration    ${CONFIG_FILE_PATH}    service_name,version,port
    Should Be Equal As Strings    ${cfg["service_name"]}    satellite-telemetry
    Should Be Equal As Strings    ${cfg["version"]}    ${expected_version}

Set Configuration File
    [Arguments]    ${source_config_path}
    [Documentation]    Overwrites the service configuration file with custom test config.
    Copy File    ${source_config_path}    ${CONFIG_FILE_PATH}
