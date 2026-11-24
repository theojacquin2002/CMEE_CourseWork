#!/usr/bin/env Rscript
# This function calculates heights of trees given distance of each tree 
# from its base and angle to its top, using  the trigonometric formula 
#
# height = distance * tan(radians)
#
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
# OUTPUT
# The heights of the tree, same units as "distance"

# Calculate heights from data/trees.csv.
TreeHeight <- function(degrees, distance) {
  radians <- degrees * pi / 180
  distance * tan(radians)
}

input_file <- "data/trees.csv"
required_columns <- c("Species", "Distance.m", "Angle.degrees")

if (!file.exists(input_file) || file.access(input_file, mode = 4) != 0) {
  stop("Error: cannot read data/trees.csv.", call. = FALSE)
}

tree_data <- read.csv(
  input_file,
  stringsAsFactors = FALSE,
  colClasses = "character",
  check.names = FALSE
)

if (!identical(names(tree_data), required_columns)) {
  stop(
    sprintf(
      "Error: expected columns in this order: %s.",
      paste(required_columns, collapse = ", ")
    ),
    call. = FALSE
  )
}

distance_m <- suppressWarnings(as.numeric(tree_data$Distance.m))
angle_degrees <- suppressWarnings(as.numeric(tree_data$Angle.degrees))

if (any(!is.finite(distance_m))) {
  stop("Error: Distance.m must contain only finite numeric values.", call. = FALSE)
}
if (any(!is.finite(angle_degrees))) {
  stop("Error: Angle.degrees must contain only finite numeric values.", call. = FALSE)
}
if (any(distance_m <= 0 | distance_m > 100)) {
  stop("Error: Distance.m must be greater than 0 and at most 100.", call. = FALSE)
}
if (any(angle_degrees <= 0 | angle_degrees >= 90)) {
  stop("Error: Angle.degrees must be greater than 0 and less than 90.", call. = FALSE)
}

height_data <- tree_data
height_data$height_m <- TreeHeight(angle_degrees, distance_m)

if (!dir.exists("results")) {
  dir.create("results", recursive = TRUE, showWarnings = FALSE)
}
if (!dir.exists("results")) {
  stop("Error: could not create the results directory.", call. = FALSE)
}

write.csv(height_data, "results/TreeHts.csv", row.names = FALSE)
message("Saved tree heights to results/TreeHts.csv.")