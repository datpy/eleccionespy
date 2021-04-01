library(dplyr)
library(tidyverse)

setwd("~/Data/Elecciones/eleccionespy")

source("./src/anr/stats.R")

# Import and clean election results.
col_types <- cols(
  zon = col_integer(),
  zondes = col_character(),
  loc = col_integer(),
  locdes = col_character(),
  lista = col_integer()
)
election_results <- read_csv(file = "./data/resultados-1996-2018.csv",
                            col_types = col_types) %>%
                    rename(anio = año) %>%
                    select(anio, dep, depdes, dis, disdes, zon, loc, cand_desc,
                           siglas_lista, votos, total_votos)

# Import income information.
income <- read_csv(file = "./data/ingresos-promedios-2017.csv") %>%
            select(-anio, -depdes) %>%
            rename(ingresos = ingresos_act_principal)


anr_mayor_statistics(election_results, income)
