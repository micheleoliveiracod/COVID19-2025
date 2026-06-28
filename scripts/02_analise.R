library(tidyverse)
library(skimr)
library(janitor)

# --- Funcao auxiliar: criar faixas etarias ---
criar_faixa_etaria <- function(idade) {
  cut(
    as.numeric(idade),
    breaks = c(0, 1, 5, 10, 17, 29, 39, 49, 59, 69, 79, Inf),
    labels = c("0-1", "2-5", "6-10", "11-17", "18-29", "30-39",
               "40-49", "50-59", "60-69", "70-79", "80+"),
    right = TRUE,
    include.lowest = TRUE
  )
}

# --- Carregar dataset ---
data_set_analisado <- read_csv2("data/data_set_analisado.csv")

cat("Dimensoes do dataset:\n")
print(dim(data_set_analisado))

cat("\nResumo dos dados:\n")
print(summary(data_set_analisado))

cat("\nTipos de dados:\n")
print(str(data_set_analisado))

skim(data_set_analisado)


# ============================================================
# ANALISE POR SEXO
# ============================================================

freq_sexo <- data_set_analisado |>
  count(SEXO, name = "frequencia")

print(freq_sexo)

ggplot(freq_sexo, aes(x = SEXO, y = frequencia, fill = SEXO)) +
  geom_bar(stat = "identity") +
  labs(x = "Sexo", y = "Frequencia",
       title = "Frequencia de casos por sexo") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("resultados/graficos/freq_casos_por_sexo.png", width = 8, height = 6)


# ============================================================
# ANALISE DE COMORBIDADES
# ============================================================

comorb_cols <- c("CARDIOPATICO", "HEMATOLOGICO", "DOWN", "HEPATICA", "ASMA",
                 "DIABETES", "NEUROLOGICO", "PNEUMOPATICO", "IMUNODEPRE",
                 "RENAL", "OBESIDADE")

freq_comorb <- data_set_analisado |>
  select(all_of(comorb_cols)) |>
  pivot_longer(everything(), names_to = "comorbidade", values_to = "presenca") |>
  filter(presenca == 1) |>
  count(comorbidade, name = "frequencia")

ggplot(freq_comorb, aes(x = reorder(comorbidade, -frequencia), y = frequencia)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "Comorbidade", y = "Frequencia",
       title = "Frequencia de comorbidades em casos de COVID-19") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("resultados/graficos/freq_comorbidades_total.png", width = 10, height = 6)


# ============================================================
# ANALISE DE SINTOMAS
# ============================================================

sint_cols <- c("FEBRE", "TOSSE", "GARGANTA", "RESPIRATORIO", "SATURACAO",
               "DIARREIA", "VOMITO", "DOR_ABD", "FADIGA",
               "PERD_OLFT", "PERD_PALA")

freq_sint <- data_set_analisado |>
  select(all_of(sint_cols)) |>
  pivot_longer(everything(), names_to = "sintoma", values_to = "presenca") |>
  filter(presenca == 1) |>
  count(sintoma, name = "frequencia")

ggplot(freq_sint, aes(x = reorder(sintoma, -frequencia), y = frequencia)) +
  geom_bar(stat = "identity", fill = "tomato") +
  labs(x = "Sintoma", y = "Frequencia",
       title = "Frequencia de sintomas em casos de COVID-19") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("resultados/graficos/freq_sintomas_total.png", width = 10, height = 6)


# ============================================================
# STATUS VACINAL
# ============================================================

db_vac <- data_set_analisado |>
  mutate(vac_status = ifelse(is.na(VACINA) | VACINA == "" | VACINA == "0",
                             "Nao vacinado", "Vacinado"))

tab_vac <- db_vac |>
  count(vac_status) |>
  mutate(perc = n / sum(n))

cat("=== Tabela de vacinacao ===\n")
print(tab_vac)

