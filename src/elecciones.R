setwd("~/Data/Elecciones/eleccionespy")

source("./src/intendentes.R")

# Import and clean results.
results <- read.csv(file = "./data/resultados-1996-2018.csv")
results <- subset(results, select = -c(depdes, zondes, locdes,
                                      candidatura, nombre_lista, lista))
colnames(results)[1] <- "anio"

mayor_results <- results[results$cand_desc == "INTENDENTE", ]

mayor_general_performance(mayor_results)
mayor_pwc_vote_share_per_year(mayor_results)
