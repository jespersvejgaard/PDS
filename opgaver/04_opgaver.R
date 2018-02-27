

######################################################
# PRÆAMBEL
######################################################

# LOADER PAKKER
library(tidyverse)

# DEFINERER VEKTORER TIL OPGAVER
x <- rnorm(10)
y <- rnorm(30)
z <- rnorm(90)

seats <- read_csv("https://raw.githubusercontent.com/jespersvejgaard/PDS/master/data/seats.csv")


######################################################
# OPGAVER
######################################################

# Bemærk: Bliver ae, ao og aa skrevet forkert? Så klik filer -> reopen with encoding -> vælg UTF-8 -> sæt flueben i "Set as default..." -> OK

# 1. Eksekvér præamblen ovenfor 
# Preamble er kørt
# 2. Skriv en funktion, som tager to vektorer som argumenter, summerer dem og returnerer resultatet. 
sum_result <- function(x,y){
  print(x+y)
}
sum_result(5,2)

# 3. Skriv en funktion, som tager en vektor som argument, og som beregner standardafvigelsen hvis n > 30, og ellers printer "N er under 30!" og afbryder (hint: `break`). Test med vektorerne `x`, `y`, `z` ovenfor.  
sd_func <- function(x) {
  if(length(x)<30){
    print("N er under 30!")
    break
  } else {
    print(sd(x))
  }
}

sd_func(x)
sd_func(y)
sd_func(z)

# 4. Skriv et for-loop, som looper igennem alle kolonnerne i dataframen `seats` og beregner partiernes gennemsnitlige antal mandater
glimpse(seats)
seats_1 <- select(seats, 2:20)
seats_vector <- vector("double", ncol(seats_1))
                  
for (parti in seq_along(seats_1)){
  seats_vector[[parti]] <- round(mean(seats_1[[parti]], na.rm = T),2)
}

View(seats_vector)

for (parti in seq_along(seats_1)){
  print(mean(seats_1[[parti]], na.rm = T))
}

cbind(names(seats_1), seats_vector)


# 5. Brug `lapply()`, `sapply()`, `vapply()` eller `map_dbl()` til at beregne det samme
# 6. Skriv en funktion, som simulerer et terningekast (hint: `sample()`)
# 7. Skriv et while-loop, som eksekverer funktionen terningekast indtil du har slået 3 seksere i streg. Hvor mange gange skal du slå, for at det sker?  
# 8. Wrap dit while-loop i et for-loop, og slå 3 seksere i streg 100 gange. Hvor mange slags skal du bruge i gennemsnit? 






