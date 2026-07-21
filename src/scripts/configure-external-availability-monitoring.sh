cat >/usr/local/bin/check-availability.sh <<EOF
#!/bin/sh
set -eu

HTTP_STATUS="\$(curl --silent --output /dev/null --write-out '%{http_code}' --max-time 10 "${EXTERNAL_CHECK_URL}")"

if [ "\${HTTP_STATUS}" != "200" ]; then
  printf 'Verificação falhou: %s retornou %s\n' "${EXTERNAL_CHECK_URL}" "\${HTTP_STATUS}" >&2
  exit 1
fi
EOF
chmod +x /usr/local/bin/check-availability.sh

echo '*/5 * * * * /usr/local/bin/check-availability.sh || echo "Falha na verificação externa" | mail -s "Alerta de disponibilidade" seu-email@exemplo.com' | crontab -