ggplot(tab_vac, aes(x = vac_status, y = n, fill = vac_status)) +
  geom_col() +
  labs(title = "Casos por status vacinal",
       x = "Status vacinal", y = "Numero de casos") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("resultados/graficos/total_casos_status_vacinal.png", width = 8, height = 6)


# ============================================================
# COMORBIDADES POR SEXO
# ============================================================

tab_comorb_sexo <- data_set_analisado |>
  select(SEXO, all_of(comorb_cols)) |>
  pivot_longer(cols = all_of(comorb_cols),
               names_to = "comorbidade", values_to = "valor") |>
  group_by(SEXO, comorbidade) |>
  summarise(n_sim = sum(valor == 1, na.rm = TRUE), .groups = "drop")

top5_comorb_sexo <- tab_comorb_sexo |>
  group_by(SEXO) |>
  slice_max(order_by = n_sim, n = 5, with_ties = FALSE) |>
  ungroup()

cat("\n=== Top 5 comorbidades por sexo ===\n")
print(top5_comorb_sexo)

ggplot(top5_comorb_sexo, aes(x = comorbidade, y = n_sim, fill = SEXO)) +
  geom_col(position = position_dodge(width = 0.8)) +
  geom_text(aes(label = n_sim),
            position = position_dodge(width = 0.8),
            vjust = -0.3, size = 3.5) +
  labs(title = "Top 5 comorbidades por sexo",
       x = "Comorbidade", y = "Numero de casos") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.title = element_blank())

ggsave("resultados/graficos/top5_comorbidades_por_sexo.png", width = 10, height = 6)


# ============================================================
# SINTOMAS POR SEXO
# ============================================================

tab_sint_sexo <- data_set_analisado |>
  select(SEXO, all_of(sint_cols)) |>
  pivot_longer(cols = all_of(sint_cols),
               names_to = "sintoma", values_to = "valor") |>
  mutate(valor = as.numeric(valor)) |>
  group_by(SEXO, sintoma) |>
  summarise(n_sim = sum(valor == 1, na.rm = TRUE), .groups = "drop") |>
  group_by(SEXO) |>
  mutate(total_sexo = sum(n_sim),
         perc = ifelse(total_sexo > 0, n_sim / total_sexo, NA_real_)) |>
  ungroup() |>
  arrange(SEXO, desc(n_sim))

cat("=== Sintomas mais frequentes por sexo ===\n")
print(tab_sint_sexo)

ggplot(tab_sint_sexo, aes(x = sintoma, y = n_sim, fill = SEXO)) +
  geom_col(position = "dodge") +
  labs(title = "Numero de casos com sintoma por sexo",
       x = "Sintoma", y = "Numero de casos") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("resultados/graficos/casos_sintoma_por_sexo.png", width = 10, height = 6)

top5_sint_sexo <- tab_sint_sexo |>
  group_by(SEXO) |>
  slice_max(order_by = n_sim, n = 5, with_ties = FALSE) |>
  ungroup()

cat("\n=== Top 5 sintomas por sexo ===\n")
print(top5_sint_sexo)

ggplot(top5_sint_sexo, aes(x = sintoma, y = n_sim, fill = SEXO)) +
  geom_col(position = "dodge") +
  labs(title = "Top 5 sintomas por sexo",
       x = "Sintoma", y = "Numero de casos") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("resultados/graficos/top5_sintomas_por_sexo.png", width = 10, height = 6)


# ============================================================
# TOTAL DE CASOS POR FAIXA ETARIA E STATUS VACINAL
# ============================================================

total_casos_faixa <- data_set_analisado |>
  mutate(
    faixa_etaria = criar_faixa_etaria(IDADE),
    status_vacinal = factor(
      case_when(
        VACINA == 1 ~ "Vacinado",
        VACINA == 0 ~ "Nao vacinado",
        TRUE ~ "Ignorado"
      ),
      levels = c("Nao vacinado", "Vacinado", "Ignorado")
    )
  )

tabela_faixa_total <- total_casos_faixa |>
  filter(!is.na(faixa_etaria)) |>
  count(faixa_etaria, name = "total_casos")

