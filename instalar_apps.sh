#!/bin/bash

# ------------------------------
# Links dos arquivos no GitHub
# ------------------------------
SCRIPT_URL="https://raw.githubusercontent.com/FelypeSposito/script/refs/heads/main/scriptApps.sh"
NINJA_URL="https://raw.githubusercontent.com/FelypeSposito/script/refs/heads/main/Ninja_MDM.pkg"

# ------------------------------
# Download do script de apps
# ------------------------------
echo "📥 Baixando script de apps..."
curl -L -o /tmp/scriptApps.sh "$SCRIPT_URL"
chmod +x /tmp/scriptApps.sh

# ------------------------------
# Download do NinjaOne Agent para a Área de Trabalho
# ------------------------------
echo "📥 Baixando NinjaOne Agent na Área de Trabalho..."
curl -L -o ~/Desktop/Ninja_MDM.pkg "$NINJA_URL"

# ------------------------------
# Executa o script de apps
# ------------------------------
echo "🚀 Executando script de apps..."
/tmp/scriptApps.sh

# ------------------------------
# Opcional: instalar o NinjaOne
# ------------------------------
# sudo installer -pkg ~/Desktop/Ninja_MDM.pkg -target /
# Se quiser instalar automaticamente, descomente a linha acima
