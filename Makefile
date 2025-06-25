all: run

compile:
	@echo "Disparando o script de compilação do kernel..."
	sudo chmod +x compile.sh
	./compile.sh

install:
	@echo "Instalando ferramentas de benchmark..."
	sudo chmod +x install_tools.sh
	./install_tools.sh

run:
	@echo "Executando benchmarks..."
	sudo chmod +x run_benchmarks.sh
	./run_benchmarks.sh

clean:
	@echo "Removendo resultados de benchmark..."
	rm -rf benchmark_results_*

.PHONY: all compile install run clean