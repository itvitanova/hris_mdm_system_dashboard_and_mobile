#!/bin/sh
set -eu
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" --set app_password="$POSTGRES_APP_PASSWORD" <<'SQL'
CREATE ROLE hrismdm LOGIN PASSWORD :'app_password';
ALTER DATABASE hrismdm OWNER TO hrismdm;
SQL
