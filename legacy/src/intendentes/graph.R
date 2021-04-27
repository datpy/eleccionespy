library(ggpubr)
library(ggrepel)

source("./src/common/graph.R")

# Graphs a scatterplot between vote share (in percentage) and income.
graph_voteshare_vs_income <- function(data, title, xlab, ylab, saved_to) {

  scatter(data, aes(income, vote_share), title, xlab, ylab, saved_to) +
    geom_text_repel(aes(label = depdes), size = 3) +
    stat_cor(method = "pearson", label.x = 3, label.y = 31,
             color = "darkblue") +
    scale_x_continuous(breaks = seq(0, 5, 0.5))  +
    scale_y_continuous(breaks = seq(30, 60, 5),
                       labels = paste0(seq(30, 60, 5), "%"))

  ggsave(saved_to, width = 7, height = 7, dpi = 300)
}

graph_deltashare_vs_income <- function(data, title, xlab, ylab, saved_to) {
  scatter(data, aes(income, avg_delta), title, xlab, ylab, saved_to) +
    geom_text_repel(aes(label = depdes), size = 3) +
    stat_cor(method = "pearson", label.x = 3.5, label.y = -3,
             color = "darkblue") +
    scale_x_continuous(breaks = seq(0, 5, 0.5))  +
    scale_y_continuous(limits = c(-3, 3),
                       breaks = seq(-3, 3, 1),
                       labels = paste0(seq(-3, 3, 1), "%"))

  ggsave(saved_to, width = 7, height = 7, dpi = 300)
}