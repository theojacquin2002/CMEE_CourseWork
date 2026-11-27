# Wrangle the Pound Hill dataset with tidyr and dplyr.
# Run from the coursework project root with:
# Rscript code/data_wrang_tidy.R

# Check that the required packages are available.
if (!requireNamespace("tidyr", quietly = TRUE) ||
    !requireNamespace("dplyr", quietly = TRUE)) {
  stop("Install the 'tidyr' and 'dplyr' packages before running this script.")
}

# Read the raw data as text. The first rows describe the sampling design,
# so transpose the table before assigning its column names.
raw_data <- as.matrix(
  read.csv(
    "data/pound_hill_data.csv",
    header = FALSE,
    colClasses = "character",
    na.strings = character(),
    check.names = FALSE
  )
)

# Read the semicolon-separated metadata, as in the starter script.
metadata <- read.csv(
  "data/pound_hill_meta_data.csv",
  header = TRUE,
  sep = ";",
  stringsAsFactors = FALSE
)

cat("Raw data dimensions:", dim(raw_data), "\n")
cat("Metadata dimensions:", dim(metadata), "\n")

transposed_data <- t(raw_data)

# In this dataset, blank species cells mean observed absence, so convert
# blanks to zero. Keep this decision specific to the supplied dataset.
transposed_data[is.na(transposed_data) | transposed_data == ""] <- "0"

# The first transposed row contains the column names.
temp_data <- as.data.frame(
  transposed_data[-1, , drop = FALSE],
  stringsAsFactors = FALSE
)
names(temp_data) <- transposed_data[1, ]
rownames(temp_data) <- NULL

id_columns <- c("Cultivation", "Block", "Plot", "Quadrat")
missing_id_columns <- setdiff(id_columns, names(temp_data))

if (length(missing_id_columns) > 0L) {
  stop(
    "Required identifier column(s) missing: ",
    paste(missing_id_columns, collapse = ", ")
  )
}

cat("Wide data dimensions:", dim(temp_data), "\n")
cat("Wide data columns:", paste(names(temp_data), collapse = ", "), "\n")

# Keep the four identifiers and gather the species columns into rows.
wrangled_data <- temp_data |>
  tidyr::pivot_longer(
    cols = -dplyr::all_of(id_columns),
    names_to = "Species",
    values_to = "Count"
  ) |>
  dplyr::mutate(
    dplyr::across(dplyr::all_of(id_columns), as.factor),
    Count = as.integer(Count)
  )

if (anyNA(wrangled_data$Count)) {
  stop("At least one species count could not be converted to an integer.")
}

cat("Long data dimensions:", dim(wrangled_data), "\n")
str(wrangled_data)
print(head(wrangled_data))

dir.create("results", showWarnings = FALSE)
write.csv(
  wrangled_data,
  "results/pound_hill_long_tidy.csv",
  row.names = FALSE
)

message("Saved results/pound_hill_long_tidy.csv")