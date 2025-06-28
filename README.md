## Compilador de Kernel e Suíte de Benchmark para Debian Como Trabalho Final

![Linguagem](https://img.shields.io/badge/Linguagem-Shell%20%7C%20Makefile-blue)
![Plataforma](https://img.shields.io/badge/Plataforma-Debian%2012-red)


Este projeto fornece um conjunto de scripts e um `Makefile` para automatizar o processo de compilação de um kernel Linux otimizado para o hardware local em sistemas Debian 12. Além da compilação, a suíte integra a instalação e execução de ferramentas de benchmark para avaliar a performance do sistema com o novo kernel, que é o objetivo do trabalho final proposto.

### Passo a Passo:

1.  **Abra o terminal:**
    Abra seu terminal de escolha. (o projeto foi executado num servidor Debian 12 via ssh) 

2.  **Clone o repositorio:**

    ```bash
    git clone [https://github.com/AndrExAgris/SOP.git](https://github.com/AndrExAgris/SOP.git)
    ```

3.  **Acesse a pasta do projeto:**
    Após o download ser concluído, uma nova pasta com o nome **SOP/** será criada. Navegue até ela usando o comando `cd`.

    ```bash
    cd SOP/
    ```

4. **Executando o projeto:**
    A execução do projeto se da por um `Makefile`, este contendo os comandos  `install` (script para instalação das ferramentas de benchmark), `compile` (Script para baixar, compilar e instalar um kernel otimizado em um Debian12.) e o `run_benchmarks` (Script para consolidar os resultados de benchmarks em um único arquivo de relatório). Execute-os com:

    * **Para instalar as ferramentas de benchmark:**
        ```bash
        make install
        ```

    * **Para baixar, compilar, e aplicar o kernel novo:**
        ```bash
        make compile
        ```

    * **Para rodar os benchmarks:**
        ```bash
        make run_benchmarks
        ```


