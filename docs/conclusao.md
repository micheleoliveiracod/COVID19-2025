
**`❓Algumas questões respondidas:`**

Quais comorbidades são mais frequentes?

Quais sintomas são mais frequentes?

Quais comorbidades são mais frequentes por sexo?

Quais sintomas e comorbidades são mais frequentes por sexo?

Quantos casos vacinados em relação ao total?

Quantos casos de internação em (UTI) em relação ao total de casos ?

Qual a taxa de internação (UTI) entre vacinados e não vacinados ?

Em quantos casos fizeram raoi-x e tomografia em relação ao total ?


#CONCLUSÃO#

Numero de casos: 318.735

O sexo masculino tem maior numero de casos, no entanto, é um valor bem semelhante ao grupo feminino.
Exitem 44 pacientes sem classificação de sexo.

=== Total por sexo ===
SEXO  frequencia
  <chr>      <int>
1 F         154.193
2 I             44
3 M         164.498


As comorbidades mais frequentes são cardiopatia, diabetes, asma e pneumaticas, neurologicas e em sexto a obesidade.
=== Top 5 comorbidades por sexo ===

SEXO  comorbidade    n_sim
   <chr> <chr>        <int>
 1 F     CARDIOPATICO 26480
 2 F     DIABETES     16963
 3 F     ASMA         11832
 4 F     PNEUMOPATICO  8846
 5 F     NEUROLOGICO   6615
 6 I     ASMA             2
 7 I     CARDIOPATICO     1
 8 I     IMUNODEPRE       1
 9 I     NEUROLOGICO      1
10 I     OBESIDADE        1
11 M     CARDIOPATICO 21125
12 M     DIABETES     12531
13 M     ASMA         10189
14 M     PNEUMOPATICO  7736
15 M     NEUROLOGICO   6949


O sexo masculino tem mais comorbidades e sintomas do que o feminino. A incidência de comorbidade segue a mesma do geral para ambos os sexos.

O sintomas mais frequentes são tosse, febre e todos os outros relacionados ao trato resporatório respectivamente.

=== Sintomas mais frequentes por sexo ===

SEXO  sintoma       n_sim total_sexo   perc
   <chr> <chr>         <int>      <int>  <dbl>
 1 F     TOSSE        123517     495371 0.249 
 2 F     RESPIRATORIO 104813     495371 0.212 
 3 F     FEBRE         92314     495371 0.186 
 4 F     SATURACAO     83503     495371 0.169 
 5 F     FADIGA        28674     495371 0.0579
 6 I     TOSSE            36        139 0.259 
 7 I     RESPIRATORIO     34        139 0.245 
 8 I     FEBRE            29        139 0.209 
 9 I     SATURACAO        21        139 0.151 
10 I     GARGANTA          6        139 0.0432
11 M     TOSSE        132843     528052 0.252 
12 M     RESPIRATORIO 114611     528052 0.217 
13 M     FEBRE        103773     528052 0.197 
14 M     SATURACAO     87539     528052 0.166 
15 M     FADIGA        28399     528052 0.

Analisando o total geral de casos por faixa etária, as idades de 0 - 10 anos e os idosos 60+ representam a maior parte dos casos.

=== Total de casos por faixa etária ===

faixa_etaria total_casos
   <fct>              <int>
 1 0-1                42.944
 2 2-5                76.814
 3 6-10               48.724
 4 11-17              14.297
 5 18-29               9.786
 6 30-39               9.241
 7 40-49              11.688
 8 50-59              15.381
 9 60-69              24.081
10 70-79              29.387
11 80+                34.531


Analisando o total geral de casos por faixa etária e status vacinal, podemos observar que o adrão continua o mesmo, com maior numero de casos entre crianças de 0 a 10 anos e idosos 60+.

=== Total geral de casos por faixa etária e status vacinal ===

faixa_etaria status_vacinal total_casos
   <fct>        <fct>                <int>
 1 0-1          Não vacinado         31.707
 2 0-1          Vacinado             11.237
 3 2-5          Não vacinado         63.456
 4 2-5          Vacinado             13.358
 5 6-10         Não vacinado         37.081
 6 6-10         Vacinado             11.643
 7 11-17        Não vacinado         11.093
 8 11-17        Vacinado              3.204
 9 18-29        Não vacinado          7.927
