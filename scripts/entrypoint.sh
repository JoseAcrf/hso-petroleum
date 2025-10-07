#!/bin/bash

DB_NAME="logisticdb"
DB_HOST="logisticdb"
DB_USER="odoo"
DB_PASS="${ODOO_DB_PASSWORD:-odoo}"

echo "⏳ Esperando que PostgreSQL esté disponible..."
until pg_isready -h $DB_HOST -p 5432 -U $DB_USER; do
  sleep 2
done

echo "🔍 Verificando existencia de la base de datos..."
EXISTS=$(psql -h $DB_HOST -U $DB_USER -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")

if [ "$EXISTS" != "1" ]; then
  echo "⚠️ Base '$DB_NAME' no existe. Creándola..."
  createdb -h $DB_HOST -U $DB_USER $DB_NAME
  echo "📥 Instalando módulo base..."
  odoo -i base -d $DB_NAME
fi

echo "🚀 Iniciando Odoo..."
exec odoo "$@"
