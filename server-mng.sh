#!/bin/bash

# Server script: tinyfecvpn_server.sh

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

function isRoot() {
    if [ "${EUID}" -ne 0 ]; then
        echo -e "${RED}You need to run this script as root${NC}"
        exit 1
    fi
}

function checkVirt() {
    if [ "$(systemd-detect-virt)" == "openvz" ]; then
        echo -e "${RED}OpenVZ is not supported${NC}"
        exit 1
    fi

    if [ "$(systemd-detect-virt)" == "lxc" ]; then
        echo -e "${RED}LXC is not supported${NC}"
        exit 1
    fi
}

function checkOS() {
    source /etc/os-release
    OS="${ID}"
    if [[ ${OS} == "debian" || ${OS} == "raspbian" ]]; then
        if [[ ${VERSION_ID} -lt 10 ]]; then
            echo -e "${RED}Your version of Debian (${VERSION_ID}) is not supported. Please use Debian 10 Buster or later${NC}"
            exit 1
        fi
        OS=debian # overwrite if raspbian
    else
        echo -e "${RED}Looks like you aren't running this installer on a Debian-based system${NC}"
        exit 1
    fi
}

function installDependencies() {
    echo -e "${GREEN}Updating package lists and installing dependencies...${NC}"
    apt update
    apt install -y wget iptables
}

function downloadAndExtractTinyFecVPN() {
    echo -e "${GREEN}Downloading TinyFecVPN precompiled binaries...${NC}"
    wget https://github.com/wangyu-/tinyfecVPN/releases/download/20230206.0/tinyvpn_binaries.tar.gz -O /opt/tinyvpn_binaries.tar.gz
    echo -e "${GREEN}Extracting TinyFecVPN binaries...${NC}"
    tar -xzf /opt/tinyvpn_binaries.tar.gz -C /opt/
    chmod +x /opt/tinyfecVPN/tinyvpn_amd64
}

function configureServerRouting() {
    echo -e "${GREEN}Configuring server-side routing and iptables...${NC}"
    iptables -t nat -A POSTROUTING -s ${SUBNET}/24 -o eth0 -j MASQUERADE
    echo 1 > /proc/sys/net/ipv4/ip_forward
    if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    fi
    sysctl -p
}

function createSystemdService() {
    echo -e "${GREEN}Creating systemd service for TinyFecVPN...${NC}"
    cat <<EOF >/etc/systemd/system/tinyfecvpn.service
[Unit]
Description=TinyFecVPN Service
After=network.target

[Service]
ExecStart=/opt/tinyvpn_amd64 -s -l0.0.0.0:${PORT} -f${FEC} -k "${PASSWORD}" --sub-net ${SUBNET}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable tinyfecvpn.service
    systemctl start tinyfecvpn.service
}

function serverMenu() {
    while true; do
        echo -e "${ORANGE}Server Management Menu:${NC}"
        echo "1) Check if TinyFecVPN service is running"
        echo "2) Restart TinyFecVPN service"
        echo "3) Stop TinyFecVPN service"
        echo "4) Remove TinyFecVPN service"
        echo "5) Exit"
        read -rp "Choose an option: " OPTION
        case $OPTION in
            1)
                systemctl is-active --quiet tinyfecvpn.service && echo -e "${GREEN}TinyFecVPN is running${NC}" || echo -e "${RED}TinyFecVPN is not running${NC}"
                ;;
            2)
                echo -e "${GREEN}Restarting TinyFecVPN service...${NC}"
                systemctl restart tinyfecvpn.service
                ;;
            3)
                echo -e "${RED}Stopping TinyFecVPN service...${NC}"
                systemctl stop tinyfecvpn.service
                ;;
            4)
                echo -e "${RED}Removing TinyFecVPN service...${NC}"
                systemctl stop tinyfecvpn.service
                systemctl disable tinyfecvpn.service
                rm /etc/systemd/system/tinyfecvpn.service
                systemctl daemon-reload
                echo -e "${GREEN}TinyFecVPN service removed successfully${NC}"
                ;;
            5)
                break
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

function getUserParams() {
    echo -e "${ORANGE}Please provide the necessary parameters for TinyFecVPN server.${NC}"
    read -rp "Port to use (e.g., 4096) [Default: 4096]: " PORT
    PORT=${PORT:-4096}

    while true; do
        if [[ ${PORT} =~ ^[0-9]+$ && ${PORT} -ge 1 && ${PORT} -le 65535 ]]; then
            break
        else
            echo -e "${RED}Invalid port. Please enter a number between 1 and 65535.${NC}"
            read -rp "Port to use (e.g., 4096) [Default: 4096]: " PORT
            PORT=${PORT:-4096}
        fi
    done

    read -rp "FEC parameters (e.g., 20:10) [Default: 20:10]: " FEC
    FEC=${FEC:-20:10}

    while true; do
        if [[ ${FEC} =~ ^[0-9]+:[0-9]+$ ]]; then
            break
        else
            echo -e "${RED}Invalid FEC parameters. Please enter in the format 'x:y', where x and y are numbers.${NC}"
            read -rp "FEC parameters (e.g., 20:10) [Default: 20:10]: " FEC
            FEC=${FEC:-20:10}
        fi
    done

    read -rp "Password [Default: secret]: " PASSWORD
    PASSWORD=${PASSWORD:-secret}

    while true; do
        if [[ -n ${PASSWORD} ]]; then
            break
        else
            echo -e "${RED}Password cannot be empty. Please enter a valid password.${NC}"
            read -rp "Password [Default: secret]: " PASSWORD
            PASSWORD=${PASSWORD:-secret}
        fi
    done

    read -rp "Subnet (e.g., 10.22.22.0) [Default: 10.22.22.0]: " SUBNET
    SUBNET=${SUBNET:-10.22.22.0}

    while true; do
        if [[ ${SUBNET} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            break
        else
            echo -e "${RED}Invalid subnet. Please enter a valid IP address in the format 'x.x.x.x'.${NC}"
            read -rp "Subnet (e.g., 10.22.22.0) [Default: 10.22.22.0]: " SUBNET
            SUBNET=${SUBNET:-10.22.22.0}
        fi
    done
}

# Main script execution for server
isRoot
checkVirt
checkOS
installDependencies
downloadAndExtractTinyFecVPN

if [ -f /etc/systemd/system/tinyfecvpn.service ]; then
    serverMenu
else
    getUserParams
    createSystemdService
    serverMenu
fi
