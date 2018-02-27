

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

# 1. Eksekvér præamblen ovenfor 
# 2. Skriv en funktion, som tager to vektorer som argumenter, summerer dem og returnerer resultatet. 
# 3. Skriv en funktion, som tager en vektor som argument, og som beregner standardafvigelsen hvis n > 30, og ellers printer "N er under 30!" og afbryder (hint: `break`). Test med vektorerne `x`, `y`, `z` ovenfor.  
# 4. Skriv et for-loop, som looper igennem alle kolonnerne i dataframen `seats` og beregner partiernes gennemsnitlige antal mandater
# 5. Brug `lapply()`, `sapply()`, `vapply()` eller `map_dbl()` til at beregne det samme
# 6. Skriv en funktion, som simulerer et terningekast (hint: `sample()`)
# 7. Skriv et while-loop, som eksekverer funktionen terningekast indtil du har slået 3 seksere i streg. Hvor mange gange skal du slå, for at det sker?  
# 8. Wrap dit while-loop i et for-loop, og slå 3 seksere i streg 100 gange. Hvor mange slags skal du bruge i gennemsnit? 



# 2. Skriv en funktion, som tager to vektorer som argumenter, summerer dem og returnerer resultatet. 
funktion_sum <- function(a, b){
  a + b
}

funktion_sum(45, 15)


# 3. Skriv en funktion, som tager en vektor som argument, og som beregner standardafvigelsen hvis n > 30, og ellers printer "N er under 30!". Test med vektorerne `x`, `y`, `z` ovenfor.  
funktion_sd <- function(vektor){
  if (length(vektor) > 30){
    sd(vektor)
  } else {
  print("N er under 30!")
  }
}
  
funktion_sd(x)
funktion_sd(y)
funktion_sd(z)


# 4. Skriv et for-loop, som looper igennem alle kolonnerne i dataframen `seats` og beregner partiernes gennemsnitlige antal mandater
seats_mean <- vector("double", ncol(seats))

for (i in seq_along(seats)){
  seats_mean[[i]] <- round(mean(seats[[i]], na.rm = T), 1)
}

as.tibble(seats_mean)

# Bonus: Laver seats_mean om til en tibble og kobler den med kolonnenavnene
seats_mean <- as.tibble(seats_mean)  
partier <- as.tibble(names(seats))
cbind(seats_mean, partier)


# 5. Brug `lapply()`, `sapply()`, `vapply()` eller `map_dbl()` til at beregne det samme
lapply(seats, mean, na.rm = TRUE)
sapply(seats, mean, na.rm = TRUE)
vapply(seats, mean, na.rm = TRUE, FUN.VALUE = numeric(1))

map_dbl(seats, mean, na.rm = TRUE)


# 6. Skriv en funktion, som simulerer et terningekast (hint: `sample()`)
terningekast <- function() {sample(1:6, 1)}
terningekast()


# 7. Skriv et while-loop, som eksekverer funktionen terningekast indtil du har slået 3 seksere i streg. Hvor mange gange skal du slå, for at det sker?  

antal_slag <- 0
antal_seksere <- 0

while (antal_seksere < 3) {
  if (terningekast() == 6){
    antal_seksere <- antal_seksere + 1
  } else {
    antal_seksere <- 0
  }
  antal_slag <- antal_slag + 1
}


# 8. Wrap dit while-loop i et for-loop, og slå 3 seksere i streg 100 gange. Hvor mange slags skal du bruge i gennemsnit? 

antal_slag_vektor <- vector("double", 100)

for (i in 1:100){
  antal_slag <- 0
  antal_seksere <- 0
  
  while (antal_seksere < 3) {
    if (terningekast() == 6){
      antal_seksere <- antal_seksere + 1
    } else {
      antal_seksere <- 0
    }
    antal_slag <- antal_slag + 1
  }
  antal_slag_vektor[[i]] <- antal_slag
}

mean(antal_slag_vektor)




