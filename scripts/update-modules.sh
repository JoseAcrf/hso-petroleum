#!/bin/bash

CONTAINER_NAME="hso_logistic"
DB_NAME="nombre_de_tu_bd"
MODULES=("mi_modulo_ventas" "mi_modulo_crm")  # Agrega tus módulos aquí

for MODULE in "${MODULES[@]}"; do
    echo "📥 Actualizando módulo: $MODULE"
    docker exec -it "$CONTAINER_NAME" odoo -u "$MODULE" -d "$DB_NAME"
done
