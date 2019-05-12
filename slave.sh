#!/bin/bash
set -e

if [ $PG_ROLE = "slave" ]; then
    echo "*:*:*:$PG_REP_USER:$PG_REP_PASSWORD" > ~/.pgpass
    chmod 0600 ~/.pgpass
    pg_ctl -D "$PGDATA" -m fast -w stop
    rm -r "$PGDATA"/*
    until pg_basebackup -h $PG_MASTER_SERVICE_HOST -p $PG_MASTER_SERVICE_PORT -D ${PGDATA} -U ${PG_REP_USER} -vP -W
        do
            echo "Waiting for master to connect..."
            sleep 1s
    done

    echo "host replication all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"

cat > ${PGDATA}/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=$PG_MASTER_SERVICE_HOST port=$PG_MASTER_SERVICE_PORT user=$PG_REP_USER password=$PG_REP_PASSWORD'
trigger_file = '/tmp/touch_me_to_promote_to_me_master'
EOF

cat >> ${PGDATA}/postgresql.conf <<EOF
hot_standby = on
EOF

    chown postgres ${PGDATA}/recovery.conf
    chmod 600 ${PGDATA}/recovery.conf
    pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" -w start

exec "$@"
fi
