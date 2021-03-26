
#' Calculates the general perfomance of the ANR in the mayor elections for each
#' year available in the dataset.
#'
#' This functions expects that the results dataframe only corresponds to the
#' election of mayors.
general_performance_mayors <- function(results) {
    election_results <- results

    # Calculates the total number of votes casted in favor of each party in each
    # election.
    votes_per_party <- aggregate(votos~anio + siglas_lista,
                                election_results,
                                sum)

    # Sort votes by year (asc) and number of votes (des), so as to make it
    # easier to get the top parties in each election year.
    votes_per_party <- votes_per_party[order(votes_per_party$anio,
                                            -votes_per_party$votos), ]

    # Fitlers the top 2 parties for each election year.
    # ' most_voted_parties <- by(votes_per_party,
    #'                         votes_per_party["anio"],
    #'                         head,
    #'                         n = 2)
    #' most_voted_parties <- Reduce(rbind, most_voted_parties)

    #' print(head(most_voted_parties))
    #' print(nrow(most_voted_parties))

    # The 1996 election didn't separate vote count for each zone and location.
    # The data was about an entire district, so the dataset has NA values for
    # loc and zon.
    #
    # If these values are not set, results for 1996 are not included in
    # aggregation. Set them to 0 for analysis purposes.
    election_results[is.na(election_results$loc), ]$loc <- 0
    election_results[is.na(election_results$zon), ]$zon <- 0


    # Calculates the total number of votes casted in each election.
    total_votes <- aggregate(total_votos~anio + disdes + zon + loc,
                                    election_results, head, 1)
    total_votes <- aggregate(total_votos~anio, total_votes, sum)

    # Calculates the ANR general performance over the years.
    anr_votes <- votes_per_party[votes_per_party$siglas_lista == "ANR", ]
    anr_votes$total_votos <- total_votes$total_votos
    anr_votes$vote_share <- anr_votes$votos / total_votes$total_votos

    print(anr_votes)
}
