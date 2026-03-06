# Zero-ETL Pipeline: Azure Data Lake Gen2 and Snowflake

![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white) ![Snowflake](https://img.shields.io/badge/snowflake-%234285F4?style=for-the-badge&logo=snowflake&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

Este repositório documenta a implementação de um pipeline de dados analítico moderno utilizando integração nativa entre recursos de armazenamento Microsoft Azure e processamento do Data Warehouse Snowflake Cloud. O pipeline apoia-se nativamente no processo de Auto-Ingestão assíncrona (Snowpipe), implementando e solidificando diretrizes fundamentais da arquitetura corporativa conhecida como Zero-ETL.

## Arquitetura Institucional

O design do fluxo é sustentado por componentes governados em isolamento tático:
1. **Origem Transacional (Simulação Simulada)**: O módulo residente em `src/generate_data.py` assume o perfil computacional de uma aplicação (ex: um cluster E-commerce), submetendo matrizes contínuas baseadas no utilitário de Mocks (`Faker`), transportando o artefato de arquivos por redes seguras de forma programática.
2. **Ambiente Data Lake (Microsoft Azure)**: A infraestrutura designada como base crua (camada `Raw`) opera nativamente em um Azure Data Lake Storage Gen2, dotada de namespace hierárquico analítico. O escopo global engloba Azure Resource Groups e sub-componentes Storage Accounts, os quais são descritos obrigatoriamente através da Governança de Infraestrutura por Código provida pelos scripts contidos no núcleo de `/infrastructure/` usando o provider oficial do Terraform.
3. **Mecanismo de Data Warehousing (Snowflake)**:
   - **Storage Integration:** Implementa-se uma validação de Diretório Ativo IAM atrelando a rede da Microsoft Azure à fundação autárquica de segurança Snowflake (evitando de forma restrita as primitivas vulneráveis baseadas em credenciamento público HTTP).
   - **Continuous Data Pipeline (Snowpipe):** Configura-se uma entidade monitoradora contínua atrelada ao ecossistema de fluxos lógicos Azure Event Grid. Este subsistema garante cargas orientadas a micro-lotes reagindo passivamente às criações do Container Blob ADLS (código na biblioteca principal `/sql/`).
4. **Camada de Modelagem Lógica (Medallion Layer)**: Processamento e estruturação relacional conduzida no motor de compute nativo do Snowflake. Aplica Views transformativas gerindo e categorizando a governança da base informacional em instâncias formais e depuradas Silver e agregações de uso gerencial e cálculos contábeis (ex: Life Time Value) via Gold.

## Módulos e Componentes

- **Cloud Provider (Storage):** Microsoft Azure (ADLS Gen2)
- **Data Warehouse / Process Engine:** Snowflake Cloud Data Platform
- **Ferramentas Integradoras de Ingestão:** Snowflake Snowpipe, Microsoft Azure Event Grid, Python SDK
- **Infrastructure as Code (IaC):** HashiCorp Terraform
- **Automatização Reprodutiva (CI/CD):** GitHub Actions Workflow

## Instruções de Instanciamento para Ambiente de Desenvolvimento

### Condicionais Obrigatórias
- Entidade de credenciamento autoral em provedor Microsoft Azure validado de forma funcional no sistema CLI da nuvem (`az cli`).
- Espaço em alocação (Warehouse) e Privilégios Corporativos administrativos `ACCOUNTADMIN` no Console Web do ecossistema Snowflake.

### 1. Construção do Repositório Físico (Azure Infrastructure)
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

### 2. Geração e Implantação de Massa Secundária
Instancie apropriadamente ao sistema interno as diretrizes de direcionamento antes do acionamento via prompt local de sua preferência:
```bash
export AZURE_STORAGE_CONNECTION_STRING="<Referencia_da_Sua_String_Connection_Atrelada_a_Azure>"
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python src/generate_data.py
```

### 3. Setup Distribuído do Subsistema de Auto-Ingestão Snowpipe
Acesse o console Web de queries logado como Administrador Snowsight no Snowflake. Submeta o bloco das instruções textuais abrigado na estrutura `./sql`:
1. Processe as instruções constantes no arquivo `01_setup_integration.sql` para fundar as entidades de segurança.
2. Analise a requisição para recuperação do atributo transacional *Tenant ID* provido na interface, transportando e estabelecendo essa validação cruzada contendo acesso estrito de leitura ("Storage Blob Data Contributor") frente a infraestrutura Microsoft Azure.
3. Acione o processamento do módulo `02_create_stage_and_pipe.sql` viabilizando as estâncias da tabela raiz (`raw_sales`) e efetivando logicamente a arquitetura de Pipe para carga perene.
4. **Configuração de Endpoint Operacional:** Construa ativamente o ecossistema de *Triggers* do Azure Event Grid estabelecendo e registrando de forma integral a EventURL (Canal de Serviço Automático Webhook Rest) elaborada pelo objeto instanciado na etapa anterior referente ao Snowpipe autônomo.
5. Pela consola ou via dbt, compile a execução e implantação dos modelos lógicos relacionais contidos no documento primário final de transação contido em `03_transformations.sql`.

---
> *A integridade e proficiência no manuseio arquitetural desse projeto espelha a excelência demandada pela área tecnológica em contextos de Data Analytics moderno.*
