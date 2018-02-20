#######################################
# PRÆABMEL
#######################################

# LOADER PAKKER
library(tidyverse)


#######################################
# OPGAVE 1
#######################################

# 1. INSTALLER OG LOAD PAKKEN `nycflights13` 
library(nycflights13)


# 2. ER DATASÆTTET TIDY?
View(flights)   # ja: kun én enhed + enheder er i rækkerne + variable i kolonnerne + værdier i cellerne


# 3. HVAD UDGØR EN ENHED?
# enheden er flyafgange 


# 4. HVAD ER DIMENSIONERNE?
glimpse(flights)  # 336.776 x 19, dvs. der er 336.776 observationer og 19 variable 


# 5. DIMENSIONERNE PÅ TO ANDRE MÅDER
str(flights)
dim(flights)


#######################################
# OPGAVE 2
#######################################

# 1. HVORNÅR AFGIK SIDSTE FLY?
arrange(flights, desc(year), desc(month), desc(day), desc(dep_time))


# 2. HVORNÅR AFGIK FØRSTE?
arrange(flights, year, month, day, dep_time)


# 3. HVOR FORSINKET VAR DE 10 MEST FORSINKEDE FLY TILSAMMEN?
arrange(flights, desc(arr_delay)) %>% 
  head(n = 10) %>% 
  summarize(total_delay = sum(arr_delay))


#######################################
# OPGAVE 3
#######################################

# 1. HVORNÅR HAR JEG FØDSELSDAG, OG HVOR MANGE FLY AFGIK DER?
flights %>% filter(month == 12 & day == 20)  # 980 fly, tillyke med det!


# 2. FIND AFGANGE:
flights %>% filter(arr_delay > 120)  # mere end 2 timer forsinkede
flights %>% filter(carrier == "AA" | carrier == "OO")  # blev opereret af AA eller OO
flights %>% filter(month == 12)  # afgik i december
flights %>% filter(dep_delay > 0 & 0 >= arr_delay) # 35.442 afgange

  
# 3. FLY MED MISSING I DEP_TIME
flights %>% filter(is.na(dep_time)) %>% count()  # 8255 har NA i dep_time


#######################################
# OPGAVE 4
#######################################

# 1. LAVER EN DF MED ALLE VAR UNDTAGET TAILNUM
flights_no_tailnum <- flights %>% select(-tailnum)


# 2. LAVER DF MED YEAR, MONTH, DAY, DEP_TIME OG ARR_DELAY
flights_selected <- flights %>% select(year, month, day, dep_time, arr_delay)


# 3. HVAD SKER DER NÅR SELECT(FLIGHTS, CONTAINS("TIME")) EKSEKVERES?
select(flights, contains("TIME"))  # vi får udvalgt alle kolonner hvor "time" indgår i navnet


#######################################
# OPGAVE 5
#######################################

# 1. BRUG DEP_TIME TIL AT LAVE DEP_HOUR OG DEP_MINUTE
flights_edt <- flights %>% 
  mutate(dep_hour = dep_time %/% 100,  # integer division
         dep_minute = dep_time %% 100)  # remainder (modulo)


# 2. LAV EN VARIABEL GAIN, SOM ER DEN INDHENTEDE FORSINKELSE UNDER FLYVNING
flights %>%
  mutate(gain = dep_delay - arr_delay) %>% 
  select(arr_delay, dep_delay, gain)


# 3. LAV EN VARIABEL HOURS SOM ER AIRTIME I MINUTTER
flights %>% 
  mutate(hours = air_time / 60,
         hours = round(hours, 1)) %>% 
  select(air_time, hours)


# 4. LAV EN VARIABEL GAIN_PER_HOUR
flights %>%
  mutate(gain = dep_delay - arr_delay, 
         hours = air_time / 60,
         gain_per_hour = gain / hours,
         gain_per_hour = round(gain_per_hour, 1)) %>% 
  select(gain, hours, gain_per_hour)


# 5. LAV EN VARIABEL GAIN_PER_HOUR I ÉN MUTATE()
flights %>%
  mutate(gain = dep_delay - arr_delay, 
         hours = air_time / 60,
         gain_per_hour = gain / hours,
         gain_per_hour = round(gain_per_hour, 1)) %>% 
  select(gain, hours, gain_per_hour)


