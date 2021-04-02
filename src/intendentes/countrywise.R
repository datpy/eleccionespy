#' Calculates the general perfomance of the ANR in the mayor elections for each
#' year available in the dataset.
#'
#' This functions expects that the results dataframe only corresponds to the
#' election of mayors.
mayor_general_performance <- function(election_results, party) {

  if (is.null(party)) {
    stop("party must be specified")
  }

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
  votes_per_party %>%
    dplyr::filter(siglas_lista == party) %>%
    mutate(total_votos = total_votes$total_votos,
          vote_share = votos / total_votes$total_votos)
}

#' Runs yearly pairwise comparisons of the mean of vote shares per district.
#'
#' This functions expects that the results dataframe only corresponds to the
#' election of mayors.
mayor_pwc_voteshare_per_year <- function(election_results, party) {
  if (is.null(party)) {
    stop("party must be specified")
  }

  votes_per_party <- election_results %>%
                       group_by(anio, disdes, siglas_lista) %>%
                       summarise(votos = sum(votos),
                                 total_votos = sum(total_votos),
                                 .groups = "drop") %>%
                       mutate(vote_share = votos / total_votos)

  party_results <- votes_per_party %>%
                     dplyr::filter(siglas_lista == party, !is.na(vote_share))

  # Pairwise comparisons over the years.
  party_results %>%
    tukey_hsd(vote_share ~ as.factor(anio))
}
