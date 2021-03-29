library(ggplot2)

theme_electionspy <- function() {
  return(
    theme_classic() +
    theme(
      plot.title = element_text(family = "Roboto",
                                size = 14,
                                face = "bold.italic",
                                hjust = 0.5),
      axis.title.x = element_text(family = "Roboto",
                                  size = 12,
                                  face = "bold",
                                  margin = margin(20, 0, 0, 0)),
      axis.title.y = element_text(family = "Roboto",
                                  size = 12,
                                  face = "bold",
                                  margin = margin(0, 20, 0, 0)),
      axis.line = element_blank()
    )
  )
}