# LOADER PAKKER
library(tidyverse)

# DEFINERER VEKTORER TIL OPGAVER
x <- rnorm(10)
y <- rnorm(30)
z <- rnorm(90)

seats <- read_csv("https://raw.githubusercontent.com/jespersvejgaard/PDS/master/data/seats.csv")

#1. Eksekver ovenståede

# 2. Skriv en funktion, som tager to vektorer som argumenter, summerer dem og returnerer resultatet.
sum_two_vectors <- function(x, y) {
  x + y
}
sum_two_vectors(x,y) 

# 3. Skriv en funktion, som tager en vektor som argument, og som beregner standardafvigelsen hvis n > 30, 
#og ellers printer "N er under 30!" og afbryder (hint: `break`). 
#Test med vektorerne `x`, `y`, `z` ovenfor. 
sd_conditional <- function(x) {
  sd_resultat <- sd(x) 
  if (sd_resultat<30) {
  print("X er under 30!") 
    break
    }
} 
sd_conditional(x)
sd_conditional(y)
sd_conditional(z)

# 4. Skriv et for-loop, som looper igennem alle kolonnerne i dataframen `seats` og beregner partiernes gennemsnitlige antal mandater
avg_mandates <- vector("double", ncol(seats))
for (i in seq_along(seats)) {
  avg_mandates[[i]] <- mean(seats[[i]], na.rm=TRUE)
}
avg_mandates

# 5. Brug `lapply()`, `sapply()`, `vapply()` eller `map_dbl()` til at beregne det samme
map_dbl(seats, mean, na.rm=TRUE)

# 6. Skriv en funktion, som simulerer et terningekast (hint: `sample()`)
dice <- function(nsides, nrolls, ndice) {
  t(replicate(nrolls, sample(1:nsides, ndice, replace = TRUE)))
}
dice(6, 10, 1) #6 sidet-terning, vi ruller 10 gange med 1 terning. 

#eller
throw_dice <- function() {
  number <- sample(1:6, size = 1)
  number 
}

throw_dice()

# 7. Skriv et while-loop, som eksekverer funktionen terningekast indtil du har slået 3 
#seksere i streg. Hvor mange gange skal du slå, for at det sker?  


# 8. Wrap dit while-loop i et for-loop, og slå 3 seksere i streg 100 gange. Hvor mange slag skal du bruge i gennemsnit? 



