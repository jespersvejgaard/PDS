
#######################################
# PRÆABMEL
#######################################

# LOADER PAKKER
library(tidyverse)


#######################################
# OPGAVE 1
#######################################

# 1. LAV ET OBJEKT MED WHO'S TUBERKULOSE-DATA (TILGÆNGELIGT I TIDYR).
who <- who


# 2. HVAD ER DIMENSIONERNE PÅ DATASÆTTET?
dim(who)  # 7240 observationer og 60 variable 


# 3. ER DATA TIDY?
glimpse(who)  # data er ikke tidy da der er i) redundante kolonner, ii) værdier i kolonnerne


# 4. HVAD ER LOGIKKEN I VARIABEL-NAVNENE FRA `new_sp_m014` til `newrel_f65`? BRUG EVT `?who`
# new = angiver om det er nye eller gamle tilfælde af TB, i datasættet her er kun nye tilfælde 
# sp = type diagnose, her positive pulonary smear 
# m = køn, her mand
# 014 = aldersgruppe, her 0 - 14 år 


# 5. BRUG GATHER() TIL AT SAMLE VÆRDIERNE I KOLONNERNE TIL VARIABLE. KALD DE NYE KOLONNER `key` OG `cases` INDTIL VIDERE. 
who_tidy <- who %>% 
  gather(new_sp_m014:newrel_f65, key = "key", value = "cases")


# 6. LEDENDE SPØRGSMÅL: ER VÆRDIERNE I DIN NYE VARIABEL `kode` KONSISTENTE? RET `newrel` TIL `new_rel`. [hint: `STR_REPLACE()`]
View(count(who_tidy, key))  # vi kan se, at nogle værdier i kolonnen "kode" starter med "newrel", andre med "new_rel". Det er inkonsistent.

who_tidy <- who_tidy %>% 
  mutate(key = str_replace(key, "newrel", "new_rel"))

View(count(who_tidy, key))  # new_rel er nu ændret til new_rel


# 7. BRUG SEPARATE() TIL AT OPDELE VÆRDIERNE I VARIABLEN 'key' SÅ HVER VÆRDI HAR SIN EGEN KOLONNE
who_tidy <- who_tidy %>% 
  separate(key, c("new_old", "type", "sex_age"), sep = "_") %>% 
  separate(sex_age, c("sex", "age"), sep = 1)


# 8. ER DIT DATASÆT TIDY? OG HVAD ER DIMENSIONERNE NU?
glimpse(who_tidy)  # ja, det er tidy: observationerne i rækkerne, variablene i kolonnerne, og værdierne i cellerne.
dim(who_tidy)  # 405440 observationer og 7 variable - vi er altså gået fra et "bredt" til et "langt" datasæt


#######################################
# OPGAVE 2
#######################################

# 1. TIDYR INDEHOLDER OGSÅ DATASÆTTET `population`. TJEK DET UD. HVIS DU VIL JOINE DET PÅ, HVILKE VARIABLE VIL SÅ VÆRE PRIMARY KEYS? OG HVAD BETYDER DET? 
# primary keys er en kolonne eller en kombination af kolonner, som unikt identificerer 
# hver en observation i datasættet. I vores tilfælde vil c("country", "year") være primary keys. 


# 2. JOIN `population` PÅ `who` VIA LEFT_JOIN OG GEM DEN RESULTERENDE DATAFRAME I ET NYT OBJEKT
who_pop <- who_tidy %>% 
  left_join(population, by = c("country", "year"))


# 3. HVILKE LANDE - HVIS NOGEN - FINDER IKKE ET MATCH I DATAFRAMEN `population`?
who_tidy %>% 
  anti_join(population, by = "country") %>% 
  count(country)


# 4. HVILKE(N) VARIABLE INDEHOLDER NA's? GEM ET NYT OBJEKT MED DIT DATASÆT, HVOR DU FILTRERER NAs FRA
summary(who_pop)  # der er NAs på cases og population

who_nona <- who_pop %>% 
  filter(!is.na(who_pop$cases) & !is.na(who_pop$population))


# 5. HVOR MANGE NYE TILFÆLDE AF TB HAR DER VÆRET I ÅRENE 2000 - 2013? KOMMENTER PÅ UDVIKLINGEN
who_nona %>%
  filter(year >= 2000) %>% 
  group_by(year) %>% 
  summarise(cases_tb = sum(cases))  # tiltagende, men måske pga. tiltagende datakvalitet 


