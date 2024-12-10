#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    ALTER USER openobserve WITH SUPERUSER CREATEROLE;
    GRANT pg_read_all_data TO openobserve;
    GRANT pg_write_all_data TO openobserve;
EOSQL
