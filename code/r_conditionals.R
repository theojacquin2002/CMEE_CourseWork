report_height <- function(height_m, digits = 2) {
  round(height_m, digits = digits)
}

report_height(12.345)             # Returns 12.35
report_height(12.345, digits = 1) # Returns 12.3

# Checks if a number is a power of 2
is.power2 <- function(n) {
  if (log2(n) %% 1==0) {
    return(paste(n, 'is a power of 2!'))
  } else {
  return(paste(n,'is not a power of 2!'))
    }
}

is.power2(4)

# Checks if a number is prime
is.prime <- function(n) {
  if (n==0) {
    return(paste(n,'is a zero!'))
  } else if (n==1) {
    return(paste(n,'is just a unit!'))
  }
    
  ints <- 2:(n-1)
  
  if (all(n%%ints!=0)) {
    return(paste(n,'is a prime!'))
  } else {
  return(paste(n,'is a composite!'))
    }
}

is.prime(3)