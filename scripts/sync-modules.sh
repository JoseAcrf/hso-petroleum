#!/bin/bash

REPO_PATH="/opt/odoo/hso-logistics"
MODULE_PATH="$REPO_PATH/addonsv2/mt/extra-addons"
CONTAINER_NAME="hso_logistic"

echo "🔄 Sincronizando repositorio desde GitHub..."
cd "$REPO_PATH" || exit 1
git pull origin master

echo "📦 Verificando cambios en módulos..."
CHANGED=$(git diff --name-only HEAD~1 HEAD | grep "addonsv2/mt/extra-addons")

if [ -n "$CHANGED" ]; then
    echo "✅ Se detectaron cambios en los módulos:"
    echo "$CHANGED"
    echo "🔁 Reiniciando contenedor Odoo..."
    docker restart "$CONTAINER_NAME"
else
    echo "🟢 No hay cambios en los módulos. No se reinicia Odoo."
fi
