#INICIO

# Carreguei pacotes essenciais

library(dplyr)
library(ggplot2)
library(psych)
library(openxlsx) 
library(readxl)
library(readr)
library(DBI)
library(RSQLite)
library(data.table)
library(skimr)
library(remotes)
library(janitor)
library(tidyverse)
library(data.table)


#Importei o CSV Bruto para fazer o ETL
INFLUD25_15_12_2025 <- read_csv2("INFLUD25-15-12-2025.csv")
View(INFLUD25_15_12_2025)

# Os 3 passos feitos estão explicados no arquivo (ETL_dos_dados).

#script do ETL:

#Importei o CSV pronto para a análise
dados_brutos <- read_csv2("INFLUD25-15-12-2025.csv", 
                          locale = locale(encoding = "latin1"))


# Verifiquei dimensões dos dados originais
cat("Dimensões do dataset original:", nrow(dados_brutos), "linhas x", 
    ncol(dados_brutos), "colunas\n")

# DEFINIÇÃO DAS COLUNAS QUE IREI USAR NAS ANALISES
colunas_analise <- c(
  "NU_NOTIFIC",
  "DT_NOTIFIC",
  "SG_UF",
  "ID_MUNICIP",
  "ID_PAIS",
  "CS_SEXO",
  "NU_IDADE_N",
  "FEBRE",
  "TOSSE",
  "GARGANTA",
  "DESC_RESP",
  "SATURACAO",
  "DIARREIA",
  "VOMITO",
  "FATOR_RISC",
  "CARDIOPATI",
  "HEMATOLOGI",
  "SIND_DOWN",
  "HEPATICA",
  "ASMA",
  "DIABETES",
  "NEUROLOGIC",
  "PNEUMOPATI",
  "IMUNODEPRE",
  "RENAL",
  "OBESIDADE",
  "DOR_ABD",
  "FADIGA",
  "PERD_OLFT",
  "PERD_PALA",
  "VACINA",
  "DT_INTERNA",
  "UTI",
  "RAIOX_RES",
  "TOMO_RES",
  "AMOSTRA"
)

# Selecionei apenas as colunas que existem no dataset
colunas_existentes <- colunas_analise[colunas_analise %in% names(dados_brutos)]

dados_transformados <- dados_brutos %>%
select(all_of(colunas_existentes))

# Salvei em CSV
write_csv(dados_transformados, "dados_covid_2025_transformados.csv")

# A ultima etapa de transformação dos dados será feita no EXCEL, e esta explicada no arquivo (ETL_dos_dados).


# INICIO DAS ANALISES

library(readr)
data_set_analisado <- read_csv2("data_set_analisado.csv")
View(data_set_analisado)

# 1. Análises Descritivas
cat("\nResumo dos dados:\n")
print(summary(data_set_analisado))

cat("Dimensões do dataset:\n")
print(dim(data_set_analisado))

cat("\nNomes das colunas:\n")
print(names(data_set_analisado))

cat("\nPrimeiras linhas:\n")
print(head(data_set_analisado, 10))

cat("\nTipos de dados:\n")
print(str(data_set_analisado))

#Explorando os dados
View(data_set_analisado)
str(data_set_analisado)
head(data_set_analisado)
dim(data_set_analisado)
summary(data_set_analisado)
glimpse(data_set_analisado)
skim(data_set_analisado)


# ANALISES RELACIONADAS A VARIÁVEL SEXO

#Gráfico distribuição por sexo

#Tabela de frequências por sexo
freq_sexo <- data_set_analisado |>
  count(SEXO, name = "frequencia")
print(freq_sexo)

#Gráfico de barras por sexo
ggplot(freq_sexo,
       aes(x = SEXO, y = frequencia, fill = SEXO)) +
  geom_bar(stat = "identity") +
  labs(x = "Sexo",
       y = "Frequência",
       title = "Frequência de casos por sexo") +
  theme_minimal() +
  theme(legend.position = "none")