print(tabela_faixa_total, n = 50)

ggplot(tabela_faixa_total, aes(x = faixa_etaria, y = total_casos)) +
  geom_col(fill = "#2C6BB0") +
  labs(title = "Total de casos por faixa etaria",
       x = "Faixa etaria", y = "Numero de casos") +
  theme_minimal()

ggsave("resultados/graficos/total_casos_faixa_etaria.png", width = 10, height = 6)

tabela_faixa_status_vac <- total_casos_faixa |>
  filter(!is.na(faixa_etaria)) |>
  count(faixa_etaria, status_vacinal, name = "total_casos") |>
  arrange(faixa_etaria, status_vacinal)

print(tabela_faixa_status_vac, n = 50)

ggplot(tabela_faixa_status_vac,
       aes(x = faixa_etaria, y = total_casos, fill = status_vacinal)) +
  geom_col(position = "dodge") +
  labs(title = "Total de casos por faixa etaria e status vacinal",
       x = "Faixa etaria", y = "Numero de casos", fill = "Status vacinal") +
  theme_minimal()

ggsave("resultados/graficos/total_casos_faixa_etaria_vacinal.png", width = 10, height = 6)


# ============================================================
# INTERNACAO EM UTI
# ============================================================

db_tot <- data_set_analisado |>
  mutate(across(c(VACINA, UTI, RAIOX_RES, TOMO_RES), as.numeric))

n_total <- nrow(db_tot)
n_uti <- sum(db_tot$UTI == 1, na.rm = TRUE)
perc_uti <- (n_uti / n_total) * 100

cat("Total de casos:", n_total, "\n")
cat("Casos em UTI:", n_uti, "\n")
cat("Percentual em UTI:", round(perc_uti, 2), "%\n")

# Taxa de UTI por status vacinal
tab_uti_vac <- data_set_analisado |>
  mutate(vac_status = ifelse(VACINA == 1, "Vacinado", "Nao vacinado")) |>
  group_by(vac_status) |>
  summarise(n_casos = n(),
            n_uti = sum(UTI == 1, na.rm = TRUE),
            taxa_uti = n_uti / n_casos,
            .groups = "drop")

cat("=== Taxa de UTI por status vacinal ===\n")
print(tab_uti_vac)

