#!/bin/bash
#
# SCRIPT FINAL: Baixa, compila e instala um kernel Linux otimizado em Debian.
#

# Encerra o script imediatamente se qualquer comando falhar.
set -e
# Mostra os comandos sendo executados para facilitar o diagnóstico.
set -x

# --- Verificação de Root ---
if [[ $EUID -ne 0 ]]; then
   echo "ERRO: Este script deve ser executado como root (ou com sudo)."
   exit 1
fi

# --- Instalação de Dependências ---
echo "--> Instalando dependências de compilação..."
apt-get update
apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev dwarves bc rsync curl ccache

# --- Download do Código-Fonte ---
echo "--> Detectando e baixando o kernel mais recente..."
KERNEL_VERSION=$(curl -s https://www.kernel.org/ | grep -A2 'id="latest_link"' | grep -oP '(?<=linux-)[^"]+(?=\.tar\.xz")' | head -n 1)
if [ -z "$KERNEL_VERSION" ]; then
    echo "Falha ao detectar a versão do kernel automaticamente. Abortando."
    exit 1
fi
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)

cd /usr/src
wget -c "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR}.x/linux-${KERNEL_VERSION}.tar.xz"
tar -xvf "linux-${KERNEL_VERSION}.tar.xz"
cd "linux-${KERNEL_VERSION}"
make clean

# --- Configuração do Kernel ---
echo "--> Configurando o kernel..."
cp "/boot/config-$(uname -r)" .config

# Desabilita a verificação por certificados de revogação específicos do Debian/Ubuntu
# para permitir a compilação de um kernel 'vanilla' (puro) sem erros.
scripts/config --disable SYSTEM_REVOCATION_LIST

# Otimiza a configuração para o hardware atual, desabilitando módulos desnecessários.
yes "" | make localmodconfig

# --- Compilação do Kernel ---
echo "--> Iniciando a compilação..."
# AVISO: A linha abaixo usa todos os núcleos de CPU. Se a compilação falhar
# com "Error 2", pode ser por falta de memória RAM.
# Nesse caso, altere -j$(nproc) para um número menor, como -j2 ou -j1.
make -j$(nproc) CC="ccache gcc"

# --- Instalação do Kernel e Módulos ---
echo "--> Instalando módulos e o novo kernel..."
make modules_install
make install

# --- Conclusão ---
set +x
echo ""
echo "================================================="
echo "  KERNEL ${KERNEL_VERSION} COMPILADO E INSTALADO!  "
echo "================================================="
echo "Reinicie o sistema para usar o novo kernel (sudo reboot)."
echo ""
