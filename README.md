# 🛰️ Cloudflare Tunnel Systemd Manager

A professional-grade Bash toolkit to deploy and manage Cloudflare Tunnels as **automated systemd services**. This tool ensures your tunnels start on boot, restart on failure, and wait for your local application to be ready before connecting.

---

## ✨ Features

* **🔄 Auto-Boot:** Starts your tunnel automatically when the server restarts.
* **🛡️ Self-Healing:** Systemd monitors the process and restarts it if it crashes.
* **🚥 Smart Health Check:** Uses `netcat` to verify your local port is active before starting the tunnel.
* **📂 Organized Configs:** Moves credentials and YAML configs to `/etc/cloudflared/`.
* **📜 Persistent Logging:** Dedicated logs stored in `/var/log/cloudflared-[appname].log`.
* **🧹 Easy Cleanup:** Includes a script to safely remove all traces of the service and DNS.

---

# 🚀 Quick Start

## 1. Install `cloudflared`

Install `cloudflared` from the official Cloudflare package repository.

Official repository documentation:
https://pkg.cloudflare.com/index.html

### Ubuntu / Debian

```bash
# Add Cloudflare GPG key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
  | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add Cloudflare repository
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Install cloudflared
sudo apt update
sudo apt install cloudflared
```

Verify installation:

```bash
cloudflared --version
```

---

## 2. Authenticate with Cloudflare

```bash
cloudflared tunnel login
```

This will open a browser window allowing you to authorize your server with your Cloudflare account.

---

## 3. Installation

Clone this repository and give the scripts execution permissions:

```bash
git clone https://github.com/YOUR_USERNAME/Cloudflare-Tunnel-Systemd-Manager.git
cd Cloudflare-Tunnel-Systemd-Manager
chmod +x *.sh
```

---

## 4. Deploy a Tunnel

Run the setup script with `sudo`. It requires three arguments:

```bash
# Usage: sudo ./setup-tunnel.sh <app-name> <domain> <local-port>
sudo ./setup-tunnel.sh myapp example.com 8080
```

Example:

```bash
sudo ./setup-tunnel.sh api api.example.com 3000
```

This script will:

* Create a Cloudflare tunnel
* Generate credentials
* Configure DNS routing
* Move configuration files to `/etc/cloudflared/`
* Create a **systemd service**
* Enable automatic startup on boot

---

# 🛠️ Management

### Check if the tunnel is running

```bash
systemctl status cloudflared-myapp
```

### Monitor live traffic or errors

```bash
tail -f /var/log/cloudflared-myapp.log
```

### Restart the tunnel

```bash
sudo systemctl restart cloudflared-myapp
```

### Stop the tunnel

```bash
sudo systemctl stop cloudflared-myapp
```

---

# 🗑️ Uninstallation

To completely remove the service, configuration files, and the DNS route from Cloudflare:

```bash
# Usage: sudo ./cleanup.sh <app-name> <domain>
sudo ./cleanup.sh myapp example.com
```

The cleanup script will:

* Stop and disable the systemd service
* Remove `/etc/cloudflared/` configs
* Delete logs
* Remove DNS routing from Cloudflare

---

# 📁 File Structure

| File              | Description                                                    |
| ----------------- | -------------------------------------------------------------- |
| `setup-tunnel.sh` | Main deployment script (creates tunnel, DNS, and systemd unit) |
| `cleanup.sh`      | Uninstaller (stops service and cleans system files)            |
| `README.md`       | Documentation and usage guide                                  |

---

# ⚖️ License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.
