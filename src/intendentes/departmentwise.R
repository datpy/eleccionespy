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

# Aggregates the total number of votes per district.
votes_per_dep <- function(election_results) {
  election_results %>%
    votes_per_district %>%
    group_by(anio, dep, depdes) %>%
    summarise(total_votos = sum(total_votos),
              .groups = "drop")
}

#' Gets the difference in vote share with respect to the other popular party.
diff_voteshare_per_dep <- function(election_results, ref_party) {
  # Get the two top parties in an election.
  # Filter those elections in which the ref_party was not among the two top
  # candidates.
  results <- election_results %>%
               group_by(anio, dep, depdes, siglas_lista) %>%
               summarise(votos = sum(votos),
                         total_votos = sum(total_votos),
                         .groups = "drop_last") %>%
               top_n(2, votos) %>%
               dplyr::filter(any(siglas_lista == ref_party)) %>%
               mutate(vote_share = votos / total_votos * 100)

  # TODO: Find a better way to place the ref_party at the top of the group
  # Change the siglas_lista of the ref party to "A", so that it can be placed
  # at the top of its group when sorting.
  results <- results %>%
               mutate(siglas_lista = if_else(siglas_lista == ref_party,
                                             "A", siglas_lista)) %>%
               arrange(siglas_lista, .by_group = TRUE)

  # Gets the difference between vote shares among the two top contestants.
  results <- results %>%
    select(-votos, -total_votos) %>%
    summarise(share_diff = dplyr::lag(vote_share) - vote_share,
              .groups = "drop") %>%
    filter(!is.na(share_diff))

  # Create a win variable if the ref_party won the election.
  results %>%
    mutate(win = share_diff > 0)
}