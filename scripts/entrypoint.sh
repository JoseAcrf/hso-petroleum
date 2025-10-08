#!/bin/bash
set -e

echo "🔧 Entrando al entrypoint..."

CONFIG_FILE="${ODOO_RC:-/opt/odoo/odoo.conf}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Archivo de configuración no encontrado: $CONFIG_FILE"
    exit 1
fi

echo "✅ Usando archivo de configuración: $CONFIG_FILE"

: ${HOST:=${DB_PORT_5432_TCP_ADDR:='hsodb'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${DBNAME:=${DB_NAME:='odoo'}}

DB_ARGS=(--db_host "$HOST" --db_port "$PORT" --db_user "$USER" --db_password "$PASSWORD")

echo "🔧 Verificando si la base '$DBNAME' está inicializada..."

psql_check=$(psql "postgresql://$USER:$PASSWORD@$HOST:$PORT/$DBNAME" -tAc "SELECT 1 FROM pg_class WHERE relname = 'ir_module_module'" || echo "0")

if [ "$psql_check" != "1" ]; then
    echo "⚙️ Base '$DBNAME' detectada sin módulos. Inicializando 'base'..."
    odoo -i base -d "$DBNAME" --config="$CONFIG_FILE" "${DB_ARGS[@]}" --without-demo=all
else
    echo "✅ Base '$DBNAME' ya contiene módulos. Continuando..."
fi

echo "🚀 Lanzando Odoo..."
exec odoo "${DB_ARGS[@]}" --config="$CONFIG_FILE"
