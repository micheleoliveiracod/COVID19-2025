# Fonte dos Dados

## Dataset

- **Arquivo:** INFLUD25-15-12-2025.csv (~398 mil linhas)
- **Fonte:** DATASUS - Sistema de Informacao de Vigilancia Epidemiologica da Gripe (SIVEP-Gripe)
- **Link:** [dados.gov.br - SRAG 2021 e 2022](https://dados.gov.br/dados/conjuntos-dados/srag-2021-e-2022)

## Processo de ETL

1. **Extracao:** Download do dataset bruto do DATASUS.
2. **Transformacao em R:** Selecao das colunas relevantes para analise (script [01_etl.R](../scripts/01_etl.R)).
3. **Transformacao no Excel/Power Query:** Recodificacao de variaveis binarias (1 = positivo, 0 = negativo).
4. **Carga:** Dataset final salvo como `data_set_analisado.csv` na pasta `data/`.

O dataset bruto original nao esta no repositorio devido ao tamanho. O dataset transformado e pronto para analise esta em [data/data_set_analisado.csv](../data/data_set_analisado.csv).

Queries SQL de referencia estao em [scripts/etl_sql_referencia.sql](../scripts/etl_sql_referencia.sql).
