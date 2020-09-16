fibonacci <- function(n){ # Base case
  if ((n==1)|(n==2)){
    return(1) }
  # Recursive case
  else{
    return(fibonacci(n-1) + fibonacci(n-2))
  }
}

fibonacci(8)
