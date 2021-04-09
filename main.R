library(dplyr)
library(tidyverse)

setwd("~/Data/Elecciones/eleccionespy")

source("./src/anr/stats.R")

# Import and clean election results.
elec_col_types <- cols(
  zon = col_integer(),
  zondes = col_character(),
  loc = col_integer(),
  locdes = col_character(),
  lista = col_integer()
)

roll_col_types <- cols(
  zon = col_integer(),
  zondes = col_character(),
  loc = col_integer(),
  locdes = col_character()
)

election_results <- read_csv(file = "./data/resultados-1996-2018.csv",
                            col_types = elec_col_types) %>%
                    select(anio, dep, depdes, dis, disdes, zon, loc, cand_desc,
                           siglas_lista, votos, total_votos)

# Electoral roll for elections 1998-2018.
roll <- read_csv(file = "./data/padron-1998-2018.csv",
                 col_types = roll_col_types) %>%
        select(anio, dep, depdes, dis, disdes, total) %>%
        rename(eligible_voters = total)

# Import income information.
income <- read_csv(file = "./data/ingresos-promedios-2017.csv") %>%
            select(-anio, -depdes) %>%
            rename(ingresos = ingresos_act_principal)


anr_mayor_statistics(election_results, roll, income)
