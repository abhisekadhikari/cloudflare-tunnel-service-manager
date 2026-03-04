#!/bin/bash

# --- ⚙️  CONFIG & UI COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
CHECK="✅"
ERROR="❌"
INFO="ℹ️"

# --- 🛡️  INITIAL CHECKS ---

# 1. Root Check
if [[ $EUID -ne 0 ]]; then
   echo -e "${ERROR} ${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

# 2. Argument Check
if [ $# -ne 3 ]; then
    echo -e "${INFO} ${BLUE}Usage:${NC} sudo $0 <appname> <domain> <local-port>"
    exit 1
fi

APPNAME=$1
DOMAIN=$2
PORT=$3
TUNNEL_NAME="${APPNAME}-tunnel"
ETC_DIR="/etc/cloudflared"

# 3. Dependency Check
echo -e "\n${BLUE}🔍 Checking dependencies...${NC}"
for cmd in cloudflared nc; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${ERROR} ${RED}$cmd is not installed.${NC} Please install it first."
        exit 1
    fi
done
echo -e "${CHECK} Dependencies met."

# 4. Certificate Check
USER_HOME=$(eval echo ~${SUDO_USER})
CERT_PATH="${USER_HOME}/.cloudflared/cert.pem"

if [ ! -f "$CERT_PATH" ]; then
    echo -e "${ERROR} ${RED}Cloudflare certificate not found at $CERT_PATH${NC}"
    echo "Please run: 'cloudflared tunnel login' as your normal user first."
    exit 1
fi

# --- 🚀 TUNNEL SETUP ---

echo -e "\n${BLUE}🛰️  Configuring Cloudflare Tunnel...${NC}"
mkdir -p $ETC_DIR

# Get or Create Tunnel
TUNNEL_ID=$(cloudflared tunnel list | grep "${TUNNEL_NAME}" | awk '{print $1}')
if [ -z "${TUNNEL_ID}" ]; then
    echo "Creating new tunnel: ${TUNNEL_NAME}..."
    CREATE_OUTPUT=$(cloudflared tunnel create ${TUNNEL_NAME})
    TUNNEL_ID=$(echo "${CREATE_OUTPUT}" | sed -n 's/.*Created tunnel .* with id \([^ ]*\).*/\1/p')
else
    echo -e "${CHECK} Existing tunnel found: ${TUNNEL_ID}"
fi

# Sync credentials
cp "${USER_HOME}/.cloudflared/${TUNNEL_ID}.json" "${ETC_DIR}/${TUNNEL_ID}.json"

# Generate Config
CONFIG_FILE="${ETC_DIR}/${APPNAME}.yml"
cat << EOF > ${CONFIG_FILE}
tunnel: ${TUNNEL_ID}
credentials-file: ${ETC_DIR}/${TUNNEL_ID}.json
ingress:
  - hostname: ${APPNAME}.${DOMAIN}
    service: http://localhost:${PORT}
  - service: http_status:404
EOF

# Route DNS
echo "Routing DNS for ${APPNAME}.${DOMAIN}..."
cloudflared tunnel route dns ${TUNNEL_NAME} ${APPNAME}.${DOMAIN} > /dev/null 2>&1

# --- 🛠️  SYSTEMD SERVICE ---

echo -e "${BLUE}⚙️  Creating Systemd Service...${NC}"
SERVICE_FILE="/etc/systemd/system/cloudflared-${APPNAME}.service"
LOG_FILE="/var/log/cloudflared-${APPNAME}.log"
touch $LOG_FILE

cat << EOF > ${SERVICE_FILE}
[Unit]
Description=Cloudflare Tunnel for ${APPNAME}
After=network.target

[Service]
Type=simple
User=root
ExecStartPre=/bin/bash -c 'until nc -z localhost ${PORT}; do echo "Waiting for local app on port ${PORT}..."; sleep 2; done'
ExecStart=/usr/local/bin/cloudflared tunnel --config ${CONFIG_FILE} run ${TUNNEL_NAME}
Restart=always
RestartSec=10
StandardOutput=append:${LOG_FILE}
StandardError=append:${LOG_FILE}

[Install]
WantedBy=multi-user.target
EOF

# Finalize
systemctl daemon-reload
systemctl enable cloudflared-${APPNAME} &> /dev/null
systemctl restart cloudflared-${APPNAME}

# --- 🏁  SUMMARY ---
echo -e "\n${GREEN}===============================================${NC}"
echo -e "${CHECK} ${GREEN}SUCCESS! Your tunnel is now a system service.${NC}"
echo -e "🔗  ${BLUE}URL:${NC} https://${APPNAME}.${DOMAIN}"
echo -e "🚥  ${BLUE}Health Check:${NC} Waiting for localhost:${PORT}"
echo -e "📜  ${BLUE}Logs:${NC} tail -f ${LOG_FILE}"
echo -e "🛠️  ${BLUE}Manage:${NC} systemctl status cloudflared-${APPNAME}"
echo -e "${GREEN}===============================================${NC}\n"