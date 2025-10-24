#!/bin/bash
clear

# Cores para saída
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[0;33m'
AZUL='\033[0;34m'
CIANO='\033[0;36m'
NC='\033[0m' # Sem cor

# Função: Verificar se um comando existe
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Função: Imprimir Banner
print_banner() {
    echo -e "${CIANO}==========================================${NC}"
    echo -e "${AMARELO}$1${NC}"
    echo -e "${CIANO}==========================================${NC}"
}

# Etapa 0: Banner em Arte ASCII (sem sleep)
print_ascii_banner() {
    clear
    if check_command toilet && check_command lolcat; then
        toilet -f smblock -F border "  TERMUX BANNER  " | lolcat
    else
        echo -e "${VERMELHO}Toilet ou lolcat não instalado. Pulando banner ASCII.${NC}"
    fi
    echo -e "${CIANO}Ferramenta por: Mr-Sunil ${NC}"
    echo -e "${CIANO}Siga-nos:${NC}"
    echo -e "${AMARELO}YouTube: https://youtube.com/@noobcybertech2024${NC}"
    echo -e "${AMARELO}Telegram: https://t.me/Annon4you${NC}"
    echo -e "${AMARELO}Facebook: https://facebook.com/share/1HrTAb9GoH/${NC}"
    echo -e "${AMARELO}Instagram: annon_4you${NC}"
    echo -e "${CIANO}==========================================${NC}"
}
print_ascii_banner

# Função: Atualizar e Atualizar Pacotes do Termux
update_termux() {
    print_banner "Atualizando e Atualizando Pacotes do Termux"
    pkg update -y && pkg upgrade -y && {
        echo -e "${VERDE}Pacotes atualizados com sucesso.${NC}"
    } || echo -e "${VERMELHO}Aviso: Atualização falhou, mas continuando.${NC}"
}

# Função: Instalar Pacotes Necessários
install_packages() {
    print_banner "Instalando Pacotes Necessários"
    packages=(starship termimage fish python wget toilet)
    for pkg in "${packages[@]}"; do
        if ! check_command "$pkg"; then
            echo -e "${AZUL}Instalando $pkg...${NC}"
            pkg install "$pkg" -y || echo -e "${VERMELHO}Falha ao instalar $pkg.${NC}"
        else
            echo -e "${VERDE}$pkg já está instalado.${NC}"
        fi
    done
}

# Função: Instalar Pacote Python Lolcat
install_lolcat() {
    print_banner "Instalando Pacote Python Lolcat"
    if ! check_command pip; then
        echo -e "${AMARELO}Pip não encontrado, instalando...${NC}"
        pkg install python-pip -y
    fi
    if ! check_command lolcat; then
        pip install lolcat || echo -e "${VERMELHO}Falha ao instalar lolcat.${NC}"
        echo -e "${VERDE}Lolcat instalado.${NC}"
    else
        echo -e "${VERDE}Lolcat já está instalado.${NC}"
    fi
}

# Etapas principais (sem duplicatas)
update_termux
install_packages
install_lolcat

# Etapa 4: Definir Fish como Shell Padrão
print_banner "Definindo Shell Fish como Padrão"
if ! check_command fish; then
    echo -e "${VERMELHO}Shell Fish não está instalado. Pulando.${NC}"
else
    chsh -s fish || echo -e "${VERMELHO}Falha no chsh. Tente manualmente.${NC}"
    echo -e "${VERDE}Fish é agora o shell padrão. Reinicie o Termux para aplicar.${NC}"
fi

# Etapa 5: Configurar Fish (path correto, com backup)
print_banner "Configurando Fish (removendo saudação padrão e adicionando custom)"
FISH_CONFIG_DIR="$HOME/.config/fish"
mkdir -p "$FISH_CONFIG_DIR"
FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"

# Backup se existir
if [ -f "$FISH_CONFIG_FILE" ]; then
    cp "$FISH_CONFIG_FILE" "${FISH_CONFIG_FILE}.bak"
    echo -e "${VERDE}Backup de config.fish criado.${NC}"
fi

# Custom greeting: Rode termimage se imagem existir, senão vazio
if [ -f "$HOME/Hacker.jpg" ] && check_command termimage; then
    echo "function fish_greeting; termimage \$HOME/Hacker.jpg; end" > "$FISH_CONFIG_FILE"
else
    echo "set -U fish_greeting ''" > "$FISH_CONFIG_FILE"
fi
echo -e "${VERDE}Config do Fish atualizada.${NC}"

# Etapa 6: Configurar Starship com Fish
print_banner "Configurando Starship com Fish"
if ! grep -q "starship init fish" "$FISH_CONFIG_FILE"; then
    echo "starship init fish | source" >> "$FISH_CONFIG_FILE"
    echo -e "${VERDE}Inicialização do Starship adicionada.${NC}"
else
    echo -e "${AMARELO}Starship já está configurado no Fish.${NC}"
fi

# Etapa 7: Baixar e Definir Banner TermImage (URL alternativa)
print_banner "Configurando Banner TermImage"
IMAGE_URL="https://cdn.pixabay.com/photo/2016/11/29/05/47/terminal-1869420_1280.jpg"  # Imagem pública "hacker terminal"
IMAGE_PATH="$HOME/Hacker.jpg"

echo -e "${AZUL}Baixando imagem do banner...${NC}"
if check_command wget; then
    wget -q "$IMAGE_URL" -O "$IMAGE_PATH" && {
        echo -e "${VERDE}Imagem baixada com sucesso.${NC}"
        # Atualiza greeting do Fish pra usar a imagem
        sed -i 's/set -U fish_greeting .*/function fish_greeting; termimage $HOME\/Hacker.jpg; end/' "$FISH_CONFIG_FILE"
    } || echo -e "${VERMELHO}Falha ao baixar imagem. Pulando.${NC}"
else
    echo -e "${VERMELHO}Wget não encontrado. Pulando download.${NC}"
fi

# Etapa 8: Configuração Personalizada do Starship (embutida)
print_banner "Criando Configuração Básica do Starship"
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'EOF'
# Config básica Starship para Termux (hacker theme)
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[directory]
truncation_length = 3
truncate_to_repo = false

[git_branch]
symbol = "🌿 "
style = "bold purple"

[git_status]
style = "bold red"
conflicted = "⚠️"
ahead = "⇡${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
behind = "⇣${count}"
untracked = "?"
stashed = "📦"
modified = "📝"
staged = '[++\++](green)'
renamed = "👉"
deleted = "✘"

[python]
symbol = "🐍 "
pyenv_version_name = true

[nodejs]
symbol = "🤘 "

[rust]
symbol = "🦀 "

[time]
disabled = false
time_format = "%T"
utc_time_offset = "local"
format = "[$time]($style) "

[status]
disabled = false
EOF
echo -e "${VERDE}Config do Starship criada localmente.${NC}"

# Etapa 9: Banner ASCII Final
print_ascii_banner

# Etapa 10: Mensagem de Conclusão
print_banner "Configuração Completa"
echo -e "${VERDE}Reinicie seu Termux com 'exec fish' ou feche/reabra.${NC}"
echo -e "${CIANO}Dica: Se termimage não renderizar, instale 'ueberzug' ou use emulador compatível.${NC}"