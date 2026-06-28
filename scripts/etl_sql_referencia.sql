# 1. A primeira etapa da tranformação foi feita com linguagem R.
# O Script esta descrito no arquivo (Analise_script.R).

# 2. A segunda etapa foi feita no EXCEL, editado no Power Query.

# O QUE FOI FEITO

#Os dados estavam classificados como 1- positivo, 2- negativo, 9- não classificado, para comorbidades, sintomas e vacinação.
#E para os exames de raoi-x e tomografia, eles estavam classificados de 1 a 6, sendo o numero 1 o resultado positivo.
#No excel eu alterei os numeros de 2 a 9 para 0, e deixei apenas o 1. Sendo 1 positivo e 0 negativo.

#3.Esta parte do SQL não é necessária, eu fiz para treinar converter CSV em SQL com o RSTUDIO e ter este caminho salvo.

Para fazer esse exercicio eu usei os dados brutos extraidos do datasus, e o processo de transformaçao que eu fiz em linguagem R, também da pra fazer com o SQL.

#TRANSFORMAR ARQUIVO CSV EM SQL. Precisa ter o SQLlite instalado.

#Instale e carregue os pacotes necessários
install.packages(c("DBI", "RSQLite", "data.table"))
library(DBI)
library(RSQLite)
library(data.table)

#Criei uma conexão com um banco SQLite (arquivo local):
conexao <- dbConnect(SQLite(), dbname = "covid_2025.sqlite") 

#Ler o CSV e insira na tabela:
dados <- fread("INFLUD25-15-12-2025.csv")
dbWriteTable(conexao, "dados_covid", dados) 

#Encerre a conexão
dbDisconnect(conexao)

#Query

SELECT NU_NOTIFIC
       DT_NOTIFIC
       SG_UF, 
       ID_MUNICIP,
       ID_PAIS,
       CS_SEXO,
       NU_IDADE_N,
       FEBRE,
       TOSSE,
       GARGANTA,
       DESC_RESP,
       SATURACAO,
       DIARREIA,
       VOMITO,
       FATOR_RISC
       PIERPERA,
       CARDIOPATI,
       HEMATOLOGI,
       SIND_DOWN,
       HEPATICA,
       ASMA,
       DIABETES,
       NEUROLOGIC,
       PNEUMOPATI,
       IMUNODEPRE,
       RENAL,
       OBESIDADE,
       DOR_ABD,
       FADIGA,
       PERD_OLFT,
       PERD_PALA,
       VACINA,
       DT_INTERNA,
       DT_INTERN,
       UTI,
       RAIOX_RES,
       TOMO_RES,
       AMOSTRA
FROM dados_covid
GROUP BY ID_MUNICIP
ORDER BY SG_UF

SELECT 
  UF,
  SUM(FEBRE) AS FEBRE,
  SUM(TOSSE) AS TOSSE,
  SUM(GARGANTA) AS GARGANTA,
  SUM(RESPIRATORIO) AS RESPIRATORIO,
  SUM(DIARREIA) AS DIARREIA,
  SUM(VOMITO) AS VOMITO,
  SUM(PUERPERA) AS PUERPERA,
  SUM(CARDIOPATICO) AS CARDIOPATICO,
  SUM(HEMATOLOGICO) AS HEMATOLOGICO,
  SUM(DOWN) AS DOWN,
  SUM(HEPATICA) AS HEPATICA,
  SUM(ASMA) AS ASMA ,
  SUM(DIABETES) AS DIABETES,
  SUM(NEUROLOGICO) AS NEUROLOGICO,
  SUM(PNEUMOPATICO) AS PNEUMOPATICO,
  SUM(IMUNODEPRE) AS IMUNODEPRE,
  SUM(RENAL) AS RENAL,
  SUM(OBESIDADE) AS OBESIDADE,
  SUM(DOR_ABD) AS DOR_ABD,
  SUM(FADIGA)  AS FADIGA,
  SUM(PERD_OLFT) AS PERD_OLFT,
  SUM(PERD_PALA) AS PERD_PALA,
  SUM(UTI) AS UTI,
  SUM(RAIOX) AS RAIOX,
  SUM(TOMOGRAFIA) AS TOMOGRAFIA,
  SUM(AMOSTRA) AS AMOSTRA,
  COUNT(*) AS total_casos
FROM dados_covid
GROUP BY UF
ORDER BY UF, total_casos DESC

SELECT 
  UF,
  SUM(PUERPERA) AS PUERPERA,
  SUM(CARDIOPATICO) AS CARDIOPATICO,
  SUM(HEMATOLOGICO) AS HEMATOLOGICO,
  SUM(DOWN) AS DOWN,
  SUM(HEPATICA) AS HEPATICA,
  SUM(ASMA) AS ASMA ,
  SUM(DIABETES) AS DIABETES,
  SUM(NEUROLOGICO) AS NEUROLOGICO,
  SUM(PNEUMOPATICO) AS PNEUMOPATICO,
  SUM(IMUNODEPRE) AS IMUNODEPRE,
  SUM(RENAL) AS RENAL,
  SUM(OBESIDADE) AS OBESIDADE,
  COUNT(*) AS total_casos
FROM dados_covid
GROUP BY UF
ORDER BY UF, total_casos DESC


