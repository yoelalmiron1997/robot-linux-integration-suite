#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

echo "============================================================"
echo " Robot Framework Linux Integration Testing Suite Runner"
echo "============================================================"

# Ensure packages are built
if [ ! -f "$ROOT_DIR/data/packages/satellite-telemetry_1.0.0_all.deb" ]; then
    echo "[INFO] Building Debian packages..."
    ./scripts/build_deb.sh
fi

echo "[INFO] Executing Robot Framework Test Suite..."

mkdir -p "$ROOT_DIR/output"

robot --outputdir "$ROOT_DIR/output" \
      --loglevel INFO \
      --name "Linux Integration Suite - Satellite Telemetry" \
      --tagdoc installation:"Installation Tests" \
      --tagdoc integration:"Integration Tests" \
      --tagdoc service:"Service Lifecycle Tests" \
      --tagdoc upgrade:"Package Upgrade Tests" \
      "$ROOT_DIR/tests/"

echo "============================================================"
echo " Test Execution Completed Successfully!"
echo " Reports generated in: $ROOT_DIR/output/"
echo " - Log: $ROOT_DIR/output/log.html"
echo " - Report: $ROOT_DIR/output/report.html"
echo "============================================================"
