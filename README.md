# 🛰️ Cloudflare Tunnel Systemd Manager

A professional-grade Bash toolkit to deploy and manage Cloudflare Tunnels as **automated systemd services**. This tool ensures your tunnels start on boot, restart on failure, and wait for your local application to be ready before connecting.

---

## ✨ Features

- **🔄 Auto-Boot:** Starts your tunnel automatically when the server restarts.
- **🛡️ Self-Healing:** Systemd monitors the process and restarts it if it crashes.
- **🚥 Smart Health Check:** Uses `netcat` to verify your local port is active before starting the tunnel.
- **📂 Organized Configs:** Moves credentials and YAML configs to `/etc/cloudflared/`.
- **📜 Persistent Logging:** Dedicated logs stored in `/var/log/cloudflared-[appname].log`.
- **🧹 Easy Cleanup:** Includes a script to safely remove all traces of the service and DNS.

---

## 🚀 Quick Start

### 1. Prerequisites

Ensure you have `cloudflared` installed and you are authenticated:

```bash
# Authenticate with Cloudflare
cloudflared tunnel login
```

---

### 2. Installation

Clone this repository and give the scripts execution permissions:

```bash
git clone https://github.com/YOUR_USERNAME/Cloudflare-Tunnel-Systemd-Manager.git
cd Cloudflare-Tunnel-Systemd-Manager
chmod +x *.sh
```

---

### 3. Deploy a Tunnel

Run the setup script with `sudo`. It requires three arguments:

```bash
# Usage: sudo ./setup-tunnel.sh <app-name> <domain> <local-port>
sudo ./setup-tunnel.sh myapp example.com 8080
```

---

## 🛠️ Management

**Check if the tunnel is running:**

```bash
systemctl status cloudflared-myapp
```

**Monitor live traffic/errors:**

```bash
tail -f /var/log/cloudflared-myapp.log
```

**Restart the tunnel:**

```bash
sudo systemctl restart cloudflared-myapp
```

---

## 🗑️ Uninstallation

To completely remove the service, configuration files, and the DNS route from Cloudflare:

```bash
# Usage: sudo ./cleanup.sh <app-name> <domain>
sudo ./cleanup.sh myapp example.com
```

---

## 📁 File Structure

| File | Description |
|------|-------------|
| `setup-tunnel.sh` | Main deployment script (Creates tunnel, DNS, and Systemd unit). |
| `cleanup.sh` | Uninstaller (Stops service and cleans up system files). |
| `README.md` | Documentation and usage guide. |

---

## ⚖️ License

This project is licensed under the MIT License - see the LICENSE file for details.