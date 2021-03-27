setwd("~/Data/Elecciones/eleccionespy")

source("./src/intendentes.R")

# Import and clean election results.
election_results <- read.csv(file = "./data/resultados-1996-2018.csv")
election_results <- subset(results, select = -c(zondes, locdes,
                                      candidatura, nombre_lista, lista))
colnames(results)[1] <- "anio"

mayor_results <- results[results$cand_desc == "INTENDENTE", ]
mayor_general_performance(mayor_results)
mayor_pwc_voteshare_per_year(mayor_results)
mayor_delta_voteshare_per_city(mayor_results)