# 6. HVAD SKER DER, HVIS MAN BRUGER TRANSMUTE I STEDET? 
flights %>%
  transmute(gain = dep_delay - arr_delay, 
         hours = air_time / 60,
         gain_per_hour = gain / hours,
         gain_per_hour = round(gain_per_hour, 1))  # så beholder vi kun de variable, vi transformerer


#######################################
# OPGAVE 6
#######################################

# 1. HVILKET SELSKAB HAR STØRT FORSINKELSE I GNS?
flights %>% 
  group_by(carrier) %>% 
  summarize(mean_delay = mean(arr_delay, na.rm = T)) %>% 
  arrange(desc(mean_delay))  # det har F9, Frontier Airlines


# 2. HVILKEN MÅNED ER AFGANGSFORSINKELSEN HØJEST?
flights %>% 
  group_by(month) %>% 
  summarize(mean_delay = mean(arr_delay, na.rm = T)) %>% 
  View()


# 3. HVILKE DESTINATIONER KAN MAN FLYVE TIL/FRA MED FLEST FORSKELLIGE SELSKABER?
flights %>% 
  group_by(dest) %>% 
  summarize(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))  # Atlanta, Boston, Charlotte, Chicago, Tampa  


#######################################
# OPGAVE 7
#######################################

# REKONSTRUERER TABELLEN MED GNS ARR_DELAY FORDELT PÅ MÅNEDER
flights %>% 
  group_by(year, month) %>% 
  summarize(delay_mean = mean(arr_delay, na.rm = TRUE), 
            n = n())


#######################################
# OPGAVE 8
#######################################

# REKONSTRUERER FIGUR MED SELSKABERNES GNS. ARR_DELAY
flights_carriers <- flights %>% 
  group_by(carrier) %>% 
  summarise(delay_mean = mean(arr_delay, na.rm = T),
            flights = n())

ggplot(flights_carriers, aes(x = carrier, y = delay_mean, fill = carrier)) +
  geom_col()  # alternativ: geom_bar(stat = "identity")


#######################################
# OPGAVE 9
#######################################

# HVILKE LUFTHAVNE STIKKER UD I PLOTTET DER VISER LUFTHAVNENES GNS. DISTANCE OG GNS. ARR_DELAY?
flights_dest <- flights %>% 
  group_by(dest) %>% 
  summarise(distance_mean = mean(distance, na.rm = T),
            arr_delay_mean = mean(arr_delay, na.rm = T))

ggplot(flights_dest, aes(x = distance_mean, y = arr_delay_mean, color = dest)) +
  geom_point() +
  theme(legend.position = "none") +
  geom_text(aes(label = dest), hjust = 1.5)  # CAE (Columbia) i South Carolina, HNL (Honolulu), LEX (Lexingtong) i Kentucky


#######################################
# OPGAVE 10
#######################################

# REKONSTRUER FIGUR MED GNS. DISTANCE OG GNS. ARR_DELAY FOR FLYSELSKABERNE
flights_carr <- flights %>% 
  group_by(carrier) %>% 
  summarise(distance_mean = mean(distance, na.rm = T),
            arr_delay_mean = mean(arr_delay, na.rm = T),
            n_flights = n())

ggplot(flights_carr, aes(x = distance_mean, y = arr_delay_mean, color = carrier)) +
  geom_point(aes(size = n_flights)) +
  geom_text(aes(label = carrier), hjust=-0.3, vjust=-0.8) +
  theme(legend.position = "none")


#######################################
# OPGAVE 11
#######################################

# LAV ET PLOT, DET KOMMUNIKERER EN NY INDSIGT
flights_ny <- flights %>%
  group_by(hour) %>%
  summarise(dep_delay_mean = mean(dep_delay, na.rm = T),
            arr_delay_mean = mean(arr_delay, na.rm = T))

# PLOTTER DEP_DELAY MOD TIME-TALLET
ggplot(flights_ny, aes(x = hour, y = dep_delay_mean)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = seq(5, 23, 1),
                     limits = c(5, 23))  # fund: forsinkelsen akkumulerer indtil kl. 19
  
# PLOTTER ARR_DELAY MOD TIME-TALLET
ggplot(flights_ny, aes(x = hour, y = arr_delay_mean)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = seq(5, 23, 1),
                     limits = c(5, 23))  # fund: akkumulerer indtil kl. 21








