#!/bin/bash

DB_NAME="logisticdb"
DB_HOST="logisticdb"
DB_USER="odoo"
DB_PASS="odoo"  # valor fijo para evitar fallos si la variable no se define correctamente

export PGPASSWORD="$DB_PASS"

echo "⏳ Esperando que PostgreSQL esté disponible..."
until pg_isready -h "$DB_HOST" -p 5432 -U "$DB_USER" > /dev/null 2>&1; do
  echo "🔄 Esperando conexión con $DB_HOST..."
  sleep 2
done

echo "🔍 Verificando existencia de la base de datos '$DB_NAME'..."
EXISTS=$(psql -h "$DB_HOST" -U "$DB_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")

if [ "$EXISTS" != "1" ]; then
  echo "⚠️ Base '$DB_NAME' no existe. Creándola..."
  createdb -h "$DB_HOST" -U "$DB_USER" "$DB_NAME"
  echo "📥 Instalando módulo base..."
  odoo -i base -d "$DB_NAME"
else
  echo "🟢 Base '$DB_NAME' ya existe. No se requiere inicialización."
fi

echo "🚀 Iniciando Odoo con configuración desde /etc/odoo/odoo.conf..."
exec odoo
