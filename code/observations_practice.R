read_observations <- function(path) {
  observations <- read.csv(
    path,
    colClasses = "character",
    na.strings = "",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  required_columns <- c("site", "date", "count")
  if (!identical(names(observations), required_columns)) {
    stop(
      sprintf(
        "%s: expected columns site,date,count in that order.",
        basename(path)
      ),
      call. = FALSE
    )
  }

  for (field in c("site", "date")) {
    missing_value <- is.na(observations[[field]]) |
      trimws(observations[[field]]) == ""

    if (any(missing_value)) {
      row <- which(missing_value)[1]
      stop(
        sprintf(
          "%s: CSV line %d, column '%s': value must not be empty.",
          basename(path), row + 1L, field
        ),
        call. = FALSE
      )
    }
  }

  # Empty counts represent missing observations; validate all other values.
  count_text <- observations$count
  present <- !is.na(count_text)
  valid_count <- grepl("^(0|[1-9][0-9]*)$", count_text[present])

  if (any(!valid_count)) {
    row <- which(present)[which(!valid_count)[1]]
    stop(
      sprintf(
        paste0(
          "%s: CSV line %d, column 'count': found '%s'; expected a blank count or a non-negative integer."
        ),
        basename(path), row + 1L, count_text[row]
      ),
      call. = FALSE
    )
  }

  converted <- suppressWarnings(as.integer(count_text[present]))
  overflow <- is.na(converted)

  if (any(overflow)) {
    row <- which(present)[which(overflow)[1]]
    stop(
      sprintf(
        "%s: CSV line %d, column 'count': value is too large for an R integer.",
        basename(path), row + 1L
      ),
      call. = FALSE
    )
  }

  observations$count <- NA_integer_
  observations$count[present] <- converted
  observations
}


summarise_observations <- function(data) {
  # Remove identical records once, before calculating site totals.
  data <- unique(data)
  sites <- sort(unique(data$site))

  summaries <- lapply(sites, function(site_name) {
    counts <- data$count[data$site == site_name]
    known_counts <- counts[!is.na(counts)]

    total_known <- if (length(known_counts) == 0L) {
      NA_integer_
    } else {
      sum(known_counts)
    }

    data.frame(
      site = site_name,
      total_known = total_known,
      missing_count = sum(is.na(counts)),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, summaries)
}


check_ordinary_summary <- function(summary) {
  stopifnot(identical(summary$site, c("A", "B")))
  stopifnot(identical(summary$total_known, c(2L, 0L)))
  stopifnot(identical(summary$missing_count, c(1L, 0L)))
}


save_known_totals_plot <- function(summary, output_path) {
  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

  known <- !is.na(summary$total_known)
  pdf(output_path)
  on.exit(dev.off(), add = TRUE)

  if (any(known)) {
    barplot(
      summary$total_known[known],
      names.arg = summary$site[known],
      xlab = "Site",
      ylab = "Total known count",
      main = "Known observation totals by site"
    )
  } else {
    plot.new()
    title("Known observation totals by site")
    text(0.5, 0.5, "No sites have known counts")
  }

  all_missing_sites <- summary$site[!known]
  if (length(all_missing_sites) > 0L) {
    mtext(
      paste("All counts missing at site(s):",
            paste(all_missing_sites, collapse = ", ")),
      side = 1,
      line = 4
    )
  }
}


main <- function() {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) > 1L) {
    stop("Usage: Rscript code/observations_practice.R [input.csv]",
         call. = FALSE)
  }

  input_path <- if (length(args) == 1L) {
    args[[1]]
  } else {
    "data/bootcamp_observations.csv"
  }

  observations <- read_observations(input_path)
  summary <- summarise_observations(observations)

  if (basename(input_path) == "bootcamp_observations.csv") {
    check_ordinary_summary(summary)
  }

  print(summary)
  save_known_totals_plot(
    summary,
    "results/observations_known_totals.pdf"
  )
  message("Saved plot to results/observations_known_totals.pdf")
}


if (sys.nframe() == 0L) {
  main()
}
