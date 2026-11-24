#!/usr/bin/env Rscript

# Generalized tree-height calculation.
# Run from the project root:
# Rscript code/get_TreeHeight.R data/trees.csv

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  stop(
    "Error: provide exactly one CSV input path.\n",
    "Usage: Rscript code/get_TreeHeight.R <input.csv>",
    call. = FALSE
  )
}

input_file <- args[[1]]

if (!grepl("\\.csv$", basename(input_file), ignore.case = TRUE)) {
  stop("Error: the input file must have a .csv extension.", call. = FALSE)
}

if (!file.exists(input_file) ||
    dir.exists(input_file) ||
    file.access(input_file, mode = 4) != 0) {
  stop(
    sprintf("Error: input file does not exist or cannot be read: %s", input_file),
    call. = FALSE
  )
}

tree_data <- tryCatch(
  read.csv(
    input_file,
    stringsAsFactors = FALSE,
    colClasses = "character",
    check.names = FALSE
  ),
  error = function(error) {
    stop(
      sprintf("Error: could not read CSV '%s': %s",
              input_file, conditionMessage(error)),
      call. = FALSE
    )
  }
)

required_columns <- c("Species", "Distance.m", "Angle.degrees")

if (!identical(names(tree_data), required_columns)) {
  stop(
    sprintf(
      "Error: expected columns in this order: %s. Found: %s.",
      paste(required_columns, collapse = ", "),
      paste(names(tree_data), collapse = ", ")
    ),
    call. = FALSE
  )
}

distance_m <- suppressWarnings(as.numeric(tree_data$Distance.m))
angle_degrees <- suppressWarnings(as.numeric(tree_data$Angle.degrees))

bad_distance <- which(!is.finite(distance_m))
if (length(bad_distance) > 0) {
  stop(
    sprintf(
      "Error: Distance.m must contain finite numbers. Invalid data row(s): %s.",
      paste(bad_distance, collapse = ", ")
    ),
    call. = FALSE
  )
}

bad_angle <- which(!is.finite(angle_degrees))
if (length(bad_angle) > 0) {
  stop(
    sprintf(
      "Error: Angle.degrees must contain finite numbers. Invalid data row(s): %s.",
      paste(bad_angle, collapse = ", ")
    ),
    call. = FALSE
  )
}

bad_distance_range <- which(distance_m <= 0 | distance_m > 100)
if (length(bad_distance_range) > 0) {
  stop(
    sprintf(
      "Error: Distance.m must be greater than 0 and at most 100. Invalid data row(s): %s.",
      paste(bad_distance_range, collapse = ", ")
    ),
    call. = FALSE
  )
}

bad_angle_range <- which(angle_degrees <= 0 | angle_degrees >= 90)
if (length(bad_angle_range) > 0) {
  stop(
    sprintf(
      "Error: Angle.degrees must be greater than 0 and less than 90. Invalid data row(s): %s.",
      paste(bad_angle_range, collapse = ", ")
    ),
    call. = FALSE
  )
}

# Define the vectorised tree-height function used by this script
TreeHeight <- function(degrees, distance) {
  radians <- degrees * pi / 180
  distance * tan(radians)
}

height_data <- tree_data

# Temporarily uncomment browser() here for the interactive debugging exercise.
# browser()
height_data$height_m <- TreeHeight(
  degrees = angle_degrees,
  distance = distance_m
)

if (!dir.exists("results")) {
  dir.create("results", recursive = TRUE, showWarnings = FALSE)
}
if (!dir.exists("results")) {
  stop("Error: could not create the results directory.", call. = FALSE)
}

input_basename <- basename(input_file)
input_stem <- sub("\\.csv$", "", input_basename, ignore.case = TRUE)
output_file <- file.path(
  "results",
  paste0(input_stem, "_treeheights.csv")
)

write.csv(height_data, output_file, row.names = FALSE)

message(
  sprintf("Saved %d tree-height records to %s",
          nrow(height_data), output_file)
)
