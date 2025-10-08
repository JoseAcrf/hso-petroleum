#!/bin/bash
set -e

echo "Entrando al entrypoint..."

# Validar archivo de configuración
CONFIG_FILE="${ODOO_RC:-/opt/odoo/odoo.conf}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Archivo de configuración no encontrado: $CONFIG_FILE"
    exit 1
fi

echo "Usando archivo de configuración: $CONFIG_FILE"

# Variables de entorno
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='hsodb'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${DBNAME:=${DB_NAME:='odoo'}}

DB_ARGS=(--db_host "$HOST" --db_port "$PORT" --db_user "$USER" --db_password "$PASSWORD")

# Esperar a que PostgreSQL esté disponible usando script local
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Esperando a que PostgreSQL esté disponible en $HOST:$PORT..."
python3 "$SCRIPT_DIR/wait-for-psql.py" \
  --db_host="$HOST" \
  --db_port="$PORT" \
  --db_user="$USER" \
  --db_password="$PASSWORD" \
  --timeout=30

# Verificar si la base existe
echo "Verificando si la base '$DBNAME' existe en PostgreSQL..."
db_exists=$(psql "postgresql://$USER:$PASSWORD@$HOST:$PORT/postgres" -tAc "SELECT 1 FROM pg_database WHERE datname = '$DBNAME'" || echo "0")

if [ "$db_exists" = "1" ]; then
    echo "La base '$DBNAME' existe. Verificando si contiene tablas..."
    table_count=$(psql "postgresql://$USER:$PASSWORD@$HOST:$PORT/$DBNAME" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'" || echo "0")

    if [ "$table_count" -gt 0 ]; then
        echo "La base '$DBNAME' ya contiene tablas. Lanzando Odoo..."
        exec odoo "${DB_ARGS[@]}" --config="$CONFIG_FILE"
    else
        echo "La base '$DBNAME' existe pero está vacía. No se puede lanzar Odoo automáticamente."
        echo "Por favor crea la base desde el wizard o inicialízala con un script externo."
        exit 1
    fi
else
    echo "La base '$DBNAME' no existe. Mostrando wizard de creación..."
    exec odoo --config="$CONFIG_FILE"
fi
