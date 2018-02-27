

######################################################
# PR??AMBEL
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

# Bem??rk: Bliver ae, ao og aa skrevet forkert? S?? klik filer -> reopen with encoding -> v??lg UTF-8 -> s??t flueben i "Set as default..." -> OK

# 1. Eksekv??r pr??amblen ovenfor 
# 2. Skriv en funktion, som tager to vektorer som argumenter, summerer dem og returnerer resultatet. 

 funktion_1 <- function(arg1, arg2, arg3) {
     sum(arg1 + arg2 + arg3)
    }
 funktion_1(x, y, z)


# 3. Skriv en funktion, som tager en vektor som argument, og som beregner standardafvigelsen hvis n > 30, og ellers printer "N er under 30!" og afbryder (hint: `break`). Test med vektorerne `x`, `y`, `z` ovenfor.  
# 4. Skriv et for-loop, som looper igennem alle kolonnerne i dataframen `seats` og beregner partiernes gennemsnitlige antal mandater
# 5. Brug `lapply()`, `sapply()`, `vapply()` eller `map_dbl()` til at beregne det samme
# 6. Skriv en funktion, som simulerer et terningekast (hint: `sample()`)
# 7. Skriv et while-loop, som eksekverer funktionen terningekast indtil du har sl??et 3 seksere i streg. Hvor mange gange skal du sl??, for at det sker?  
# 8. Wrap dit while-loop i et for-loop, og sl?? 3 seksere i streg 100 gange. Hvor mange slags skal du bruge i gennemsnit? 






