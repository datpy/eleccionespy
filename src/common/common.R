
#' Calculates the average vote share for the ANR per district. Then, it takes
#' the mean of the vote shares grouping by department.
avg_voteshare_per_dep <- function(election_results) {
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
  results <- results %>%
               group_by(dep, depdes) %>%
               summarise(vote_share = mean(vote_share), .groups = "drop")
}
