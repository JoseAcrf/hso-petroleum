#!/bin/bash
set -e

# 🧠 Variables de entorno para PostgreSQL
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='petroleumdb'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo19@2024'}}}

# 🧠 Crear usuario odoo si no existe
if ! id -u odoo >/dev/null 2>&1; then
    useradd -m -d /var/lib/odoo -s /bin/bash odoo
fi

# 🔐 Corregir permisos para evitar errores de escritura
chown -R odoo:odoo /var/lib/odoo

# 📦 Instalar dependencias Python (forzando entorno gestionado)
pip install --break-system-packages -r /etc/odoo/requirements.txt || echo "⚠️ pip install falló, pero el entorno puede estar preinstalado."

# 🔁 Instalar logrotate si no está presente
if ! dpkg -l | grep -q logrotate; then
    apt-get update && apt-get install -y logrotate
fi

# 📁 Configurar logrotate
cp /etc/odoo/logrotate /etc/logrotate.d/odoo
cron

# 🧠 Construir argumentos de conexión a PostgreSQL
DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

# 🔍 Diagnóstico: mostrar bases existentes
echo "🔍 Listando bases de datos existentes..."
export PGPASSWORD="$PASSWORD"
DB_LIST=$(psql -h "$HOST" -U "$USER" -tAc "SELECT datname FROM pg_database WHERE datistemplate = false")

if [ -z "$DB_LIST" ]; then
  echo "⚠️ No hay bases de datos disponibles. Mostrando pantalla de bienvenida..."
else
  echo "🟢 Bases existentes:"
  echo "$DB_LIST"
fi

# 🚀 Lanzar Odoo como usuario correcto
case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec su -s /bin/bash odoo -c "odoo $*"
        else
            su -s /bin/bash odoo -c "wait-for-psql.py ${DB_ARGS[@]} --timeout=30 && odoo $* ${DB_ARGS[@]}"
        fi
        ;;
    -*)
        su -s /bin/bash odoo -c "wait-for-psql.py ${DB_ARGS[@]} --timeout=30 && odoo $* ${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 
