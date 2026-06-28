# ETL - Extração, Transformação e Carga dos dados COVID-19 (DATASUS)
#
# Etapa 1: Seleção de colunas relevantes do dataset bruto com R
# Etapa 2: Recodificação de variáveis no Excel/Power Query
#   - Valores 2-9 convertidos para 0, mantendo apenas 1 (positivo) e 0 (negativo)
#   - Para raio-x e tomografia: valores 2-6 convertidos para 0
# Etapa 3 (opcional): Conversão CSV -> SQLite para exercicio com SQL

library(readr)
library(dplyr)
library(data.table)

# --- Etapa 1: Selecionar colunas do dataset bruto ---

dados_brutos <- read_csv2("INFLUD25-15-12-2025.csv",
                          locale = locale(encoding = "latin1"))

cat("Dimensoes do dataset original:", nrow(dados_brutos), "linhas x",
    ncol(dados_brutos), "colunas\n")

colunas_analise <- c(
  "NU_NOTIFIC", "DT_NOTIFIC", "SG_UF", "ID_MUNICIP", "ID_PAIS",
  "CS_SEXO", "NU_IDADE_N",
  "FEBRE", "TOSSE", "GARGANTA", "DESC_RESP", "SATURACAO",
  "DIARREIA", "VOMITO", "FATOR_RISC",
  "CARDIOPATI", "HEMATOLOGI", "SIND_DOWN", "HEPATICA", "ASMA",
  "DIABETES", "NEUROLOGIC", "PNEUMOPATI", "IMUNODEPRE", "RENAL", "OBESIDADE",
  "DOR_ABD", "FADIGA", "PERD_OLFT", "PERD_PALA",
  "VACINA", "DT_INTERNA", "UTI", "RAIOX_RES", "TOMO_RES", "AMOSTRA"
)

colunas_existentes <- colunas_analise[colunas_analise %in% names(dados_brutos)]

dados_transformados <- dados_brutos %>%
  select(all_of(colunas_existentes))

write_csv(dados_transformados, "dados_covid_2025_transformados.csv")

cat("Dataset transformado salvo com", nrow(dados_transformados), "linhas x",
    ncol(dados_transformados), "colunas\n")


# --- Etapa 3 (opcional): Converter CSV para SQLite ---

library(DBI)
library(RSQLite)

conexao <- dbConnect(SQLite(), dbname = "covid_2025.sqlite")
dados <- fread("INFLUD25-15-12-2025.csv")
dbWriteTable(conexao, "dados_covid", dados)
dbDisconnect(conexao)

cat("Banco SQLite criado: covid_2025.sqlite\n")
