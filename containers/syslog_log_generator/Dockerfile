FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    netcat-openbsd \
    bsdutils \
    && rm -rf /var/lib/apt/lists/*

# Copy the log generation script
COPY generate_logs.sh /usr/local/bin/generate_logs.sh

# Make the script executable
RUN chmod +x /usr/local/bin/generate_logs.sh

# Keep container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
