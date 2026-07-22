FROM debian:bookworm-slim

# Avoid interactive prompts during apt package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    procps \
    dpkg \
    sed \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install python packages
COPY requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Copy application source code and tests
COPY . .

# Set execution permissions on scripts
RUN chmod +x scripts/*.sh

# Default command runs the entire Robot Framework test suite
CMD ["/bin/bash", "./scripts/run_tests.sh"]