10 18-29        Vacinado              1.859
11 30-39        Não vacinado          7.440
12 30-39        Vacinado              1.801
13 40-49        Não vacinado          9.484
14 40-49        Vacinado              2.204
15 50-59        Não vacinado         11.942
16 50-59        Vacinado              3.439
17 60-69        Não vacinado         16.108
18 60-69        Vacinado              7.973
19 70-79        Não vacinado         17.904
20 70-79        Vacinado             11.483
21 80+          Não vacinado         20.030
22 80+          Vacinado             14.501


Em relação ao total de casos, a taxa de internação na UTI é de 26% em relação ao total.

Total de casos: 318.735 
Casos em UTI: 83.005 
Percentual em UTI: 26.04 %

A faixa etária que mais teve casos de internação na UTI foi de 0 a 10 anos (crianças), seguidos dos idosos.

=== Frequencia UTI por faixa etaria ===
faixa_etaria n_uti perc_uti
   <fct>        <int>    <dbl>
 1 2-5          18212 21.9    
 2 0-1          11351 13.7    
 3 6-10         10833 13.1    
 4 70-79         8701 10.5    
 5 80+           8654 10.4    
 6 60-69         7513  9.05   
 7 50-59         4801  5.78   
 8 11-17         3894  4.69   
 9 40-49         3656  4.40   
10 18-29         2715  3.27   
11 30-39         2674  3.22   
12 NA               1  0.00120

Dos 83.005 internados na UTI, 63.107 não se vacinaram.

=== Taxa de UTI (gravidade) por status vacinal ===
> print(tab_uti_vac)
# A tibble: 2 × 4
  vac_status   n_casos n_uti taxa_uti
  <chr>          <int> <int>    <dbl>
1 Não vacinado  235.426 63.107    0.268
2 Vacinado       83.309 19.898    0.239

Entre os NAO VACINADOS, as crianças até 10 anos e idosos 70+ lideram o numero de casos.

=== Tabela de casos UTI por faixa etária NÃO VACINADOS ===

   faixa_etaria n_casos_n_vac
   <fct>                <int>
 1 2-5                  15665
 2 0-1                   9014
 3 6-10                  8439
 4 70-79                 5349
 5 80+                   5208
 6 60-69                 5145
 7 50-59                 3796
 8 11-17                 3057
 9 40-49                 2970
10 18-29                 2267
11 30-39                 2196
12 NA                       1


Para os internados na UTI e vacinados, o maior numero de casos foram os idosos 70+

=== Tabela de casos UTI por faixa etária VACINADOS ===

   faixa_etaria n_casos_vac
   <fct>              <int>
 1 80+                 3446
 2 70-79               3352
 3 2-5                 2547
 4 6-10                2394
 5 60-69               2368
 6 0-1                 2337
 7 50-59               1005
 8 11-17                837
 9 40-49                686
10 30-39                478
11 18-29                448

Nos casos de não vacinados e internados na UTI, as crianças de 0 a 10 anos foram o grupo mais frequente.

No Brasil, os protocolos atuais do Programa Nacional de Imunizações (PNI) do Ministério da Saúde, incluem a vacinação contra COVID-19 a partir dos 6 meses de idade para crianças.

Isso significa de 0 a 6 meses de vida, crianças nesta faixaetária ficam desprotegidas imunologicamente.

No entanto, não temos como supor que a falta de vacinação foi a causa.

Nos casos de vacinados e internados na UTI, os idosos foram o grupo mais frequente e na sequecia as crianças.

A faixa etaria 0 a 10 anos foi a primeira e de 70+ anos foi a segunda, em maior numero de casos vacinados e não vacinados na UTI.

Então não podemos supor que a falta de vacinação seja um fator determinante de internação e agravamento da doença.

Se faz necessário a continuidade das analises, correlacionando estes indicadores com as comorbidades dos pacientes.

Considerando que as comorbidades mais frequentes na população deste estudo são, cardiopatia e diabetes, é possivel que seja o fator de agravamento.

São doenças que afetam o sistema imunologico do paciente, principalmente nos iddosos.

O raio-x foi o exame mais realizado, sendo uma taxa de 14% em relação ao total.

Mas para a maioria dos casos não foram realizados exames de imagem.

E em (84.2%) dos casos foram realizados exames labratoriais.

Casos totais: 318735 (100%)
Casos com raio-X:45674 (14.3%)
Casos com tomografia:4642 (1.5%)
Casos sem exame laboratorial:268419 (84.2%)












