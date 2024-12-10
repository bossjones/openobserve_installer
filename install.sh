#!/usr/bin/env bash

set -e

# Function to check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Linux"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# Function to download and install OpenObserve
install_openobserve() {
    local os=$1
    local install_dir="/usr/local/bin"
    local download_url="https://github.com/openobserve/openobserve/releases/latest/download/openobserve-${os}-amd64"

    echo "Downloading OpenObserve..."
    curl -L -o "${install_dir}/openobserve" "${download_url}"
    chmod +x "${install_dir}/openobserve"
    echo "OpenObserve installed successfully in ${install_dir}"
}

# Function to create environment file
create_env_file() {
    local env_file="/etc/openobserve.env"
    echo "Creating environment file..."
    cat << EOF > "${env_file}"
ZO_ROOT_USER_EMAIL="root@example.com"
ZO_ROOT_USER_PASSWORD="Complexpass#123"
ZO_DATA_DIR="/data/openobserve"
EOF
    echo "Environment file created at ${env_file}"
}

# Function to create systemd service file
create_systemd_service() {
    local service_file="/etc/systemd/system/openobserve.service"
    echo "Creating systemd service file..."
    cat << EOF > "${service_file}"
[Unit]
Description=The OpenObserve server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
LimitNOFILE=65535
EnvironmentFile=/etc/openobserve.env
ExecStart=/usr/local/bin/openobserve
ExecStop=/bin/kill -s QUIT \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    echo "Systemd service file created at ${service_file}"
}

# Function to setup systemd service
setup_systemd() {
    echo "Setting up systemd service..."
    systemctl daemon-reload
    systemctl enable openobserve
    systemctl start openobserve
    echo "OpenObserve service started"
}

# Main execution
main() {
    check_root
    os=$(detect_os)

    if [ "$os" == "Linux" ]; then
        install_openobserve "linux"
        create_env_file
        create_systemd_service
        setup_systemd
    elif [ "$os" == "macOS" ]; then
        install_openobserve "darwin"
        echo "Note: Systemd is not available on macOS. You'll need to set up a launch daemon manually."
    else
        echo "Unsupported OS"
        exit 1
    fi

    echo "OpenObserve installation and setup completed successfully!"
}

main
