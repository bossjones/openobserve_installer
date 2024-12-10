FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    netcat-openbsd \
    bsdutils \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-venv \
    iputils-ping \
    net-tools \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy the log generation script
COPY generate_logs.sh /usr/local/bin/generate_logs.sh
COPY syslog_gen.py /usr/local/bin/syslog_gen.py
COPY sample_logs.txt /usr/local/bin/sample_logs.txt

# Make the script executable
RUN chmod +x /usr/local/bin/generate_logs.sh

# Keep container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
