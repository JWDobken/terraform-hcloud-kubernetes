#!/bin/bash
set -euo pipefail

# Set firewall rules
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

ufw allow ssh
ufw allow 6443
ufw allow http
ufw allow https

ufw allow from ${subnet_ip_range}

ufw --force enable
ufw status verbose

ufw disable