# ANALISES RELACIONADAS A VARIÁVEL COMORBIDADES

#Gráfico frequencia de comorbidades

#Selecionei apenas as colunas de comorbidades
comorb_cols <- c("CARDIOPATICO","HEMATOLOGICO","DOWN","HEPATICA","ASMA",
                 "DIABETES","NEUROLOGICO","PNEUMOPATICO","IMUNODEPRE",
                 "RENAL","OBESIDADE")

db_long <- data_set_analisado |>
  select(all_of(comorb_cols)) |>
  pivot_longer(cols = everything(),
               names_to = "comorbidade",
               values_to = "presenca")

#Contar frequência de presenca == 1
freq_comorb <- db_long |>
  filter(presenca == 1) |>
  count(comorbidade, name = "frequencia")

#Gráfico de barras
ggplot(freq_comorb, aes(x = reorder(comorbidade, -frequencia),
                        y = frequencia)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "Comorbidade",
       y = "Frequência",
       title = "Frequência de comorbidades em casos de COVID-19") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  


# ANALISES RELACIONADAS A VARIÁVEL SINTOMAS

#Gráfico frequencia de sintomas

#Defina as colunas de sintomas (ajuste se necessário)
sint_cols <- c("FEBRE","TOSSE","GARGANTA","RESPIRATORIO","SATURACAO",
               "DIARREIA","VOMITO","DOR_ABD","FADIGA",
               "PERD_OLFT","PERD_PALA")

db_sint_long <- data_set_analisado |>
  select(all_of(sint_cols)) |>
  pivot_longer(cols = everything(),
               names_to = "sintoma",
               values_to = "presenca")

#Contar frequência de sintoma presente (== 1)
freq_sint <- db_sint_long |>
  filter(presenca == 1) |>
  count(sintoma, name = "frequencia")

#Gráfico de barras dos sintomas
ggplot(freq_sint,
       aes(x = reorder(sintoma, -frequencia),
           y = frequencia)) +
  geom_bar(stat = "identity", fill = "tomato") +
  labs(x = "Sintoma",
       y = "Frequência",
       title = "Frequência de sintomas em casos de COVID-19") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




# ANALISES RELACIONADAS A VARIÁVEL VACINADOS

#Quantos casos vacinados em relação ao total

db2 <- data_set_analisado |>
  mutate(
    vac_status = ifelse(is.na(VACINA) | VACINA == "" | VACINA == "0",
                        "Não vacinado",
                        "Vacinado")
  )

tab_vac <- db2 |>
  count(vac_status) |>
  mutate(
    perc = n / sum(n)
  )

cat("=== Tabela de vacinação (coluna VACINA) ===\n")
print(tab_vac)


