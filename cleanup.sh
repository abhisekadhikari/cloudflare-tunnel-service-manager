#!/bin/bash
# cleanup-tunnel.sh <appname> <domain>
APPNAME=$1
DOMAIN=$2

echo "🛑 Stopping and removing service..."
systemctl stop cloudflared-${APPNAME}
systemctl disable cloudflared-${APPNAME}
rm /etc/systemd/system/cloudflared-${APPNAME}.service
systemctl daemon-reload

echo "🗑️ Removing config files..."
rm /etc/cloudflared/${APPNAME}.yml
rm /var/log/cloudflared-${APPNAME}.log

echo "🌐 Deleting DNS route..."
cloudflared tunnel route dns delete ${APPNAME}.${DOMAIN}

echo "✅ Cleanup complete for ${APPNAME}"