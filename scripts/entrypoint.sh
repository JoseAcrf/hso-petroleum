#!/bin/bash

DB_HOST="petroleumdb"
DB_USER="odoo"
DB_PASS="odoo"

export PGPASSWORD="$DB_PASS"

echo "⏳ Esperando que PostgreSQL esté disponible..."
until pg_isready -h "$DB_HOST" -p 5433 -U "$DB_USER" > /dev/null 2>&1; do
  echo "🔄 Esperando conexión con $DB_HOST..."
  sleep 2
done

echo "🔍 Listando bases de datos existentes..."
DB_LIST=$(psql -h "$DB_HOST" -U "$DB_USER" -tAc "SELECT datname FROM pg_database WHERE datistemplate = false")

if [ -z "$DB_LIST" ]; then
  echo "⚠️ No hay bases de datos disponibles. Mostrando pantalla de bienvenida..."
else
  echo "🟢 Bases existentes:"
  echo "$DB_LIST"
fi

echo "🚀 Iniciando Odoo sin forzar creación de base..."
exec odoo