#Grafico numero de vacinados em relação ao total
ggplot(tab_vac,
       aes(x = vac_status,
           y = n,
           fill = vac_status)) +
  geom_col() +
  labs(
    title = "Casos por status vacinal (VACINA)",
    x = "Status vacinal",
    y = "Número de casos"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


# ANALISES COMORBIDADE POR SEXO

#Quais comorbidades são mais frequentes por sexo?
str(data_set_analisado)
head(data_set_analisado)

#Nomes das colunas de comorbidade do dataset agregado
comorb_vars <- c("CARDIOPATICO","HEMATOLOGICO","DOWN","HEPATICA",
                 "ASMA","DIABETES","NEUROLOGICO","PNEUMOPATICO",
                 "IMUNODEPRE","RENAL","OBESIDADE")

#Tabela longa com comorbidades por sexo
tab_comorb_sexo <- data_set_analisado |>
  select(SEXO, all_of(comorb_vars)) |>
  tidyr::pivot_longer(
    cols = all_of(comorb_vars),
    names_to = "comorbidade",
    values_to = "valor"
  ) |>
  group_by(SEXO, comorbidade) |>
  summarise(
    n_sim = sum(valor == 1, na.rm = TRUE),
    .groups = "drop"
  )

#TOP 5 comorbidades mais frequentes por sexo
top5_comorb_sexo <- tab_comorb_sexo |>
group_by(SEXO) |>
slice_max(order_by = n_sim, n = 5, with_ties = FALSE) |>
ungroup()
    
cat("\n=== Top 5 comorbidades por sexo ===\n")
print(top5_comorb_sexo)
    
# Gráfico de barras agrupadas
ggplot(top5_comorb_sexo,
aes(x = comorbidade,
y = n_sim,
fill = SEXO)) +
geom_col(position = position_dodge(width = 0.8)) +
geom_text(aes(label = n_sim),
    position = position_dodge(width = 0.8),
    vjust = -0.3,
                size = 3.5) +
      labs(
        title = "Top 5 comorbidades por sexo",
        x = "Comorbidade",
        y = "Número de casos"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.title = element_blank()
      )


# ANALISES SINTOMAS POR SEXO

#Quais sintomas são mais frequentes por sexo?

sintomas_vars <- c("FEBRE","TOSSE","GARGANTA","RESPIRATORIO",
                   "SATURACAO","DIARREIA","VOMITO",
                   "DOR_ABD","FADIGA","PERD_OLFT","PERD_PALA")

tab_sint_sexo <- data_set_analisado |>
  select(SEXO, all_of(sintomas_vars)) |>
  pivot_longer(
    cols = all_of(sintomas_vars),
    names_to = "sintoma",
    values_to = "valor"
  ) |>
  mutate(valor = as.numeric(valor)) |>
  group_by(SEXO, sintoma) |>
  summarise(
    n_sim = sum(valor == 1, na.rm = TRUE),
    .groups = "drop"
  ) |>
  group_by(SEXO) |>
  mutate(
    total_sexo = sum(n_sim),
    perc = ifelse(total_sexo > 0, n_sim / total_sexo, NA_real_)
  ) |>
  ungroup() |>
  arrange(SEXO, desc(n_sim))

cat("=== Sintomas mais frequentes por sexo (contagem e percentual dentro do sexo) ===\n")
print(tab_sint_sexo)

#TOP 5 sintomas mais frequentes

top5_sint_sexo <- tab_sint_sexo |>
  group_by(SEXO) |>
  slice_max(order_by = n_sim, n = 5, with_ties = FALSE) |>
  ungroup()

cat("\n=== Top 5 sintomas por sexo ===\n")
print(top5_sint_sexo)


#Gráfico de barras sintomas por sexo
ggplot(tab_sint_sexo,
       aes(x = sintoma,
           y = n_sim,
           fill = SEXO)) +
  geom_col(position = "dodge") +
  labs(
    title = "Número de casos com sintoma por sexo",
    x = "Sintoma",
    y = "Número de casos"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#Gráfico de barras TOP 5 sintomas por sexo

ggplot(top5_sint_sexo,
       aes(x = sintoma,
           y = n_sim,
           fill = SEXO)) +
  geom_col(position = "dodge") +
  labs(
    title = "Top 5 sintomas por sexo",
    x = "Sintoma",
    y = "Número de casos"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# ANALISES TOTAL DE CASOS POR FAIXA ETARIA

#Criar faixas etárias

total_casos_faixa <- data_set_analisado %>%
  mutate(
    IDADE = as.numeric(IDADE),
    
    faixa_etaria = cut(
      IDADE,
      breaks = c(0, 1, 5, 10, 17, 29, 39, 49, 59, 69, 79, Inf),
      labels = c("0-1", "2-5", "6-10", "11-17", "18-29", "30-39", "40-49",
                 "50-59", "60-69", "70-79", "80+"),
      right = TRUE
    ),
  
    #transformar VACINA em fator com rótulos
    status_vacinal = case_when(
      VACINA == 1 ~ "Vacinado",
      VACINA == 0 ~ "Não vacinado",
      TRUE        ~ "Ignorado"
    ),
    status_vacinal = factor(
      status_vacinal,
      levels = c("Não vacinado", "Vacinado", "Ignorado")
    )
  )

#Tabela total de casos por faixa etária e status vacinal

tabela_faixa_status_vac <- total_casos_faixa %>%
  filter(!is.na(faixa_etaria)) %>%
  count(faixa_etaria, status_vacinal, name = "total_casos") %>%
  arrange(faixa_etaria, status_vacinal)

print(n = 50, tabela_faixa_status_vac)

#Tabela total geral por faixa geral:
tabela_faixa_total <- total_casos_faixa %>%
  filter(!is.na(faixa_etaria)) %>%
  count(faixa_etaria, name = "total_casos") %>%
  arrange(faixa_etaria, total_casos)

print(tabela_faixa_total, n = 50)


#Grafico totla de casos por faixa etária

ggplot(tabela_faixa_total,
       aes(x = faixa_etaria, y = total_casos)) +
  geom_col(fill = "#2C6BB0") +
  labs(
    title = "Total de casos por faixa etária",
    x = "Faixa etária",
    y = "Número de casos"
  ) +
  theme_minimal()


#Gráfico barras empilhadas por faixa etária e status vacinal

ggplot(tabela_faixa_status_vac,
       aes(x = faixa_etaria, y = total_casos, fill = status_vacinal)) +
  geom_col(position = "stack") +
  labs(
    title = "Total de casos por faixa etária e status vacinal",
    x = "Faixa etária",
    y = "Número de casos",
    fill = "Status vacinal"
  ) +
  theme_minimal()

#Gráfico barras lado a lado (facilita comparação)

ggplot(tabela_faixa_status_vac,
       aes(x = faixa_etaria, y = total_casos, fill = status_vacinal)) +
  geom_col(position = "dodge") +
  labs(
    title = "Total de casos por faixa etária e status vacinal",
    x = "Faixa etária",
    y = "Número de casos",
    fill = "Status vacinal"
  ) +
  theme_minimal()


# ANALISES INTERNAÇÃO NA UTI

#Quantos casos de internação em UTI em relação ao total de casos ?

db_tot <- data_set_analisado |>
  mutate(
    VACINA     = as.numeric(VACINA),
    UTI        = as.numeric(UTI),
    RAIOX_RES      = as.numeric(RAIOX_RES),
    TOMO_RES = as.numeric(TOMO_RES)
  )

#Casos de UTI em relação ao total

n_uti <- sum(db_tot$UTI == 1, na.rm = TRUE)
n_total <- nrow(db_tot)
perc_uti <- (n_uti / n_total) * 100

cat("Casos em UTI:", n_uti, "\n")
cat("Total de casos:", n_total, "\n")
cat("Percentual em UTI:", round(perc_uti, 2), "%\n")


#Gráfico total de casos UTI por faixa etaria

ggplot(tabela_faixa_status_vac,
       aes(x = faixa_etaria, y = total_casos, fill = status_vacinal)) +
  geom_col(position = "dodge") +
  labs(
    title = "Total de casos por faixa etária e status vacinal",
    x = "Faixa etária",
    y = "Número de casos",
    fill = "Status vacinal"
  ) +
  theme_minimal()


#Taxa de internação na (UTI) entre vacinados e não vacinados

db_tot2 <- data_set_analisado |>
  mutate(
    vac_status = ifelse(VACINA == 1, "Vacinado", "Não vacinado")
  )

tab_uti_vac <- db_tot2 |>
  group_by(vac_status) |>
  summarise(
    n_casos = n(),
    n_uti   = sum(UTI == 1, na.rm = TRUE),
    taxa_uti = n_uti / n_casos,
    .groups = "drop"
  )

cat("=== Taxa de UTI (gravidade) por status vacinal ===\n")
print(tab_uti_vac)
cat("\n")


#Grafico UII por status vacinal
ggplot(tab_uti_vac,
       aes(x = vac_status,
           y = taxa_uti,
           fill = vac_status)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Taxa de UTI por status vacinal",
    x = "Status vacinal",
    y = "Proporção de casos em UTI"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


# ANALISES INTERNADOS UTI POR FAIXA ETARIA

#Frequencia de faixa etária dos internadoS na UTI.

#Criar faixas etárias
faixa_etaria <- data_set_analisado |>
  mutate(
    faixa_etaria = cut(
      IDADE,
      breaks = c(0, 1, 5, 10, 17, 29, 39, 49, 59, 69, 79, Inf),
      labels = c("0-1", "2-5", "6-10", "11-17", "18-29", "30-39", "40-49",
                 "50-59", "60-69", "70-79", "80+"),
      right = TRUE,
      include.lowest = TRUE
    )
  )

#Frequencia UTI por faixa etaria
freq_uti_faixa <- faixa_etaria |>
  filter(UTI == 1) |>
  group_by(faixa_etaria) |>
  summarise(
    n_uti = n(),
    .groups = "drop"
  ) |>
  mutate(
    perc_uti = 100 * n_uti / sum(n_uti)
  ) |>
arrange(desc(n_uti))

cat("=== Frequencia UTI por faica etaria ===\n")
print(freq_uti_faixa)
cat("\n")

# Gráfico em barras com contagem absoluta
ggplot(freq_uti_faixa,
       aes(x = faixa_etaria,
           y = n_uti)) +
  geom_col(fill = "#2E86C1") +
  geom_text(aes(label = n_uti),
            vjust = -0.3, size = 3.5) +
  labs(
    title = "Casos de internação em UTI por faixa etária",
    x = "Faixa etária",
    y = "Número de casos em UTI"
  ) +
  theme_minimal()

# Grafico percntual
ggplot(freq_uti_faixa,
       aes(x = faixa_etaria,
           y = perc_uti)) +
  geom_col(fill = "#27AE60") +
  geom_text(aes(label = paste0(round(perc_uti, 1), "%")),
            vjust = -0.3, size = 3.5) +
  labs(
    title = "Percentual de internações em UTI por faixa etária",
    x = "Faixa etária",
    y = "Percentual de casos em UTI"
  ) +
  theme_minimal()


# ANALISES INTERNADOS UTI, NÃO VACINADOS E POR FAIXA ETARIA

# Filtrar internados em UTI e não vacinados (UTI == 1 e VACINA == 0)
tabela_faixa_n_vac <- data_set_analisado |>
  filter(UTI == 1, VACINA == 0)

# Criar faixa etária
dados_uti_n_vac <- tabela_faixa_n_vac |>
  mutate(
    IDADE_NUM = as.numeric(IDADE),
    faixa_etaria = cut(
      IDADE_NUM,
      breaks = c(0, 1, 5, 10, 17, 29, 39, 49, 59, 69, 79, Inf),
      labels = c("0-1", "2-5", "6-10", "11-17", "18-29", "30-39",
                 "40-49", "50-59", "60-69", "70-79", "80+"),
      right = TRUE,
      include.lowest = TRUE
    )
  )

# Tabela de casos UTI por faixa etária (não vacinados)
tabela_faixa_n_vac2 <- dados_uti_n_vac |>
  count(faixa_etaria, name = "n_casos_n_vac") |>
  arrange(desc(n_casos_n_vac))

cat("=== Tabela de casos UTI por faixa etária NÃO vacinados ===\n")
print(tabela_faixa_n_vac2)
cat("\n")

# Gráfico de barras
ggplot(tabela_faixa_n_vac2, aes(x = faixa_etaria, y = n_casos_n_vac)) +
  geom_col(fill = "#1f77b4") +
  labs(
    title = "Internados em UTI NÃO vacinados por faixa etária",
    x = "Faixa etária",
    y = "Número de casos"
  ) +
  theme_minimal()


# ANALISES INTERNADOS UTI, VACINADOS E POR FAIXA ETARIA

# Filtrar internados em UTI vacinados
tabela_uti_vac <- data_set_analisado |>
  filter(UTI == 1, VACINA == 1)

# Criar faixa etária
dados_uti_vac <- tabela_uti_vac |>
  mutate(
    IDADE_NUM = as.numeric(IDADE),
    faixa_etaria = cut(
      IDADE_NUM,
      breaks = c(0, 1, 5, 10, 17, 29, 39, 49, 59, 69, 79, Inf),
      labels = c("0-1", "2-5", "6-10", "11-17", "18-29", "30-39",
                 "40-49", "50-59", "60-69", "70-79", "80+"),
      right = TRUE,
      include.lowest = TRUE
    )
  )

# Tabela de casos UTI por faixa etária vacinados
tabela_faixa_vac2 <- dados_uti_vac |>
  count(faixa_etaria, name = "n_casos_vac") |>
  arrange(desc(n_casos_vac))

cat("=== Tabela de casos UTI por faixa etária vacinados ===\n")
print(tabela_faixa_vac2)
cat("\n")

# Gráfico de barras
ggplot(tabela_faixa_vac2, aes(x = faixa_etaria, y = n_casos_vac)) +
  geom_col(fill = "#1f77b4") +
  labs(
    title = "Internados em UTI vacinados por faixa etária",
    x = "Faixa etária",
    y = "Número de casos"
  ) +
  theme_minimal()


# ANALISES RAIO-X E TOMOGRAFIA

#Em quantos casos foram feito raio-x e tomografia em relação ao total ?
n_raiox <- sum(db_tot$RAIOX_RES == 1, na.rm = TRUE)
n_tomo  <- sum(db_tot$TOMO_RES == 1, na.rm = TRUE)
n_sem <- n_total - n_raiox - n_tomo
n_total <- nrow(db_tot)

perc_raiox <- (n_raiox / n_total) * 100
perc_tomo  <- (n_tomo / n_total) * 100
perc_sem  <- (n_sem / n_total) * 100
perc_total  <- (n_total / n_total) * 100

cat("=== Exames de imagem em relação ao total ===\n")
cat("Casos com raio-X:", n_raiox, " (", round(perc_raiox, 1), "%)\n", sep = "")
cat("Casos com tomografia:", n_tomo, " (", round(perc_tomo, 1), "%)\n\n", sep = "")
cat("Casos sem exame:", n_sem, " (", round(perc_sem, 1), "%)\n\n", sep = "")
cat("Casos totais:", n_total, " (", round(perc_total, 1), "%)\n\n", sep = "")

#Tabela numero total de exames
df_exames <- tibble::tibble(
  categoria  = c("Raio-X", "Tomografia", "Sem exame", "Total"),
  total      = c(n_raiox, n_tomo, n_sem, n_total),
  percentual = c(perc_raiox, perc_tomo, perc_sem, perc_total)
)

cat("=== Tabela numero total de exames ===\n")
print(df_exames)
cat("\n")

#Grafico barras casos por realização de exames de imagem
grafico_barras <- ggplot(df_exames,
                         aes(x = categoria,
                             y = total,
                             fill = categoria)) +
  geom_col() +
  geom_text(aes(label = format(total,
                               big.mark = ".",
                               decimal.mark = ",")),
            vjust = -0.3, size = 4) +
  labs(
    title = "Casos por realização de exames de imagem",
    x = "Categoria",
    y = "Número de casos"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(grafico_barras)

#Pizza percentual de casos por situação de exame de imagem
df_pizza <- df_exames |>
  filter(categoria != "Total")

grafico_pizza <- ggplot(df_pizza,
                        aes(x = "",
                            y = percentual,
                            fill = categoria)) +
  geom_col(color = "white") +
  coord_polar("y") +
  geom_text(aes(label = paste0(round(percentual, 1), "%")),
            position = position_stack(vjust = 0.5),
            color = "white",
            size = 4) +
  labs(
    title = "Percentual de casos por situação de exame de imagem",
    x = NULL,
    y = NULL,
    fill = "Categoria"
  ) +
  theme_void()

print(grafico_pizza)

#FIM
