# -*- mode: conf -*-
FROM postgres:11.2

ENV PG_ROLE master
ENV PG_REP_USER replication
ENV PG_REP_PASSWORD replication
ENV PG_MASTER_SERVICE_HOST localhost
ENV PG_MASTER_SERVICE_PORT 5432

COPY master.sh /docker-entrypoint-initdb.d/
COPY slave.sh /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/*
