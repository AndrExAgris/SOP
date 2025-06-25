#!/bin/bash
set -e 

# 1. Instalação de dependências
echo "[1/6] Instalando pacotes necessários..."
sudo apt update 
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc git fakeroot dpkg-dev

# 2. Baixar a versão mais recente do kernel estável
echo "[2/6] Baixando o código-fonte do kernel Linux..."
cd /usr/src
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.3.tar.xz
tar -xf linux-6.14.3.tar.xz
cd linux-6.14.3

# 3. Usar a configuração atual do kernel como base
echo "[3/6] Importando configuração do kernel atual..."
cp -v /boot/config-$(uname -r) .config

# 4. Ajustar a configuração para os módulos atualmente carregados
echo "[4/6] Otimizando para o hardware atual com localmodconfig..."
yes "" | make localmodconfig

# 5. Compilar o kernel (pode demorar bastante)
echo "[5/6] Compilando o kernel (isso pode levar bastante tempo)..."
make -j"$(nproc)"
make modules_install
make install

# 6. Atualizar o GRUB
echo "[6/6] Atualizando GRUB e finalizando..."
sudo update-initramfs -c -k 6.14.3
sudo update-grub

echo "✅ Kernel recompilado e instalado com sucesso! Reinicie o sistema para usar o novo kernel."
