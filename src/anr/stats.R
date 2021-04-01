source("./src/common/department.R")
source("./src/intendentes/countrywise.R")
source("./src/intendentes/districtwise.R")
source("./src/intendentes/graph.R")

anr_mayor_statistics <- function(election_results, income) {
  basepath <- "./data/output/"

  mayor_results <- election_results %>%
                    filter(cand_desc == "INTENDENTE")

  #' anr_mayor_general_performance(mayor_results)
  #' anr_mayor_district_comp(election_results, basepath)
  anr_graph_results_vs_income(mayor_results, income)
}

# Generates graphs comparing department-wise election results and income.
anr_graph_results_vs_income <- function(mayor_results, income) {
  # Mayor vote share in 2015 vs income.
  title <- "Porcentaje de votos vs. Promedio de ingresos"
  xlab <- "Promedio de ingresos en 2017 (en millones de Gs.)"
  ylab <- "Porcentaje de votos en 2015 (intendencia)"
  saved_to <- "./graphs/2015-voteshare_per_dep-vs-income.png"

  mayor_results %>%
    anr_mayor_share_per_dep(2015) %>%
    make_vs_income_graph(income, title, xlab, ylab, saved_to)
}

make_vs_income_graph <- function(results, income, title, xlab, ylab, saved_to) {
  results %>%
    left_join(income, c("dep" = "dep")) %>%
    mutate(income = ingresos / 1000000) %>%
    select(-ingresos) %>%
    graph_voteshare_vs_income(title, xlab, ylab, saved_to)
}

# Runs analysis on the ANR's general performance accross the country.
anr_mayor_general_performance <- function(election_results) {
  election_results %>%
    mayor_general_performance("ANR") %>%
    print()

  election_results %>%
    mayor_pwc_voteshare_per_year("ANR") %>%
    print()
}

# Generates a dataset with the change in vote share per district over the years.
anr_mayor_district_comp <- function(mayor_results, basepath) {
  filename <- paste(basepath, "anr_delta_voteshare_district.csv", sep = "")

  mayor_results %>%
    mayor_delta_voteshare_per_city("ANR") %>%
    write.csv(file = filename)
}

#' Calculates the average vote share for the ANR per district. Then, it takes
#' the mean of the vote shares grouping by department.
anr_mayor_avgshare_per_dep <- function(election_results) {
  election_results %>%
    dplyr::filter(siglas_lista == "ANR") %>%
    avgshare_per_dep()
}

#' Calculates the vote share per department for the ANR over all the years.
anr_mayor_share_per_dep <- function(election_results, year = NULL) {
  anr_results <- election_results %>%
                   dplyr::filter(siglas_lista == "ANR", anio == year)

  if (!is.null(year)) {
    anr_results <- anr_results %>%
                     dplyr::filter(anio == year)
  }

  anr_results %>%
    share_per_dep()
}