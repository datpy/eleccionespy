source("./src/common/department.R")
source("./src/intendentes/countrywise.R")
source("./src/intendentes/departmentwise.R")
source("./src/intendentes/districtwise.R")
source("./src/intendentes/graph.R")
source("./src/common/graph.R")

anr_mayor_statistics <- function(election_results, electoral_roll,
                                 dev_indicators) {

  #' basepath <- "./data/output/"

  # Data on electoral roll is only availables since 1998, so remove the ones
  # before.
  mayor_results <- election_results %>%
                     dplyr::filter(cand_desc == "INTENDENTE",
                                   anio == 2015)

  anr_mayor_results <- mayor_results %>%
                         dplyr::filter(siglas_lista == "ANR")

  #' Use electoral roll for the general elections as proxy for the local ones.
  #' 2018 -> 2015
  electoral_roll <- electoral_roll %>%
                      dplyr::filter(anio == 2018) %>%
                      voters_per_district() %>%
                      mutate(anio = anio - 3)

  #' anr_mayor_general_performance(mayor_results)
  #' anr_mayor_district_comp(election_results, basepath)
  #' anr_graph_results_vs_income(anr_mayor_results, income)

  #' district_level_model(mayor_results, electoral_roll)
  dep_level_model(mayor_results, electoral_roll, dev_indicators)
}

# Generates graphs comparing department-wise election results and income.
anr_graph_results_vs_income <- function(mayor_results, dev_indicators) {
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

#' Creates a statistical model for datapoints at the department level.
#'
#' This function expects that the election results and electoral roll are from
#' a specific year.
dep_level_model <- function(election_results, electoral_roll, dev_indicators) {
  anr_mayor_results <- election_results %>%
                         dplyr::filter(siglas_lista == "ANR")

  electoral_roll <- electoral_roll %>%
                      group_by(dep, depdes) %>%
                      summarise(eligible_voters = sum(eligible_voters),
                                .groups = "drop")

  tb <- anr_mayor_results %>%
          anr_mayor_share_per_dep()

  tb <- tb %>%
          inner_join(electoral_roll, c("dep" = "dep", "depdes" = "depdes")) %>%
          mutate(turnout = total_votos / eligible_voters * 100)

  print(tb)

  indicators <- dep_process_dev_indicators(dev_indicators)

  tb <- tb %>%
          inner_join(indicators, c("dep" = "dep", "depdes" = "depdes"))

  linear_mod <- lm(vote_share ~ income_2017 + turnout + poverty_2017 +
                                nbi_2012 + adlcnt_pregnancy_2018,
                   data = tb)
  print(summary(linear_mod))

  scatter(tb, aes(poverty_2017, vote_share), saved_to = "test")
}

dep_process_dev_indicators <- function(dev_indicators) {
  nbi <- dev_indicators %>%
                  filter(!is.na(PBRZ_NBI), anio == 2012) %>%
                  select(dep, depdes, PBRZ_NBI) %>%
                  rename(nbi_2012 = PBRZ_NBI)

  total_poverty <- dev_indicators %>%
                     filter(!is.na(PBRZ_PTOTL), anio == 2017) %>%
                     select(dep, depdes, PBRZ_PTOTL) %>%
                     rename(poverty_2017 = PBRZ_PTOTL)

  income <- dev_indicators %>%
              filter(!is.na(ECON_IMAP), anio == 2017) %>%
              select(dep, depdes, ECON_IMAP) %>%
              rename(income_2017 = ECON_IMAP) %>%
              mutate(income_2017 = income_2017 / 1000000)

  adlcnt_pregnancy <- dev_indicators %>%
                        filter(!is.na("SALU_PMNV10-19"), anio == 2018) %>%
                        select(dep, depdes, "SALU_PMNV10-19") %>%
                        rename(adlcnt_pregnancy_2018 = "SALU_PMNV10-19")

  nbi %>%
    inner_join(total_poverty, c("dep" = "dep", "depdes" = "depdes")) %>%
    inner_join(income, c("dep" = "dep", "depdes" = "depdes")) %>%
    inner_join(adlcnt_pregnancy, c("dep" = "dep", "depdes" = "depdes"))
}

#' Creates a statistical model for datapoints at the district level.
#'
#' TODO: Think of obtainable variables to add to the model. The current ones are
#' not good at all to explain variance.
district_level_model <- function(election_results, electoral_roll) {
  results <- election_results %>%
               ncandidates_per_district(5)

  results <- election_results %>%
               diff_voteshare_per_district("ANR") %>%
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
