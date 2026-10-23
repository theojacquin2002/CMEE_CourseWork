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

data <- read.csv("data/trees.csv", colClasses = "character", 
    na.strings = "", check.names = FALSE)


#head(data)

required_cols <- c("Species", "Distance.m", "Angle.degrees")
if (!all(required_cols %in% names(data))) {
  stop("Error: The input data must have columns 'Species', 'Distance', and 'Angle'.")
}
x = 1

for (i in data$Distance.m) {
    if (!is.finite(i)) {
        stop(paste0("Error: The 'Distance' column must contain only finite numeric values. Row ", x, " contains a non-finite value."))
    }
    else {
        if (!(0 < i && i < 100)) {
            stop(paste0("Error: The 'Distance' column must contain only values between 0 and 100. Row ", x, " contains a non-numeric value."))
        }
    }
    x = x + 1
}
y = 1
for (i in data$Angle.degrees) {
    if (!is.finite(i)) {
        stop(paste0("Error: The 'Angle' column must contain only finite numeric values. Row ", y, " contains a non-finite value."))
    }
    else {
        if (!(0 < i && i < 90)) {
            stop(paste0("Error: The 'Angle' column must contain only values between 0 and 90. Row ", y, " contains a non-numeric value."))
        }
    }
    y = y + 1
}

TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return(height)
}

height_data <- data
height_data$height_m <- TreeHeight(height_data$Angle.degrees, height_data$Distance.m)
head(height_data)
row.names(height_data) == row.names(data)
# how to check for row order?


write.csv(height_data, "results/TreeHts.csv")
message("Tree heights calculated and saved to 'results/TreeHts.csv'.")


