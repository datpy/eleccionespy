library(dplyr)
library(tidyverse)

setwd("~/Data/Elecciones/eleccionespy")

source("./src/intendentes/intendentes.R")
source("./src/intendentes/graph.R")

# Import and clean election results.
election_results <- read_csv(file = "./data/resultados-1996-2018.csv") %>%
                    rename(anio = año) %>%
                    select(anio, dep, depdes, dis, disdes, cand_desc,
                           siglas_lista, votos, total_votos)

# Import income information.
income <- read_csv(file = "./data/ingresos-promedios-2017.csv") %>%
            select(-anio, -depdes) %>%
            rename(ingresos = ingresos_act_principal)

mayor_results <- election_results %>%
                    filter(cand_desc == "INTENDENTE")

#' mayor_general_performance(mayor_results)
#' mayor_pwc_voteshare_per_year(mayor_results)
#' mayor_delta_voteshare_per_city(mayor_results)

anr_results <- mayor_avg_voteshare_per_dep(mayor_results) %>%
                 left_join(income, c("dep" = "dep")) %>%
                 mutate(ingresos = ingresos / 1000000)

title <- "Departamentos: Porcentaje de votos vs. Promedio de ingresos"
xlab <- "Promedio de ingresos en 2017 (en millones de Gs.)"
ylab <- "Promedio de porcentaje de votos (1996 - 2015)"
print(graph_voteshare_vs_income(anr_results, title, xlab, ylab))
