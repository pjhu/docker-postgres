#!/bin/bash
set -e

if [ $PG_ROLE = "master" ]; then
cat >> ${PGDATA}/postgresql.conf <<EOT
wal_level = replica
max_wal_senders = 10
wal_keep_segments = 256
archive_mode = on
EOT

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE USER $PG_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_REP_PASSWORD';
EOSQL

echo "host replication all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
fi
