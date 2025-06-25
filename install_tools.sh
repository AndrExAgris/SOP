#!/bin/bash

# Script para instalação das ferramentas de benchmark

echo "Atualizando a lista de pacotes..."
sudo apt-get update -y

echo "Instalando sysbench..."
sudo apt-get install -y sysbench

echo "Instalando fio..."
sudo apt-get install -y fio

echo "Instalando iperf3..."
sudo apt-get install -y iperf3

echo "Instalação concluída."


