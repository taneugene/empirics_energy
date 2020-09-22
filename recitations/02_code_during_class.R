# Pseudocode to is_palindrome
library(stringi)
input_t <- 74547 
input_f <- 2338882
x <- input_t
# Function
is_palindrome <- function(x){
  # Change to a character variable
  x <- as.character(x)
  # Split into two
  # We don't need to compare the middle number for the odd case
  # Find the length of numbers
  len <- nchar(x)
  # If odd,
  odd <- as.logical(len%%2)
  if(odd){
    # the first part is up to the middle index (exclusively)
    # slice from the 1st index to floor of length%/%2
    first_part <- substr(x,1,len %/% 2)
    # the second part is from the middle index (exclusively) to the end
    # slice from the middle index + 1 to length of variable
    second_part <- substr(x, len %/% 2 + 2 , len)
  } else {
    # Else the length is even
    first_part <- substr(x,1,len/2)
    second_part <- substr(x,len/2+1,len)
  }
  # Reverse one of the two parts
  reversed <- stri_reverse(second_part)
  # Checking whether the two parts are the same 
  # If they are the same, 
  if (reversed == first_part){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# fizzbuzz exercise
input <- 29
# Iterate from 1 till the input
  # Check if the number is divisible by 5
  # if both 
    # print fizzbuzz
  # else if it's just divisible by 3 
    # print fizz
  # else if it's ust divisible by 5
    # print buzz
  # else
    # print the number

is_palindrome(29992)
is_palindrome(input_f)
