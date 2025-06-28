install:
	@echo "Instalando ferramentas de benchmark..."
	sudo chmod +x install.sh
	./install.sh

compile:
	@echo "Disparando o script de compilação do kernel..."
	sudo chmod +x compile.sh
	./compile.sh

run_benchmarks:
	@echo "Executando benchmarks..."
	sudo chmod +x run_benchmarks.sh
	./run_benchmarks.sh

.PHONY: install compile run_benchmarks 