ggplot(tab_uti_vac, aes(x = vac_status, y = taxa_uti, fill = vac_status)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(title = "Taxa de UTI por status vacinal",
       x = "Status vacinal", y = "Proporcao de casos em UTI") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("resultados/graficos/taxa_uti_status_vacinal.png", width = 8, height = 6)


# ============================================================
# UTI POR FAIXA ETARIA
# ============================================================

dados_com_faixa <- data_set_analisado |>
  mutate(faixa_etaria = criar_faixa_etaria(IDADE))

freq_uti_faixa <- dados_com_faixa |>
  filter(UTI == 1) |>
  count(faixa_etaria, name = "n_uti") |>
  mutate(perc_uti = 100 * n_uti / sum(n_uti)) |>
  arrange(desc(n_uti))

cat("=== Frequencia UTI por faixa etaria ===\n")
print(freq_uti_faixa)

ggplot(freq_uti_faixa, aes(x = faixa_etaria, y = n_uti)) +
  geom_col(fill = "#2E86C1") +
  geom_text(aes(label = n_uti), vjust = -0.3, size = 3.5) +
  labs(title = "Casos de internacao em UTI por faixa etaria",
       x = "Faixa etaria", y = "Numero de casos em UTI") +
  theme_minimal()

ggsave("resultados/graficos/total_uti_faixa_etaria.png", width = 10, height = 6)

ggplot(freq_uti_faixa, aes(x = faixa_etaria, y = perc_uti)) +
  geom_col(fill = "#27AE60") +
  geom_text(aes(label = paste0(round(perc_uti, 1), "%")),
            vjust = -0.3, size = 3.5) +
  labs(title = "Percentual de internacoes em UTI por faixa etaria",
       x = "Faixa etaria", y = "Percentual de casos em UTI") +
  theme_minimal()

ggsave("resultados/graficos/percentual_uti_faixa_etaria.png", width = 10, height = 6)


# ============================================================
# UTI - NAO VACINADOS POR FAIXA ETARIA
# ============================================================

tabela_faixa_n_vac <- dados_com_faixa |>
  filter(UTI == 1, VACINA == 0) |>
  count(faixa_etaria, name = "n_casos_n_vac") |>
  arrange(desc(n_casos_n_vac))

cat("=== UTI por faixa etaria - NAO vacinados ===\n")
print(tabela_faixa_n_vac)

ggplot(tabela_faixa_n_vac, aes(x = faixa_etaria, y = n_casos_n_vac)) +
  geom_col(fill = "#1f77b4") +
  labs(title = "Internados em UTI nao vacinados por faixa etaria",
       x = "Faixa etaria", y = "Numero de casos") +
  theme_minimal()

ggsave("resultados/graficos/uti_nao_vacinados_faixa_etaria.png", width = 10, height = 6)


# ============================================================
# UTI - VACINADOS POR FAIXA ETARIA
# ============================================================

tabela_faixa_vac <- dados_com_faixa |>
  filter(UTI == 1, VACINA == 1) |>
  count(faixa_etaria, name = "n_casos_vac") |>
  arrange(desc(n_casos_vac))

cat("=== UTI por faixa etaria - VACINADOS ===\n")
print(tabela_faixa_vac)

ggplot(tabela_faixa_vac, aes(x = faixa_etaria, y = n_casos_vac)) +
  geom_col(fill = "#1f77b4") +
  labs(title = "Internados em UTI vacinados por faixa etaria",
       x = "Faixa etaria", y = "Numero de casos") +
  theme_minimal()

ggsave("resultados/graficos/uti_vacinados_faixa_etaria.png", width = 10, height = 6)


# ============================================================
# RAIO-X E TOMOGRAFIA
# ============================================================

n_raiox <- sum(db_tot$RAIOX_RES == 1, na.rm = TRUE)
n_tomo <- sum(db_tot$TOMO_RES == 1, na.rm = TRUE)
n_sem <- n_total - n_raiox - n_tomo

cat("=== Exames de imagem ===\n")
cat("Casos com raio-X:", n_raiox, "(", round(100 * n_raiox / n_total, 1), "%)\n")
cat("Casos com tomografia:", n_tomo, "(", round(100 * n_tomo / n_total, 1), "%)\n")
cat("Casos sem exame:", n_sem, "(", round(100 * n_sem / n_total, 1), "%)\n")

df_exames <- tibble(
  categoria = c("Raio-X", "Tomografia", "Sem exame"),
  total = c(n_raiox, n_tomo, n_sem),
  percentual = 100 * total / n_total
)

ggplot(df_exames, aes(x = categoria, y = total, fill = categoria)) +
  geom_col() +
  geom_text(aes(label = format(total, big.mark = ".", decimal.mark = ",")),
            vjust = -0.3, size = 4) +
  labs(title = "Casos por realizacao de exames de imagem",
       x = "Categoria", y = "Numero de casos") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("resultados/graficos/casos_raiox_tomografia_vs_total.png", width = 8, height = 6)

ggplot(df_exames, aes(x = "", y = percentual, fill = categoria)) +
  geom_col(color = "white") +
  coord_polar("y") +
  geom_text(aes(label = paste0(round(percentual, 1), "%")),
            position = position_stack(vjust = 0.5),
            color = "white", size = 4) +
  labs(title = "Percentual de casos por situacao de exame realizado",
       x = NULL, y = NULL, fill = "Categoria") +
  theme_void()

ggsave("resultados/graficos/percentual_exame_realizado.png", width = 8, height = 6)

cat("\n=== Analise concluida. Graficos salvos em resultados/graficos/ ===\n")
