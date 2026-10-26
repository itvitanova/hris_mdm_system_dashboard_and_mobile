#!/bin/sh
set -eu
umask 077
cd /opt/hrismdm
stamp=$(date -u +%Y%m%dT%H%M%SZ)
docker compose exec -T postgres pg_dump -U hrismdm -d hrismdm -Fc > "backups/hrismdm-${stamp}.dump.partial"
mv "backups/hrismdm-${stamp}.dump.partial" "backups/hrismdm-${stamp}.dump"
printf '%s\n' "HRIS backup complete: hrismdm-${stamp}.dump"
