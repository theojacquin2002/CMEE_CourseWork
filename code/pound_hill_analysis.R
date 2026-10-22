# How does mean plant species richness per quadrat vary among the March, May and October 
# cultivation treatments?

ph_data <- as.matrix(read.csv("data/pound_hill_data.csv", colClasses = "character", check.names = FALSE))
ph_metadata <- as.matrix(read.csv("data/pound_hill_metadata.csv", colClasses = "character", check.names = FALSE))

str(ph_data)
str(ph_metadata) # checks dimensions, col types and first few rows of data

ph_data[ph_data == ""] <- 0

ph_data <- t(ph_data)
head(ph_data)
str(ph_data)

headers <- as.character(ph_data[1, ])
ph <- as.data.frame(ph_data[-1, , drop = FALSE])
names(ph) <- headers

ph$Cultivation <- rownames(ph_data)[-1] # Assign row-named Cultivation as a full column
ph <- ph[, c("Cultivation", setdiff(names(ph), "Cultivation"))] # code to put Cultivation as the first column

if (!is.numeric(ph[, -3])) {
  stop("Error: All species columns must containt numerical values.")
}
if (!(all(ph[, -3] >= 0))) {
  stop("Error: All species columns must containt positive values.")
}


id_cols <- c("Cultivation", "Block", "Plot", "Quadrat") # All columns that are not species counts
species_idx <- which(!names(ph) %in% id_cols)
species_names <- names(ph)[species_idx]
rownames(ph) <- NULL # Remove row names to avoid duplicate with Cultivation column
head(ph)

message(paste0("There are ", length(unique(species_names)), " distinct species."))
message(paste0("There are ", length(unique(ph$Plot)), " distinct plots."))
message(paste0("There are ", length(unique(interaction(ph$Cultivation, ph$Plot, ph$Block, ph$Quadrat))), " distinct quadrats."))

quadrat_counts <- ph |>
  # Convert all specified species columns to numeric data types
  mutate(across(all_of(species_names), ~ as.numeric(as.character(.)))) |> 
  group_by(Cultivation, Block, Plot, Quadrat) |> 
  summarise(across(all_of(species_names), sum, na.rm = TRUE), .groups = "drop")


quadrat_richness <- quadrat_counts[, id_cols]
quadrat_richness$Richness <- rowSums(as.matrix(quadrat_counts[, species_names]) > 0)


# Calculate mean richness for each plot
plot_richness <- quadrat_richness |>
  group_by(Cultivation, Block, Plot) |>
  summarise(MeanRichness = mean(Richness), .groups = "drop")

# Confirm there are exactly 12 unique plots
if (nrow(plot_richness) != 12L) {
  stop("Expected 12 plots, but found only ", nrow(plot_richness), " plots.")
}

write.csv(plot_richness, "results/pound_hill_plot_richness.csv")

quadrat_richness
plot_richness

ggplot(plot_richness, aes(Plot, MeanRichness, color = Cultivation)) +
  geom_point(stat = "identity", position = "dodge") +
  labs(title = "Mean Plant Species Richness per Plot by Cultivation Treatment",
       x = "Plot",
       y = "Mean Species Richness") +
  theme_minimal()
