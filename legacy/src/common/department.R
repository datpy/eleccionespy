
#' Calculates the average vote share per district. Then, it takes the mean of
#' the vote shares grouping by department.
#'
#' To use this function, make sure to filter the results for the specific
#' subset of data such as specific party, election type, or year.
avgshare_per_dep <- function(election_results) {
  # Obtains election results per districct and year for ANR and calculates the
  # vote share.
  results <- election_results %>%
                   group_by(anio, dep, depdes) %>%
                   summarise(votos = sum(votos),
                             total_votos = sum(total_votos),
                             .groups = "drop") %>%
                   mutate(vote_share = votos / total_votos * 100)

  # Take the means of vote share accross all the districts under the same
  # department.
  results %>%
    group_by(dep, depdes) %>%
    summarise(vote_share = mean(vote_share), .groups = "drop")
}

#' Calculates the vote share per department.
#'
#' To use this function, make sure to filter the results for the specific
#' subset of data such as specific party, election type, or year.
share_per_dep <- function(election_results) {
  election_results %>%
    group_by(dep, depdes) %>%
    summarise(votos = sum(votos),
              total_votos = sum(total_votos),
              vote_share = votos / total_votos * 100,
              .groups = "drop")
}