# 6. PLOT ANTALLET AF TB-TILFÆLDE FOR HVERT LAND FOR ÅRENE 2000 - 2013. PLOT HVERT LAND VED SIDEN AF HINANDEN [hint: `facet_wrap()`]. HVILKE LANDE SER UD TIL AT DRIVE UDVIKLINGEN FRA SPM. 5?
who_nona %>% 
  filter(year >= 2000) %>% 
  group_by(year, country) %>% 
  summarise(cases_tb = sum(cases)) %>% 
  ggplot(mapping = aes(x = year, y = cases_tb)) + geom_line() + facet_wrap(~ country) + expand_limits(y = 0)
  # det gør de folkerigeste udviklingslande såsom Kina, Indien, Indonesien, Bangladesh, Sydafrika 

who_nona %>% 
  filter(year >= 2000) %>% 
  group_by(year, country) %>%
  filter(country %in% c("India", "China", "Indonesia", "Bangladesh", "South Africa")) %>% 
  summarise(cases_tb = sum(cases)) %>% 
  ggplot(mapping = aes(x = year, y = cases_tb)) + geom_line() + facet_wrap(~ country) + expand_limits(y = 0)
  # måske noget med datakvaliteten i Kina + et udbrud i Indien? 


# 7. LAV EN VARIABEL MED TILFÆLDE AF TB PER 100.000 INDBYGGERE (POPULATION / 100.000), OG PLOT DEN FOR ALLE LANDENE VED SIDEN AF HINANDEN. HVILKE LANDE STIKKER UD NU?
who_nona %>% 
  filter(year >= 2000) %>% 
  mutate(tb_pop = cases/(population / 100000)) %>% 
  group_by(year, country) %>% 
  summarise(tb_pop = sum(tb_pop)) %>% 
  ggplot(mapping = aes(x = year, y = tb_pop)) + geom_line() + facet_wrap(~ country) + expand_limits(y = 0)
  # Botswana, Nordkorea, Lesotho, Marshall-øerne, Namibia, Samoa, Sydafrika, Swaziland, Zimbabwe m.fl. 


#######################################
# Bonus-opgave: 
#######################################

# 1. INDLÆSER DATA FRA WB OM ANDEL AF BNP BRUGT PÅ SUNDHED FOR VERDENS LANDE
wb <- read_csv("/Users/jespersvejgaard/Desktop/Desktop/Akademiet/Political Data Science/PDS under construction/data/API_SH.XPD.PUBL.ZS_DS2_en_csv_v2.csv", skip = 4)


# 2. UNDERSØGER DATASÆTTET - ER DET TIDY?
glimpse(wb)  # ser ud til 1) Indicator Name/Code ikke varierer, 2) Værdier i kolonnerne, 3) variablen `X63`

table(wb$`Indicator Code`)  # ingen variation
table(wb$`Indicator Name`)  # ingen variation

count(wb, `Indicator Code`)  # ingen variation
count(wb, `Indicator Name`)  # ingen variation

summary(wb$X63)
sum(is.na(wb$X63))  # kun NA


# 3. FJERNER `X63`, SAMLER KOLONNER OG KONVERTERER `year` og `health_pct` TIL NUMERIC
wb_tidy <- wb %>%
  select(-X63) %>% 
  gather(`1960`:`2017`, key = "year", value = "health_pct") %>% 
  mutate(year = as.integer(year),
         health_pct = as.numeric(health_pct)) 
  

# 4. FILTRERER `who` FOR ÅRET 2013 OG LAVER EN DATAFRAME MED LANDEKODER (ISO3) OG ANTAL TB-TILFÆLDE PER 100.INDBYGGERE
who_2013 <- who_nona %>% 
  filter(year == 2013) %>% 
  group_by(iso3, population) %>% 
  mutate(tb_pop = cases/(population / 100000)) %>% 
  summarise(tb_pop = sum(tb_pop),
            tb_cases = sum(cases))


# 5. FILTRERER `wb` TIL AT VÆRE ÅRET 2013
wb_2013 <- wb_tidy %>%
  filter(year == 2013)


# 6. JOIN DATA PÅ WHO-DATA
who_wb_2013 <- who_2013 %>% 
  left_join(wb_2013, by = c("iso3" = "Country Code"))


# 7. SER ANTAL TB-TILFÆLDE PER 100.000 INDBYGGERE UD TIL AT KORRELERE MED ANDELEN AF BNP BRUGT PÅ SUNDHED (I ÅRET 2013)? 
ggplot(who_wb_2013, aes(x = health_pct, y = tb_pop)) +
  geom_point()  # ikke rigtigt! 

ggplot(who_wb_2013, aes(x = health_pct, y = tb_pop, color = `Country Name`)) +
  geom_point(aes(size = population)) +
  theme(legend.position = "none") +
  geom_text(data = filter(who_wb_2013, tb_pop > 180), 
            aes(x = health_pct, y = tb_pop, label = iso3), hjust = 1.2)  # næsten samme plot med lidt mere information 



