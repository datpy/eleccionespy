library(dplyr)
library(ggplot2)

theme_electionspy <- function() {
  return(
    theme_classic() +
    theme(
      plot.title = element_text(family = "Roboto",
                                size = 14,
                                face = "bold.italic",
                                hjust = 0.5,
                                lineheight = 1.2,
                                margin = margin(10, 0, 30, 0)),
      axis.title.x = element_text(family = "Roboto",
                                  size = 12,
                                  face = "bold",
                                  margin = margin(20, 0, 0, 0)),
      axis.title.y = element_text(family = "Roboto",
                                  size = 12,
                                  face = "bold",
                                  margin = margin(0, 20, 0, 0))
    )
  )
}

scatter <- function(data = NULL, mapping = aes(), title, xlab, ylab, saved_to) {

  ggplot(data, mapping) +
    geom_point(size = 2, shape = 1) +
    labs(title = title, x = xlab, y = ylab) +
    geom_smooth(method = lm, se = FALSE, formula = y ~ x,
                color = "#c63957") +
    theme_electionspy()
}