#!/bin/bash
#
# SCRIPT PARA COMPILAR E INSTALAR KERNEL LINUX OTIMIZADO EM DEBIAN 12
# AVISO: A execução incorreta pode impedir o boot do sistema. Tenha backups.
#

# Encerra o script imediatamente se qualquer comando falhar.
set -e
# Mostra os comandos sendo executados para facilitar o diagnóstico.
set -x

# --- Verificação de Root ---
if [[ $EUID -ne 0 ]]; then
   echo "ERRO: Este script precisa ser executado como root (ou com sudo)." 
   exit 1
fi

# --- Instalação de Dependências ---
echo "Atualizando pacotes e instalando dependências de compilação..."
apt-get update
apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev dwarves bc rsync curl ccache

# --- Download do Código-Fonte ---
echo "Buscando a versão mais recente do kernel estável..."
# Este comando extrai a versão diretamente do site kernel.org.
KERNEL_VERSION=$(curl -s https://www.kernel.org/ | grep -A1 'stable:' | grep -oP '>\K[6-9]\.[0-9]+\.[0-9]+')
if [ -z "$KERNEL_VERSION" ]; then
    echo "Falha ao detectar a versão do kernel automaticamente. Abortando."
    exit 1
fi
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)

echo "Baixando o código-fonte do kernel versão ${KERNEL_VERSION}..."
cd /usr/src
# O parâmetro -c permite continuar downloads interrompidos.
wget -c "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR}.x/linux-${KERNEL_VERSION}.tar.xz"
tar -xvf "linux-${KERNEL_VERSION}.tar.xz"
cd "linux-${KERNEL_VERSION}"

# --- Configuração Otimizada ---
echo "Configurando o kernel para o hardware local..."
cp "/boot/config-$(uname -r)" .config
# 'localmodconfig' otimiza o .config removendo módulos para hardware não presente.
yes "" | make localmodconfig

# --- Compilação e Instalação ---
echo "Iniciando a compilação do kernel (pode levar muito tempo)..."
# Usa 'ccache' para acelerar futuras compilações.
make -j$(nproc) CC="ccache gcc"

echo "Instalando os módulos do kernel..."
make modules_install

echo "Instalando o kernel (o GRUB será atualizado automaticamente)..."
make install

# --- Conclusão ---
# Desativa a exibição de comandos para uma saída mais limpa.
set +x

echo ""
echo "======================================================"
echo "  Kernel ${KERNEL_VERSION} Compilado e Instalado com Sucesso!  "
echo "======================================================"
echo "O sistema está pronto para ser reiniciado com o novo kernel."
echo "O kernel antigo foi mantido e pode ser selecionado no menu do GRUB em caso de problemas."
echo ""
echo "Para reiniciar, use o comando: sudo reboot"
echo ""