#!/bin/bash
set -e

echo "🔧 Entrando al entrypoint..."

# Validar archivo de configuración
CONFIG_FILE="${ODOO_RC:-/opt/odoo/odoo.conf}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Archivo de configuración no encontrado: $CONFIG_FILE"
    exit 1
fi

echo "✅ Usando archivo de configuración: $CONFIG_FILE"

# Leer contraseña si viene por archivo
if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< "$PASSWORD_FILE")"
fi

# Variables de entorno
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$CONFIG_FILE"; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$CONFIG_FILE" | cut -d "=" -f2 | tr -d ' "\n\r')
    fi
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}

check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

echo "🔧 Parámetros de conexión: ${DB_ARGS[*]}"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]]; then
            exec odoo "$@"
        else
            wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        if [ -z "$1" ]; then
            echo "❌ No se recibió ningún comando. Abortando."
            exit 1
        fi
        echo "✅ Ejecutando comando directo: $@"
        exec "$@"
        ;;
esac
