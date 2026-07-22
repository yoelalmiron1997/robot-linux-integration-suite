import os
import json
import subprocess
from robot.api import logger
from robot.api.deco import keyword


class LinuxPackageLibrary:
    """
    Custom Robot Framework Library for Linux Package & Service Inspection.
    Demonstrates extending Robot Framework capabilities using Python.
    """

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    @keyword("Package Should Be Installed")
    def package_should_be_installed(self, package_name):
        """Verifies that a Debian package is installed on the Linux host using dpkg-query."""
        cmd = ["dpkg-query", "-W", "-f=${Status}", package_name]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0 or "install ok installed" not in result.stdout:
            raise AssertionError(f"Package '{package_name}' is NOT installed. Status output: {result.stdout.strip()}")
        logger.info(f"Package '{package_name}' is correctly installed.")
        return True

    @keyword("Package Should Not Be Installed")
    def package_should_not_be_installed(self, package_name):
        """Verifies that a Debian package is not installed on the system."""
        cmd = ["dpkg-query", "-W", "-f=${Status}", package_name]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode == 0 and "install ok installed" in result.stdout:
            raise AssertionError(f"Package '{package_name}' IS installed, but expected to be removed.")
        logger.info(f"Verified package '{package_name}' is not installed.")
        return True

    @keyword("Get Installed Package Version")
    def get_installed_package_version(self, package_name):
        """Returns the version string of an installed Debian package."""
        cmd = ["dpkg-query", "-W", "-f=${Version}", package_name]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise AssertionError(f"Failed to query package version for '{package_name}': {result.stderr.strip()}")
        version = result.stdout.strip()
        logger.info(f"Installed package '{package_name}' version: {version}")
        return version

    @keyword("Get Package Dependencies")
    def get_package_dependencies(self, deb_file_path):
        """Extracts declared dependencies from a .deb package control metadata."""
        if not os.path.exists(deb_file_path):
            raise FileNotFoundError(f".deb package file not found: {deb_file_path}")
        cmd = ["dpkg-deb", "-f", deb_file_path, "Depends"]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0:
            raise AssertionError(f"Failed to extract dependencies from {deb_file_path}: {result.stderr.strip()}")
        deps = result.stdout.strip()
        logger.info(f"Declared dependencies for {deb_file_path}: {deps}")
        return deps

    @keyword("Read Service Log")
    def read_service_log(self, log_path, max_lines=50):
        """Reads and returns the last lines of a service log file."""
        if not os.path.exists(log_path):
            raise FileNotFoundError(f"Log file does not exist: {log_path}")
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
        recent_lines = "".join(lines[-int(max_lines):])
        logger.info(f"Read {len(lines[-int(max_lines):])} lines from log file {log_path}")
        return recent_lines

    @keyword("Service Log Should Contain")
    def service_log_should_contain(self, log_path, expected_text):
        """Asserts that a service log file contains expected string content."""
        log_content = self.read_service_log(log_path, max_lines=200)
        if expected_text not in log_content:
            raise AssertionError(f"Log file '{log_path}' does NOT contain expected text: '{expected_text}'")
        logger.info(f"Verified log file '{log_path}' contains: '{expected_text}'")

    @keyword("Validate Json Configuration")
    def validate_json_configuration(self, config_path, required_keys=None):
        """Parses a JSON configuration file and asserts required top-level keys."""
        if not os.path.exists(config_path):
            raise FileNotFoundError(f"Config file not found: {config_path}")
        with open(config_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        if required_keys:
            if isinstance(required_keys, str):
                required_keys = [k.strip() for k in required_keys.split(",")]
            missing_keys = [key for key in required_keys if key not in data]
            if missing_keys:
                raise AssertionError(f"Config file '{config_path}' is missing required keys: {missing_keys}")
        
        logger.info(f"Validated JSON configuration in '{config_path}' successfully.")
        return data

    @keyword("Get Process ID By Name")
    def get_process_id_by_name(self, process_name):
        """Returns the PID of a running process by name or script command using pgrep."""
        cmd = ["pgrep", "-f", process_name]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode != 0 or not result.stdout.strip():
            logger.info(f"Process matching '{process_name}' is not running.")
            return None
        pids = result.stdout.strip().splitlines()
        logger.info(f"Found process PIDs for '{process_name}': {pids}")
        return pids[0]
