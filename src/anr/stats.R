source("./src/common/department.R")
source("./src/intendentes/countrywise.R")
source("./src/intendentes/departmentwise.R")
source("./src/intendentes/districtwise.R")
source("./src/intendentes/graph.R")
source("./src/common/graph.R")

anr_mayor_statistics <- function(election_results, electoral_roll, income) {
  #' basepath <- "./data/output/"

  # Data on electoral roll is only availables since 1998, so remove the ones
  # before.
  mayor_results <- election_results %>%
                     dplyr::filter(cand_desc == "INTENDENTE",
                                   anio == 2015)

  anr_mayor_results <- mayor_results %>%
                         dplyr::filter(siglas_lista == "ANR")

  #' Use electoral roll for the general elections as proxy for the local ones.
  #' 2003 -> 2001
  #' 2008 -> 2005
  #' 2013 -> 2010
  #' 2018 -> 2015
  electoral_roll <- electoral_roll %>%
                      dplyr::filter(anio > 1998) %>%
                      voters_per_district() %>%
                      mutate(anio = anio - 3) %>%
                      mutate(anio = if_else(anio == 2000, 2001, anio))

  #' anr_mayor_general_performance(mayor_results)
  #' anr_mayor_district_comp(election_results, basepath)
  #' anr_graph_results_vs_income(anr_mayor_results, income)

  district_level_model(mayor_results, electoral_roll, income)
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
    make_vs_income_graph(income, title, xlab, ylab, saved_to,
                         graph_voteshare_vs_income)

  ###
  ### Not statistically significant results.
  ###
  #' title <- "Promedio de cambio vs. Promedio de ingresos"
  #' ylab <- "Promedio de cambio de porcentaje de votos (intendencia)"
  #' saved_to <- "./graphs/delta_voteshare_per_dep-vs-income.png"
  #' mayor_results %>%
  #'   mayor_delta_voteshare_per_dep("ANR") %>%
  #'   make_vs_income_graph(income, title, xlab, ylab, saved_to,
  #'                        graph_deltashare_vs_income)
}

make_vs_income_graph <- function(results, income, title, xlab, ylab,
                                 saved_to, fn) {
  results %>%
    left_join(income, c("dep" = "dep")) %>%
    mutate(income = ingresos / 1000000) %>%
    select(-ingresos) %>%
    fn(title, xlab, ylab, saved_to)
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
  anr_results <- election_results

  if (!is.null(year)) {
    anr_results <- anr_results %>%
                     dplyr::filter(anio == year)
  }

  anr_results %>%
    share_per_dep()
}

#' Creates a statistical model for datapoints at the district level.
#'
#' TODO: Think of obtainable variables to add to the model. The current ones are
#' not good at all to explain variance.
district_level_model <- function(election_results, electoral_roll) {
  results <- election_results %>%
               ncandidates_per_district(5)

  results <- election_results %>%
               diff_voteshare("ANR") %>%
               inner_join(results,
                          c("anio" = "anio", "dep" = "dep", "depdes" = "depdes",
                           "disdes" = "disdes"))

  results <- results %>%
               inner_join(electoral_roll,
                          c("anio" = "anio", "dep" = "dep", "depdes" = "depdes",
                           "disdes" = "disdes"))

  results <- results %>%
               inner_join(votes_per_district(election_results),
                          c("anio" = "anio", "dep" = "dep", "depdes" = "depdes",
                           "disdes" = "disdes")) %>%
                mutate(turnout = total_votos / eligible_voters * 100)

  linear_mod <- lm(win ~ n_candidates + n_rel_candidates + turnout,
                   data = results)
  print(summary(linear_mod))

  linear_mod <- lm(share_diff ~ n_candidates + n_rel_candidates + turnout,
                  data = results)
  print(summary(linear_mod))

  #' scatter(results, aes(turnout, share_diff), saved_to = "test")
}
