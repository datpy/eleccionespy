setwd("~/Data/Elecciones/eleccionespy")

source("./src/intendentes.R")

# Import and clean results.
results <- read.csv(file = "./data/resultados-1996-2018.csv")
results <- subset(results, select = -c(depdes, zondes, locdes,
                                      candidatura, nombre_lista, lista))
colnames(results)[1] <- "anio"

mayor_results <- results[results$cand_desc == "INTENDENTE", ]
general_performance_mayors(mayor_results)


#'
# Results for ANR.
#
# anr_results <- results[results$siglas_lista == "ANR", ]
# years <- unique(results$anio)
# anr_props <- list()

# for (i in 1:length(years)) {
#     anr_props[[i]] <- as.vector(results[results$anio == years[i], ]$prop_votos)
# }

# # Test two-sample difference in means between the proportion of votes in first
# # and last municipal elections.
# t.test(anr_props[[1]], anr_props[[length(anr_props)]],
#         alternative = "two.sided", paired = FALSE, conf.level = 0.95)
