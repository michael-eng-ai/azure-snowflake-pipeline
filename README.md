# ❄️ Zero-ETL Pipeline: Azure Data Lake Gen2 + Snowflake

![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white) ![Snowflake](https://img.shields.io/badge/snowflake-%234285F4?style=for-the-badge&logo=snowflake&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

Este repositório demonstra a construção de um pipeline de dados moderno e escalável, conectando a nuvem Microsoft Azure nativamente ao Data Warehouse Snowflake através da funcionalidade de Auto-Ingestão (Snowpipe), aplicando conceitos de **Zero-ETL**.

## 🏗️ Arquitetura do Projeto

O fluxo de dados consiste em:
1. **Origem (Simulada)**: Um script Python (`src/generate_data.py`) atua como serviço transacional (Ex: E-commerce), gerando milhares de métricas falsas com a biblioteca `Faker` e as enviando programaticamente.
2. **Data Lake (Azure)**: O destino primário dos dados é uma camada *Raw* no **Azure Data Lake Storage Gen2** (armazenamento hierárquico). Toda essa infraestrutura (Resource Group, Storage Account) é inteiramente gerenciada através de **Terraform** (pasta `/infrastructure/`).
3. **Data Warehouse (Snowflake)**:
   - **Storage Integration:** Utilizamos integração de diretório (IAM via AD) para criar uma relação de confiança segura, sem exposição de chaves primárias.
   - **Snowpipe (Auto-Ingest):** Um *Pipe* monitora a fila do Azure Event Grid e carrega os novos dados CSV automaticamente para a tabela bruta na nuvem do Snowflake (código na pasta `/sql/`).
4. **Transformação (Medallion Layer)**: Modelamos os dados no Snowflake aplicando Views nas camadas **Silver** (limpeza/deduplicação) e **Gold** (agregados de negócio e LTV).

## 🛠️ Tecnologias Utilizadas

- **Cloud Provider (Storage):** Microsoft Azure (ADLS Gen2)
- **Data Warehouse / Compute:** Snowflake Cloud Data Platform
- **Ingestion Tools:** Snowpipe, Azure Event Grid, Script Custom (Python)
- **Infrastructure as Code (IaC):** Terraform
- **Automatização (CI/CD):** GitHub Actions

## 🚀 Como Executar Localmente

### Pré-Requisitos
- Uma conta Azure e o CLI do Cloud (`az cli`) configurado e autenticado.
- Uma conta Snowflake com privilégios `ACCOUNTADMIN`.
- Terraform executável na máquina.

### 1️⃣ Provisionando a Infraestrutura (Azure)
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

### 2️⃣ Gerando Dados Falsos
Configure localmente a variável de ambiente para que o robô consiga injetar dados na sua storage string:
```bash
export AZURE_STORAGE_CONNECTION_STRING="<SuaConnectionDaAzure>"
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python src/generate_data.py
```

### 3️⃣ Setup Snowflake e Snowpipe
No painel de SQL/Warehousing do Snowsight, rode as instruções iterativas da pasta `sql/`:
1. Execute o `01_setup_integration.sql` para estabelecer a relação de credenciais.
2. Obtenha o *Tenant ID* pela query fornecida e insira na Role da Azure (Contribuinte de Blob) as permissões para a aplicação do Snowflake.
3. Rode o `02_create_stage_and_pipe.sql` para inicializar a tabela de stage (`raw_sales`) e ativar o Snowpipe.
4. **Passo Crucial:** Configure as *Triggers* no Event Grid da Azure usando a EventURL gerada pelo Snowpipe, criando o gatilho de auto-ingestão sobre arquivos caídos no Container ADLS.
5. Pela consola ou via DBT/Ferramentas similares, rode `03_transformations.sql` para criar a camada analítica (Silver e Gold).

---

> *Desenvolvido como prova conceitual pragmática para engenharia de integração Zero-ETL.*
