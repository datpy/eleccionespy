library(dplyr)
library(tidyr)

#' Calculates the average change in vote share per district for a particular
#' party.
mayor_delta_voteshare_per_city <- function(election_results, party) {
  if (is.null(party)) {
    stop("party must be specified")
  }

  # Obtains a party's election results per district and year and calculates the
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

#' Calculates the number of candidates in a specific district.
#'
#' It returns two counters:n_candidates:
#' 1) n_candidates is the total number of candidates.
#' 2) n_rel_candidates is the number of candidates that got a share of votes
#' above the threshold.
ncandidates_per_district <- function(election_results, rel_threshold = 5) {
  election_results %>%
    group_by(anio, dep, depdes, disdes, siglas_lista) %>%
    summarise(votos = sum(votos),
              total_votos = sum(total_votos),
              .groups = "drop_last") %>%
    mutate(vote_share = votos / total_votos * 100) %>%
    summarise(n_candidates = n(),
              vote_share = vote_share,
              .groups = "keep") %>%
    filter(vote_share > rel_threshold) %>%
    summarise(n_rel_candidates = n(),
              n_candidates = n_candidates,
              .groups = "keep") %>%
    slice_head()
}

#' Gets the difference in vote share with respect to the other popular party.
diff_voteshare_per_district <- function(election_results, ref_party) {
  # Get the two top parties in an election.
  # Filter those elections in which the ref_party was not among the two top
  # candidates.
  results <- election_results %>%
               group_by(anio, dep, depdes, disdes, siglas_lista) %>%
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

# Aggregates the total number of eligible voters per district.
voters_per_district <- function(electoral_roll) {
  electoral_roll %>%
    group_by(anio, dep, depdes, disdes) %>%
    summarise(eligible_voters = sum(eligible_voters), .groups = "drop")
}

# Aggregates the total number of votes per district.
votes_per_district <- function(election_results) {
  election_results %>%
    group_by(anio, dep, depdes, disdes, zon, loc) %>%
    slice_head() %>%
    group_by(anio, dep, depdes, disdes) %>%
    summarise(total_votos = sum(total_votos),
              .groups = "drop")
}
