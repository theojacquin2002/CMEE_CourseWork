# How does mean plant species richness per quadrat vary among the March, May and October 
# cultivation treatments?

library(tidyverse)
library(ggplot2)
library(dplyr)

ph_data <- as.matrix(read.csv("data/pound_hill_data.csv", colClasses = "character", check.names = FALSE))
ph_metadata <- read.csv2("data/pound_hill_meta_data.csv", colClasses = "character", check.names = FALSE)

str(ph_data)
str(ph_metadata) # checks dimensions, col types and first few rows of data

ph_data[ph_data == ""] <- 0

ph_data <- t(ph_data)
head(ph_data)
str(ph_data)

headers <- as.character(ph_data[1, ]) # only way I found to turn first row as header
ph <- as.data.frame(ph_data[-1, , drop = FALSE])
names(ph) <- headers

names(ph) <- trimws(names(ph))
ph$Cultivation <- rownames(ph_data)[-1]
ph <- ph[, c("Cultivation", setdiff(names(ph), "Cultivation"))]
rownames(ph) <- NULL

id_cols <- c("Cultivation", "Block", "Plot", "Quadrat")
ph[id_cols] <- lapply(ph[id_cols], trimws)
species_names <- setdiff(names(ph), id_cols)

ph[species_names] <- lapply(ph[species_names], function(x) {
  x <- trimws(as.character(x))
  x[is.na(x) | x == ""] <- "0"
  suppressWarnings(as.numeric(x))
})

counts <- as.matrix(ph[species_names])
if (anyNA(counts) || any(!is.finite(counts)) || any(counts < 0)) {
  stop("Species counts must be numeric, finite, and non-negative.")
}

message("Distinct species: ", length(species_names))
message("Distinct plots: ", nrow(unique(ph[c("Cultivation", "Block", "Plot")])))
message("Distinct quadrats: ", nrow(unique(ph[id_cols])))

quadrat_counts <- ph |>
  group_by(Cultivation, Block, Plot, Quadrat) |>
  summarise(
    across(all_of(species_names), ~ sum(.x)),
    .groups = "drop"
  )

quadrat_richness <- quadrat_counts[, id_cols, drop = FALSE]
quadrat_richness$Richness <-
  rowSums(as.matrix(quadrat_counts[, species_names, drop = FALSE]) > 0)

plot_richness <- quadrat_richness |>
  group_by(Cultivation, Block, Plot) |>
  summarise(MeanRichness = mean(Richness), .groups = "drop")

dir.create("results", showWarnings = FALSE)
write.csv(plot_richness, "results/pound_hill_plot_richness.csv", row.names = FALSE)
quadrat_richness
plot_richness

ggplot(plot_richness, aes(x = Plot, y = MeanRichness, colour = Cultivation)) +
  geom_point(size = 3) +
  labs(
    title = "Mean plant species richness per plot",
    x = "Plot",
    y = "Mean species richness"
  ) +
  theme_minimal()
