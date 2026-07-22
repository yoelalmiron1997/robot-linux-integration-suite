#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Building Debian Packages for Satellite Telemetry Service ==="

PACKAGES_DIR="$ROOT_DIR/data/packages"
mkdir -p "$PACKAGES_DIR"

# Source code location
SRC_FILE="$ROOT_DIR/demo_service/src/satellite_telemetry.py"

build_version() {
    local VERSION="$1"
    local DEB_DIR="$ROOT_DIR/demo_service/debian_$VERSION"
    local TARGET_DEB="$PACKAGES_DIR/satellite-telemetry_${VERSION}_all.deb"

    echo "Building Debian Package version $VERSION..."
    
    mkdir -p "$DEB_DIR/usr/bin"
    cp "$SRC_FILE" "$DEB_DIR/usr/bin/satellite-telemetry"
    chmod +x "$DEB_DIR/usr/bin/satellite-telemetry"
    chmod +x "$DEB_DIR/DEBIAN/postinst" "$DEB_DIR/DEBIAN/prerm" "$DEB_DIR/etc/init.d/satellite-telemetry"

    # Set proper permissions for Debian package build
    chmod -R 755 "$DEB_DIR/DEBIAN"
    
    dpkg-deb --build "$DEB_DIR" "$TARGET_DEB"
    echo "[SUCCESS] Package generated at: $TARGET_DEB"
}

build_version "1.0.0"
build_version "1.1.0"

echo "=== Debian Package Build Completed ==="
