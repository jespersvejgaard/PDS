
######################################################
# OPGAVER
######################################################

# 1. Lav en vektor med årstallene 2007, 2011, 2015 [`x <- c(...)`]
# 2. Lav en vektor med LA's mandater i de 3 valgår, henholdsvis 5, 9, 13
# 3. Kombiner de to vektorer til en dataframe [`data.frame()`]
# 4. Hvor mange mandater fik LA i gennemsnit ved de tre valg? [`mean()`]
# 5. Hvilket directory arbejder du fra? [`getwd()`]
# 6. Ændr dit directory til selvvalgt directory [`setwd()`]
# 7. Installér og load pakken "tidyverse"
# 8. Indlæs datasættet `seats.csv` fra https://raw.githubusercontent.com/jespersvejgaard/PDS/master/data/seats.csv
# 9. Hvor mange observationer er der i datasættet? Hvor mange variable?
# 10. Hvilke år dækker datasættet?
# 11. Hvor mange stemmer har S fået i gennemsnit?
# 12. Hvad med DF? ... Hvorfor virker `mean()` ikke? [`mean(... , na.rm = TRUE)`]
# 13. Hvor stor en andel af mandaterne har RV fået ved valgene?
# 14. Hvad er standardafvigelsen i K's antal mandater?
# 15. Hvilke år har K fået flere end 30 mandater?


# 1. LAVER VEKTOR MED ÅRSTAL
år <- c(2007, 2011, 2015)


# 2. LAVER VEKTOR MED LA'S MANDATER
LA <- c(5, 7, 13)


# 3. KOMBINERER VEKTORER TIL DF
mandater_LA <- data.frame(år, LA) 


# 4. FINDER GENNEMSNITTET PÅ VARIABLEN MED MANDATER
mean(mandater_LA$LA)


# 5. UNDERSØGER DIRECTORY
getwd()


# 6. SÆTTER DIRECTORY
#setwd("/Users/.../.../")


# 7. INSTALLERER & LOADER PAKKEN TIDYVERSE 
#install.packages("tidyverse")
library(tidyverse)


# 8. DEFINERER STI TIL DATA & LOADER DATA
sti <- "https://raw.githubusercontent.com/jespersvejgaard/PDS/master/data/seats.csv"
seats <- read_csv(sti)


# 9. ANTAL OBSERVATIONER & VARIABLE I DATASÆTTER
View(seats)  # 23 observationer og 22 variable 
glimpse(seats)


# 10. HVILKE ÅR DÆKKER DATASÆTTET
View(seats) 
seats$year
summary(seats$year)  # 1953 - 2015


# 11. GNS. STEMMER TIL S
mean(seats$s)  # 60,1


# 12. GNS. STEMMER TIL DF
mean(seats$df)  # duer ikke pga. NAs
mean(seats$df, na.rm = TRUE)  # 23,8


# 13. ANDEL AF MANDATERNE RV HAR FÅET
seats$RV_andel <- round(((seats$rv / seats$total) * 100), 1)
seats$RV_andel

ggplot(data = seats, aes(x = year, y = RV_andel)) +
  geom_col()  # viser fordelingen af RV_andel over år


# 14. STANDARDAFVIGELSE I K'S MANDATER
sd(seats$k)  # = 10,4

seats$k_afvigelse_kvd <- (seats$k - mean(seats$k))^2
sqrt(sum(seats$k_afvigelse_kvd) / (length(seats$k_afvigelse_kvd) - 1))  # = 10,4


# 15. ÅR HVOR K HAR FÅET FLERE END 30 MANDATER
mandater_k_over30 <- seats$k > 30
mandater_k_over30

seats$year[mandater_k_over30]  # 1960 1964 1966 1968 1971 1984 1987 1988



