library(ggpubr)
library(ggrepel)

source("./src/common/graph.R")

# Graphs a scatterplot between vote share (in percentage) and income.
graph_voteshare_vs_income <- function(data, title, xlab, ylab, saved_to) {

  ggplot(data, aes(income, vote_share)) +
    geom_point(size = 2, shape = 1) +
    geom_text_repel(aes(label = depdes), size = 3) +
    geom_smooth(method = lm, se = FALSE, formula = y ~ x,
                color = "#c63957") +
    stat_cor(method = "pearson", label.x = 3, label.y = 31,
             color = "darkblue") +
    ggtitle(title) +
    scale_x_continuous(name = xlab,
                       breaks = seq(0, 5, 0.5))  +
    scale_y_continuous(name = ylab,
                       breaks = seq(30, 60, 5),
                       labels = paste0(seq(30, 60, 5), "%")) +
    theme_electionspy()

  ggsave(saved_to, width = 7, height = 7, dpi = 300)
}