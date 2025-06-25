#!/bin/bash

# ==============================================================================
# Script para Baixar, Compilar e Instalar um Kernel Linux Otimizado no Debian 12
# ==============================================================================
#
# AVISO: Use por sua conta e risco. Um erro pode impedir o boot do sistema.
# Garanta que você tem um backup e acesso de resgate ao servidor.
#
# ==============================================================================

# --- Configuração ---
# Você pode alterar a versão do kernel aqui se desejar.
# Vá para https://www.kernel.org/ para encontrar a última versão estável.
KERNEL_VERSION="6.9.6"
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)

# --- Sair em caso de erro ---
set -e
set -x # Mostra os comandos sendo executados (bom para debug)

# --- Passo 1: Verificações Iniciais ---

echo "Verificando se o script está sendo executado como root..."
if [[ $EUID -ne 0 ]]; then
   echo "ERRO: Este script deve ser executado como root." 
   exit 1
fi


# --- Passo 2: Instalação das Dependências ---

echo "Atualizando a lista de pacotes e instalando as dependências de compilação..."
apt-get update
apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev dwarves bc rsync


# --- Passo 3: Download e Extração do Kernel ---

echo "Baixando o código-fonte do kernel versão ${KERNEL_VERSION}..."
cd /usr/src
wget "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR}.x/linux-${KERNEL_VERSION}.tar.xz"
tar -xvf "linux-${KERNEL_VERSION}.tar.xz"
cd "linux-${KERNEL_VERSION}"


# --- Passo 4: Configuração do Kernel ---

echo "Configurando o kernel para o hardware local..."

# Copia a configuração do kernel atual como base. É uma boa prática.
cp "/boot/config-$(uname -r)" .config

# Usa 'localmodconfig' para desabilitar módulos que não estão carregados atualmente.
# Isso otimiza o kernel para o hardware presente.
# O 'yes "" |' responde 'enter' (padrão) para quaisquer novas opções que possam surgir.
yes "" | make localmodconfig


# --- Passo 5: Compilação e Instalação ---

echo "Iniciando a compilação do kernel. Isso pode levar muito tempo..."
# Usa todos os núcleos de processador disponíveis para acelerar a compilação.
make -j$(nproc)

echo "Instalando os módulos..."
make modules_install

echo "Instalando o kernel..."
# Este comando copia o kernel para /boot e ATUALIZA O GRUB AUTOMATICAMENTE.
make install


# --- Passo 6: Conclusão ---

set +x # Desativa a exibição de comandos

echo ""
echo "======================================================"
echo "      Kernel ${KERNEL_VERSION} Compilado e Instalado!     "
echo "======================================================"
echo ""
echo "O GRUB foi atualizado para usar o novo kernel como padrão na próxima inicialização."
echo "O kernel antigo ainda está disponível no menu do GRUB caso precise dele."
echo ""
echo "REINICIE O SERVIDOR para começar a usar o novo kernel."
echo "Comando para reiniciar: sudo reboot"
echo ""

exit 0