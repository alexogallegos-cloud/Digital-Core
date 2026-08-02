#!/bin/bash
# =============================================================================
# user-data para la EC2 del DEMO (Amazon Linux 2023, x86 — SQL Server exige x86).
# Garantiza que la instancia se AUTO-DETIENE 60 min después de cada arranque.
#
# Requisito en el launch (run-instances): la instancia debe iniciar con
#   --instance-initiated-shutdown-behavior stop
# para que el `shutdown -h` la DETENGA (deja de facturar cómputo) y NO la termine.
#
# Se usa systemd (no cron): AL2023 no instala cron por defecto. El servicio queda
# 'enabled', así que se ejecuta en CADA boot y rearma el apagado desde cero.
# =============================================================================
set -euxo pipefail

cat >/etc/systemd/system/auto-stop-demo.service <<'EOF'
[Unit]
Description=Auto-stop demo EC2 60 min despues de cada arranque
After=multi-user.target

[Service]
Type=oneshot
# Programa el apagado (STOP de la instancia) 60 min despues del boot.
ExecStart=/sbin/shutdown -h +60 "Auto-stop: demo limitado a 1h"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable auto-stop-demo.service
# 'start' arma el apagado tambien para ESTE primer arranque (user-data corre 1 vez).
systemctl start auto-stop-demo.service

# ---------------------------------------------------------------------------
# (Opcional) Arranque de la app en la misma caja. Descomentar y ajustar:
#   dnf install -y docker && systemctl enable --now docker
#   docker compose -f /opt/nomina/docker-compose.yml up -d
# o bien servicios systemd para nomina-api (Java) + SQL Server Express + Nginx.
# ---------------------------------------------------------------------------
