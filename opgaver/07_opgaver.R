
####################################################################
## OPGAVE 1: 
####################################################################

## OPGAVE 1.1: Installer/indlæs pakkerne `tidyverse` og `rio`. Kør `install_formats()` hvis R Studio spørger om det.
library("tidyverse")
library("rio")
install_formats() 


####################################################################
## OPGAVE 2: IMPORT OG PRÆPROCESSERING 
####################################################################

## Vi vil undersøge datasættet UNvotes.RData, der der indeholder data om 
## afstemninger i FN's generalforsamling fra 1946 til i dag. Det fulde 
## datasæt er tilgængeligt på Harvards Dataverse: 
## https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/12379 
## En kodebog kan findes på:
## https://dataverse.harvard.edu/file.xhtml?fileId=2699453&version=RELEASED&version=.0


## OPGAVE 2.1: Importér datasættet `UNvotes.RData` fra PDS/data/ på GitHub
votes <- import("https://github.com/jespersvejgaard/PDS/raw/master/data/UNvotes.RData")


## OPGAVE 2.2: Filtrer data, så du kun beholder alle værdier på variablen "vote", som er mindre end eller lig med 3. Gruppér på år og beregn totalt antal afstemninger inden for hvert år (total) og andelen af ja-stemmerne (percent_yes)
votes_year <- votes %>% 
  filter(___) %>% 
  group_by(___) %>% 
  summarise(total = n(),
            percent_yes = mean(vote == 1))

## OPGAVE 2.3: Gør det samme som i 2.2, men gruppér på lande
votes_country <- votes %>% 
  filter(___) %>% 
  group_by(___) %>% 
  summarise(total = n(),
            percent_yes = mean(vote == 1))

## OPGAVE 2.3: Gør det samme som i 2.2, men gruppér på år og lande (lande-år)
votes_year_country <- votes %>% 
  filter(___) %>% 
  group_by(___, ___) %>% 
  summarise(total = n(),
            percent_yes = mean(vote == 1))  


####################################################################
## OPGAVE 3: ANALYSE AF ENIGHED I FN
####################################################################

## OPGAVE 3.1: Hvor stor er enigheden i FN's generalforsamling over tid udtrykt ved andelen, som stemmer ja? Visualisér datasættet votes_year med et lineplot og et scatterplot. 

## OPGAVE 3.1a: Lineplot
ggplot(___, aes(___, ___)) +
  ___()

## OPGAVE 3.1b: Scatterplot + smoothing curve
ggplot(___, aes(___, ___)) +
  ___() + 
  ___()


## OPGAVE 3.2: Hvordan er udviklingen i Storbrittanien? (landekode = GBR)
votes_year_country %>% 
  filter(___) %>% 
  ggplot(aes(___, ___)) +
  ___()


## OPGAVE 3.3: Hvordan er udviklingen i Storbritannien sammenlignet med USA, Frankrig og Indien?
countries <- c("USA", "FRA", "GBR", "IND") 

votes_year_country %>% 
  filter(___ %in% countries) %>% 
  ggplot(aes(___, ___, color = ___)) +
  ___()


## OPGAVE 3.4: Hvordan er udviklingen i Storbritannien sammenlignet med USA, Frankrig, Japan, Brasilien, Kina, Tyskland og Danmark? Visualiser resultatet ved at bruge faceting [hint: facet_wrap() ]
countries <- c("USA", "FRA", "GBR", "IND", "BRA", "JPN", "DEU", "DNK", "CHN")

votes_year_country %>% 
  filter(___ %in% countries) %>% 
  ggplot(aes(___, ___, color = ___)) +
  ___() +
  ___(~ ___, scales = "free_y")


####################################################################
## OPGAVE 4: ENIGHED I FN OG EMNER TIL AFSTEMNING
####################################################################

## OPGAVE 4.1: Importér datasættet `UNvotes_descriptions.RData` fra PDS/data/ på GitHub, der indeholder beskrivelser af afstemningerne i FN's generalforsamling fra 1946 til i dag
descriptions <- ___("https://github.com/jespersvejgaard/PDS/raw/master/data/UNvotes_descriptions.RData")


## OPGAVE 4.2: Tjek data ud
___(descriptions)

## INFO: 
# me: Palestinian conflict
# nu: Nuclear weapons and nuclear material
# di: Arms control and disarmament
# hr: Human rights
# co: Colonialism
# ec: Economic development


## OPGAVE 4.3: Join dataframen descriptions på dataframen votes med et inner join.  
votes_joined <- votes %>% 
  ___(descriptions, by = c("___", "___"))
  

## OPGAVE 4.4: Tjek data ud
___(votes_joined)


## OPGAVE 4.5: Brug et line plot til at visualisere andelen af afstemningerne hvor USA stemmer ja inden for emnet Colonialism
votes_joined %>%
  filter(___ == "USA" & co == 1) %>%
  group_by(year) %>%
  summarise(percent_yes = mean(vote == 1)) %>% 
  ggplot(aes(year, percent_yes)) +
  ___()


## OPGAVE 4.6: Tidying I: Saml kilonnerne om topics (kolonnerne me, nu, di, hr, co, ec) i én kolonne
votes_tidy <- votes_joined %>%
  ___(key = topic, value = has_topic, me:ec)


## OPGAVE 4.7: Tidying II: Filtrer så du kun har kolonnerne, hvor has_topic er 1, og fjern derefter kolonnen has_topic
votes_tidy <- votes_tidy %>% 
  ___(has_topic == 1) %>% 
  ___(-has_topic)


## OPGAVE 4.8: Tidying III: Omdøb topics til deres fulde navne [hint: recode() ]
votes_tidy <- votes_tidy %>%
  mutate(topic = ___(topic,
                        me = "Palestinian conflict",
                        nu = "Nuclear weapons and nuclear material",
                        di = "Arms control and disarmament",
                        hr = "Human rights",
                        co = "Colonialism",
                        ec = "Economic development"))


## OPGAVE 4.9: Lav en dataframe med andelen af ja-stemmer inden for hvert emne inden for hvert land inden for hvert år
votes_country_year_topic <- votes_tidy %>%
  ___(country, year, topic) %>%
  ___(total = n(),
            percent_yes = mean(vote==1)) %>%
  ungroup()


## OPGAVE 4.10: Visualiser andelen som ja-stemmer udgør af USA's stemmer for hvert topic over tid [hint: face_wrap() ]
votes_country_year_topic %>% 
  filter(country == "USA") %>% 
  ggplot(aes(year, percent_yes)) + 
  geom_line() +
  ___(~ ___)


####################################################################
## OPGAVE 5: EKSPLORATIV ANALYSE AF AFSTEMNINGER I FN
####################################################################

## OPGAVE 5: Kommunikér og visualisér en ny indsigt mønstre i afstemningerne i FN





