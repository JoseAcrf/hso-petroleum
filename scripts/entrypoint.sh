#!/bin/bash

DB_NAME="logisticdb"
DB_HOST="logisticdb"
DB_USER="odoo"
DB_PASS="odoo"

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
else
  echo "🟢 Base '$DB_NAME' ya existe. No se requiere creación."
fi

echo "📋 Verificando si el módulo base está instalado..."
INSTALLED=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='base'")

if [ "$INSTALLED" != "installed" ]; then
  echo "📥 Instalando módulo base..."
  odoo -i base -d "$DB_NAME"
else
  echo "✅ Módulo base ya está instalado."
fi

echo "🚀 Iniciando Odoo con configuración desde /etc/odoo/odoo.conf..."
exec odoo
