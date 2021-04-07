source("./src/intendentes/districtwise.R")

#' Calculates the average change in vote share per department for a particular
#' party.
#'
#' Calculates the average change in vote share per district for a particular
#' party.
mayor_delta_voteshare_per_dep <- function(election_results, party) {
  if (is.null(party)) {
    stop("party must be specified")
  }

  # Obtains a party's election results per department and year and calculates
  # the vote share.
  party_results <- election_results %>%
                   dplyr::filter(siglas_lista == party) %>%
                   group_by(anio, dep, depdes) %>%
                   summarise(votos = sum(votos),
                             total_votos = sum(total_votos),
                             .groups = "keep") %>%
                   mutate(vote_share = votos / total_votos * 100)

  # Group the results by department in order to add a change in vote share
  # between 2 consecutive years.
  #
  # Arranging by dep is needed since lag only works using the previous row,
  # and we want to take the difference in vote share between 2 consecutive years
  # for the same district.
  #
  # The row with the base case (first election for a district) gets a NA for
  # delta
  party_results <- party_results %>%
                     arrange(dep) %>%
                     group_by(dep) %>%
                     dplyr::filter(n() > 2) %>%
                     mutate(delta = vote_share - dplyr::lag(vote_share)) %>%
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

mayor_ncandidates_per_dep <- function(election_results) {
  dist_result <- election_results %>%
                   ncandidates_per_district()
}
