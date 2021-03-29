library(dplyr)
library(rstatix)

source("./src/common/common.R")

#' Calculates the general perfomance of the ANR in the mayor elections for each
#' year available in the dataset.
#'
#' This functions expects that the results dataframe only corresponds to the
#' election of mayors.
mayor_general_performance <- function(election_results) {

  # Calculates the total number of votes casted in favor of each party in each
  # election.
  votes_per_party <- election_results %>%
                       group_by(anio, siglas_lista) %>%
                       summarise(votos = sum(votos),
                                .groups = "drop")

  # Calculates the total number of votes casted in each election.
  total_votes <- election_results %>%
                   group_by(anio, disdes, zon, loc) %>%
                   # Total votes per district are repeated, get the first one.
                   slice_head() %>%
                   group_by(anio) %>%
                   summarise(total_votos = sum(total_votos))

  # Calculates the ANR general performance over the years.
  anr_votes <- votes_per_party %>%
                 dplyr::filter(siglas_lista == "ANR") %>%
                 mutate(total_votos = total_votes$total_votos,
                        vote_share = votos / total_votes$total_votos)

  print(anr_votes)
}


#' Runs yearly pairwise comparisons of the mean of vote shares per district.
#'
#' This functions expects that the results dataframe only corresponds to the
#' election of mayors.
mayor_pwc_voteshare_per_year <- function(election_results) {
  votes_per_party <- election_results %>%
                       group_by(anio, disdes, siglas_lista) %>%
                       summarise(votos = sum(votos),
                                 total_votos = sum(total_votos),
                                 .groups = "drop") %>%
                       mutate(vote_share = votos / total_votos)

  anr_results <- votes_per_party %>%
                   dplyr::filter(siglas_lista == "ANR", !is.na(vote_share))

  # Pairwise comparisons over the years.
  pwc <- anr_results %>%
           tukey_hsd(vote_share ~ as.factor(anio))

  print(pwc)
}

#' Calculates the average vote share for the ANR per district. Then, it takes
#' the mean of the vote shares grouping by department.
mayor_avg_voteshare_per_dep <- function(election_results) {
  results <- election_results %>%
               dplyr::filter(siglas_lista == "ANR")

  avg_voteshare_per_dep(results)
}

#' Calculates the average change in vote share for the ANR per district.
#'
#' This functions expects that the results dataframe only corresponds to the
#' election of mayors.
mayor_delta_voteshare_per_city <- function(election_results) {
  # Obtains election results per districct and year for ANR and calculates the
  # vote share.
  anr_results <- election_results %>%
                   dplyr::filter(siglas_lista == "ANR") %>%
                   group_by(anio, depdes, disdes) %>%
                   summarise(votos = sum(votos),
                             total_votos = sum(total_votos),
                             .groups = "drop") %>%
                   mutate(vote_share = votos / total_votos * 100)

  # Group the results by district in order to add a change in vote share between
  # 2 consecutive years.
  #
  # Arranging by disdes is needed since lag only works using the previous row,
  # and we want to take the difference in vote share between 2 consecutive years
  # for the same district.
  #
  # The row with the base case (first election for a district) gets a NA for
  # delta
  anr_results <- anr_results %>%
                   arrange(depdes, disdes) %>%
                   group_by(depdes, disdes) %>%
                   dplyr::filter(n() > 2) %>%
                   mutate(delta = dplyr::lag(vote_share) - vote_share)

  # Save the change in vote share per year and district.
  anr_results %>%
    select(depdes, disdes, delta) %>%
    write.csv(file = "./data/output/anr_delta_voteshare_district.csv")

  # Runs a simple model in which, for each district, we take the average change
  # in vote share over the years.
  anr_results <- anr_results %>%
                   dplyr::filter(!is.na(delta))  %>%
                   group_by(depdes, disdes) %>%
                   summarise(avg_delta = mean(delta))

  # Save the average change in vote shater per year and district.
  anr_results %>%
    select(depdes, disdes, avg_delta) %>%
    write.csv(file = "./data/output/anr_avg_delta_voteshare.csv")

  anr_results <- anr_results %>%
                   group_by(depdes) %>%
                   summarise(avg_of_avg_delta = mean(avg_delta)) %>%
                   arrange(desc(avg_of_avg_delta))

  print(anr_results)
}