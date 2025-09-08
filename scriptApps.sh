#!/bin/bash

# ======================
# Função para remover resíduos de apps
# ======================
remove_app_data() {
    local app_name="$1"
    local bundle_id="$2"

    echo "🧹 Removendo dados do $app_name ..."

    sudo rm -rf "/Applications/$app_name.app"
    rm -rf "$HOME/Library/Application Support/$app_name"
    rm -rf "$HOME/Library/Caches/$bundle_id"
    rm -rf "$HOME/Library/Preferences/$bundle_id.plist"
    rm -rf "$HOME/Library/Logs/$app_name"
    rm -rf "$HOME/Library/Saved Application State/$bundle_id.savedState"
    rm -rf "$HOME/Library/Cookies/$bundle_id.binarycookies"

    echo "✅ $app_name removido completamente!"
}

# ======================
# Função para instalar via Homebrew Cask
# ======================
install_app_brew() {
    local name="$1"

    if [ -d "/Applications/$name.app" ]; then
        echo "⚠️ $name já está instalado, pulando..."
    else
        echo "🔽 Instalando $name via Homebrew..."
        BREW_PATH=$(which brew || echo "/opt/homebrew/bin/brew")
        $BREW_PATH uninstall --cask --force "$name" &>/dev/null || true
        $BREW_PATH cleanup "$name" &>/dev/null || true
        $BREW_PATH install --cask "$name"

        if [ -d "/Applications/$name.app" ]; then
            echo "✅ $name instalado com sucesso!"
        else
            echo "❌ Falha ao instalar $name"
        fi
    fi
}

# ======================
# Função para instalar DMG direto
# ======================
install_app_dmg() {
    local name="$1"
    local url="$2"

    if [ -d "/Applications/$name.app" ]; then
        echo "⚠️ $name já está instalado, pulando..."
        return
    fi

    echo "🔽 Baixando $name..."
    TMP_DMG="/tmp/$name.dmg"
    curl -L "$url" -o "$TMP_DMG"

    echo "📦 Montando $name..."
    MOUNT_POINT=$(hdiutil attach "$TMP_DMG" -nobrowse -quiet | grep "/Volumes/" | awk '{print $3}' | tail -1)

    if [ -d "$MOUNT_POINT" ]; then
        APP_INSIDE=$(find "$MOUNT_POINT" -name "*.app" -maxdepth 2 | head -n 1)
        if [ -d "$APP_INSIDE" ]; then
            echo "📂 Copiando $name para /Applications..."
            sudo cp -R "$APP_INSIDE" /Applications/
            echo "✅ $name instalado com sucesso!"
        else
            echo "❌ Não foi possível encontrar o app dentro do DMG de $name"
        fi
        hdiutil detach "$MOUNT_POINT" -quiet
    else
        echo "❌ Não foi possível montar o DMG de $name"
    fi

    rm -f "$TMP_DMG"
}

# ======================
# Função para instalar ZIP
# ======================
install_app_zip() {
    local name="$1"
    local url="$2"

    if [ -d "/Applications/$name.app" ]; then
        echo "⚠️ $name já está instalado, pulando..."
        return
    fi

    echo "🔽 Baixando $name..."
    TMP_ZIP="/tmp/$name.zip"
    curl -L "$url" -o "$TMP_ZIP"

    echo "📦 Instalando $name..."
    unzip -q "$TMP_ZIP" -d "/tmp/$name"
    APP_INSIDE=$(find "/tmp/$name" -name "*.app" -maxdepth 2 | head -n 1)

    if [ -d "$APP_INSIDE" ]; then
        sudo cp -R "$APP_INSIDE" /Applications/
        echo "✅ $name instalado com sucesso!"
    else
        echo "❌ Não foi possível encontrar o app dentro do ZIP de $name"
    fi

    rm -rf "/tmp/$name" "$TMP_ZIP"
}

# ======================
# Verifica Homebrew
# ======================
if ! command -v brew &> /dev/null; then
    echo "⚠️ Homebrew não encontrado. Instalando..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_PREFIX=$(brew --prefix 2>/dev/null || echo "/opt/homebrew")
if [ ! -w "$BREW_PREFIX" ]; then
    echo "🔧 Corrigindo permissões do Homebrew..."
    sudo chown -R $(whoami) "$BREW_PREFIX"
fi

# ======================
# Se rodar com --clean, remove apps primeiro
# ======================
if [[ "$1" == "--clean" ]]; then
    remove_app_data "Discord" "com.hnc.Discord"
    remove_app_data "Figma" "com.figma.Desktop"
    remove_app_data "Cyberduck" "ch.sudo.cyberduck"
    remove_app_data "OpenVPN Connect" "net.openvpn.connect"
    remove_app_data "SonicWall Mobile Connect" "com.sonicwall.Mobile-Connect"
fi

# ======================
# Instala os apps
# ======================
install_app_zip "Figma" "https://desktop.figma.com/mac/Figma.zip"
install_app_zip "Cyberduck" "https://update.cyberduck.io/Cyberduck-9.2.1.43578.zip"
install_app_brew "discord"
install_app_brew "openvpn-connect"
install_app_dmg "SonicWall Mobile Connect" "COLOQUE_AQUI_LINK_DMG_SONICWALL"

echo "🎉 Todos os apps foram instalados!"
