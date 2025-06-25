#!/bin/bash

# Script para consolidar os resultados de benchmarks em um único arquivo de relatório.

REPORT_FILE="benchmark_report_$(date +%Y%m%d_%H%M%S).txt"

run_and_log() {
    local title="$1"
    local command_to_run="$2"

    echo "------------------------------------------------------------" >> "$REPORT_FILE"
    echo "--- $title" >> "$REPORT_FILE"
    echo "--- Executado em: $(date)" >> "$REPORT_FILE"
    echo "------------------------------------------------------------" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    eval "$command_to_run" >> "$REPORT_FILE" 2>&1
    echo "" >> "$REPORT_FILE"
    echo "--- Fim de $title ---" >> "$REPORT_FILE"
    echo -e "\n\n" >> "$REPORT_FILE"
}

echo "Iniciando benchmarks em $(date)..."
echo "O relatório será salvo em: $REPORT_FILE"

# Cabeçalho inicial do relatório
echo "RELATÓRIO DE BENCHMARK DO SISTEMA" > "$REPORT_FILE"
echo "Gerado em: $(date)" >> "$REPORT_FILE"
echo "============================================================" >> "$REPORT_FILE"
echo -e "\n" >> "$REPORT_FILE"

# 1. Informações do Sistema e Hardware
echo "Coletando informações do sistema..."
run_and_log "Informações do Kernel e SO" "uname -a"
run_and_log "Detalhes da CPU" "lscpu"
run_and_log "Layout dos Discos (Block Devices)" "lsblk"

# 2. Análise de Boot
echo "Executando systemd-analyze..."
run_and_log "systemd-analyze: Tempo de Boot" "systemd-analyze"

# 3. Análise de Memória
echo "Executando testes de memória..."
run_and_log "free: Uso de Memória e Swap" "free -h"
run_and_log "vmstat: Atividade do Sistema (10 amostras)" "vmstat 1 10"

# 4. Benchmark de CPU
echo "Executando sysbench CPU..."
run_and_log "sysbench: Teste de CPU" "sysbench cpu run"

# 5. Benchmark de Memória
echo "Executando sysbench Memory..."
run_and_log "sysbench: Teste de Memória" "sysbench memory run"

# 6. Benchmark de I/O de Disco (Sysbench)
echo "Executando sysbench File I/O..."
sysbench fileio --file-total-size=1G prepare > /dev/null 2>&1
run_and_log "sysbench: Teste de I/O (Leitura/Escrita Aleatória)" "sysbench fileio --file-total-size=1G --file-test-mode=rndrw --file-extra-flags=direct --file-fsync-all=off run"
sysbench fileio --file-total-size=1G cleanup > /dev/null 2>&1

# 7. Benchmark de I/O de Disco (fio)
echo "Executando fio..."
run_and_log "fio: Teste de Escrita Aleatória" "fio --name=randwrite --iodepth=1 --rw=randwrite --bs=4k --direct=1 --size=1G --numjobs=1 --runtime=60 --group_reporting"
run_and_log "fio: Teste de Leitura Aleatória" "fio --name=randread --iodepth=1 --rw=randread --bs=4k --direct=1 --size=1G --numjobs=1 --runtime=60 --group_reporting"

# 8. Benchmark de Rede
echo "Executando iperf3 para localhost..."
run_and_log "iperf3: Teste de Rede para localhost" "iperf3 -c localhost -t 10"

echo "------------------------------------------------------------" >> "$REPORT_FILE"
echo "--- FIM DO RELATÓRIO ---" >> "$REPORT_FILE"
echo "------------------------------------------------------------" >> "$REPORT_FILE"

echo "Benchmarks concluídos. O relatório completo foi salvo em: $REPORT_FILE"
