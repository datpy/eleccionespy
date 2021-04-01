library(dplyr)
library(tidyr)

#' Calculates the average change in vote share per district for a particular
#' party.
#'
#' This functions expects that the results dataframe only corresponds to the
#' election of mayors.
mayor_delta_voteshare_per_city <- function(election_results, party) {
  if (is.null(party)) {
    stop("party must be specified")
  }

  # Obtains election results per district and year for ANR and calculates the
  # vote share.
  party_results <- election_results %>%
                   dplyr::filter(siglas_lista == party) %>%
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
  party_results <- party_results %>%
                     arrange(depdes, disdes) %>%
                     group_by(depdes, disdes) %>%
                     dplyr::filter(n() > 2) %>%
                     mutate(delta = dplyr::lag(vote_share) - vote_share) %>%
                     select(-votos, -total_votos, -vote_share)

  # Runs a simple model in which, for each district, we take the average change
  # in vote share over the years.
  avg_delta <- party_results %>%
                dplyr::filter(!is.na(delta))  %>%
                summarise(avg_delta = mean(delta), .groups = "keep")

  # Spreads the change in vote share and adds an average change column.
  party_results <- party_results %>%
                     spread(anio, delta) %>%
                     ungroup() %>%
                     mutate(avg_delta = avg_delta$avg_delta)
}
