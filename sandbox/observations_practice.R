read_observations <- function(file_path) {
  observations <- suppressWarnings(
    read.csv(
    file_path,
    colClasses = "character", na.strings = "", check.names = FALSE
  ))
  print(c("The names of the columns are:", paste(colnames(observations), collapse = ", ")))

 if (any(is.na(observations$site))) {
    return("Error: Missing site information in the observations data.")
  }

if (any(is.na(observations$site))) {
    return("Error: Missing date information in the observations data.")
  }

  if (any(!grepl("^(0|[1-9][0-9]*)$", observations$count))) {
    return("Error: Invalid count information in the observations data.")
  } else {
    observations$count <- as.integer(observations$count)
  }

  return(observations)
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Error: You must provide a file path as an argument!", call. = FALSE)
}
input_path <- args[1]

read_observations(input_path)