

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
  # done

# 2. Skriv en funktion, som tager to vektorer som argumenter,
  # summerer dem og returnerer resultatet. 
funktion_sum <- function(a, b) {
  x+y
}

# 3. Skriv en funktion, som tager en vektor som argument, 
  # og som beregner standardafvigelsen hvis n > 30, og ellers printer "N er under 30!" 
  # og afbryder (hint: `break`). Test med vektorerne `x`, `y`, `z` ovenfor.
funktion_sd <- function(c) {
  if (length(c) > 30) {
    sd(c)
  } else {
    print("N er under 30!")
    break
  }
}
funktion_sd(x) # [1] "N er under 30!"
funktion_sd(y) # [1] "N er under 30!"
funktion_sd(z) # [1] 1.021006

# 4. Skriv et for-loop, som looper igennem alle kolonnerne i dataframen `seats` 
  # og beregner partiernes gennemsnitlige antal mandater
seats_avg <- vector("character", ncol((seats)))
  for (i in seq_along(seats)) {
    seats_avg[[i]] <- mean(seats[[i]], na.rm = T)
  }
seats_avg
View(seats_avg)   # hvordan beregner man uden years, other og total?
                  # hvorfor virkede det ikke med "double"?
                  # hvordan skriver man parti pr. kolonne?

# 5. Brug `lapply()`, `sapply()`, `vapply()` eller `map_dbl()` til at beregne det samme
# lapply()
seats %>% 
  select(s:la) %>% 
lapply(mean, na.rm = T) 

# sapply()
seats %>% 
  select(s:la) %>% 
  sapply(mean, na.rm = T) %>% 
  round()

#vapply()
vapply(seats, mean, numeric(1), na.rm = T) %>% 
  round() # hvordan select uden year, other og total?

#map_dbl()
map_dbl(seats, mean, na.rm = T) %>% 
  round()

# 6. Skriv en funktion, som simulerer et terningekast (hint: `sample()`)
funktion_kast <- function(x) {
  sample(x = 1:6, size = 1)
}
funktion_kast()

# 7. Skriv et while-loop, som eksekverer funktionen terningekast 
  # indtil du har slået 3 seksere i streg. Hvor mange gange skal du slå, for at det sker? 

terning_kast <- 0
terning_seks <- 0

while(terning_seks < 3) {
  if (funktion_kast() == 6) {
    terning_seks <- terning_seks + 1
  } else {
    terning_seks <- 0
  }
  terning_kast <- terning_kast + 1
} 
terning_kast # det varierer, skal det det?

# 8. Wrap dit while-loop i et for-loop, og slå 3 seksere i streg 100 gange. 
  # Hvor mange slags skal du bruge i gennemsnit? 

  # laver først tom vektor med en variabel(kolonne) og hundrede rækker til brug i for-loop
antal_slag_vektor <- vector("double", 100)

  # laver en for-loop (hvor jeg putter while-loop indeni)
for(i in 1:100) { # while loop start
  terning_kast <- 0
  terning_seks <- 0

while(terning_seks < 3) {
  if (funktion_kast() == 6) {
    terning_seks <- terning_seks + 1
  } else {
    terning_seks <- 0
  }
  terning_kast <- terning_kast + 1
} # while-loop slut
  antal_slag_vektor[[i]] <- terning_kast
} # for-loop slut
  
mean(antal_slag_vektor) # [1] 323.59 slag i gns for at slå tre seksere i streg
 View(antal_slag_vektor)