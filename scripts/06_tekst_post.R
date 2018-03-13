
##################################
# PRÆAMBEL
##################################

# Loader pakker
library(GuardianR)  # key til API fås her: https://bonobo.capi.gutools.co.uk/register/developer
library(rvest)
library(stringr)
library(tidytext)
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(readr)


##################################
# HENTER DATA VIA API
##################################

# Laver request fra The Guardian: Alle artiklen fra hele verden med søgeordene "sexual harassment" fra 1. jan. 2017 - 1. jan. 2018
articles <- get_guardian(keywords = "sexual+harassment",
                         section = "world",
                         from.date = "2013-01-01",  # nyheden om Weinstein kom 5. oktober 2017
                         to.date = "2018-01-01",
                         api.key = "5090d8bc-7f2a-4913-9d34-9da02c4a4f53")

##################################
# PRÆ-PROCESSERING
##################################

# Tjekker dataframen ud 
glimpse(articles)


# Laver datoen om til en dato, body'en til characters og subsetter 
articles_clean <- articles %>% 
  mutate(webPublicationDate = as.Date.factor(articles$webPublicationDate),
         body = as.character(body)) %>% 
  select(webPublicationDate, 
         webUrl,
         body)


# Loop: Laver html-body om til tekst og fjerner ikke-alfanumeriske tegn
for (i in 1:nrow(articles_clean)){
  articles_clean[[3]][i] <- articles_clean[[3]][i] %>% 
    read_html() %>% 
    html_text() %>% 
    str_replace_all("[^a-zA-Z0-9]", " ")  # læses: replace alt undtaget symbolerne a til z, A til Z og 0 til 9. Her fjernes â. Undtaget angives af ^, og [ ] angiver at der er tale om en samling af symboler. Andet eksempel: "[abc]", som betyder replace alt der enten er a, b eller c. Andet eksempel: "[^abc] replace alt undtaget a, b eller c. 
}


# Alternativ via mutate()
# articles_clean <- articles_clean %>% 
#   group_by(webUrl) %>% 
#   mutate(body = body %>% read_html() %>% html_text() %>% str_replace_all("[^a-zA-Z0-9]", " "))


# Splitter artiklerne før/efter Weinstein
articles_before <- articles_clean %>% 
  filter(webPublicationDate < "2017-10-05") %>% 
  select(body)

articles_after <- articles_clean %>% 
  filter(webPublicationDate >= "2017-10-05") %>% 
  select(body)


# Laver bi-grammer
bigrams_before <- articles_before %>% 
  unnest_tokens(bigram, 
                body,
                token = "ngrams",
                n = 2)

bigrams_after <- articles_after %>% 
  unnest_tokens(bigram, 
                body,
                token = "ngrams",
                n = 2)


# Deler bi-grammerne op i to kolonner
bigrams_before <- bigrams_before %>% 
  separate(bigram, c("word_1", "word_2"), sep = " ")

bigrams_after <- bigrams_after %>% 
  separate(bigram, c("word_1", "word_2"), sep = " ")


# Filtrerer bigrammer til at starte med "he" eller "she"
bigrams_before <- bigrams_before %>% 
  filter(word_1 %in% c("he", "she"))

bigrams_after <- bigrams_after %>% 
  filter(word_1 %in% c("he", "she"))


# Retter manglende apostroffer
wordfix <- c("hasn", "hadn", "doesn", "didn", "isn", "wasn", "couldn", "wouldn")

bigrams_before <- bigrams_before %>% 
  mutate(word_2 = ifelse(word_2 %in% wordfix, str_c(word_2, "t"), word_2))

bigrams_after <- bigrams_after %>% 
  mutate(word_2 = ifelse(word_2 %in% wordfix, str_c(word_2, "t"), word_2))


# Beregner word counts og ratioer
he_she_counts_before <- bigrams_before %>%
  count(word_1, word_2) %>%
  spread(word_1, n, fill = 0) %>%
  mutate(total = he + she,
         he = (he + 1) / sum(he + 1),  # lægger 1 til for at kunne beregne ratio
         she = (she + 1) / sum(she + 1),  # lægger 1 til for at kunne beregne ratio
         ratio = she / he,
         log_ratio = log2(she / he),  # beregner log-ratioer, fordi de er symmetriske: log2(10/100) = -log(100/10)
         abs_log_ratio = abs(log_ratio)) %>%
  arrange(desc(log_ratio))

he_she_counts_after <- bigrams_after %>%
  count(word_1, word_2) %>%
  spread(word_1, n, fill = 0) %>%
  mutate(total = he + she,
         he = (he + 1) / sum(he + 1),  # lægger 1 til for at kunne beregne ratio
         she = (she + 1) / sum(she + 1),  # lægger 1 til for at kunne beregne ratio
         ratio = she / he,
         log_ratio = log2(she / he),  # beregner log-ratioer, fordi de er symmetriske: log2(10/100) = -log(100/10)
         abs_log_ratio = abs(log_ratio)) %>%
  arrange((log_ratio))


# Tjekker ordene ud
head(he_she_counts_before)
head(he_she_counts_after)


##################################
# VISUALISERER RESULTATER
##################################

# Plotter - præ-Weinstein
he_she_counts_before %>%
  filter(!word_2 %in% c("himself", "herself", "ever", "quickly", "never",
                       "actually", "sexually", "allegedly", "have", "s"),  # fjerner non-verbs og have manuelt - hvis man er seriøs, så brug en pakke til NLP
         total >= 5) %>%  # fjerner ord hvor n < 5
  group_by(direction = ifelse(log_ratio > 0, 'Mere "hende"', 'Mere "ham"')) %>%
  top_n(15, abs_log_ratio) %>%  # udvælger ord med størst absolut forskel
  ungroup() %>%
  mutate(word_2 = reorder(word_2, log_ratio)) %>%  # sorterer efter log_ratio
  ggplot(aes(word_2, log_ratio, fill = direction)) +
  geom_col() +
  coord_flip() +
  labs(x = "",
       y = 'Relativ forekomst af ord efter "hende" sammenlignet med efter "ham"',
       fill = "",
       title = "Præ-Weinstein: Artikler fra The Guardian om Sexual Harassment",
       subtitle = 'Top 15 mest kønnede verber anvendt efter ordene "she" og "he", med mindst 5 forekomster (2012-2017)') +
  scale_y_continuous(labels = c("4X", "2X", "Samme", "2X", "4X")) +
  guides(fill = guide_legend(reverse = TRUE)) +
  expand_limits(y = c(-4, 4))


# Plotter post-Weinstein
he_she_counts_after %>%
  filter(!word_2 %in% c("himself", "herself", "ever", "quickly", "never", "and", "was", "d", "also",
                        "actually", "sexually", "allegedly", "have", "s"),  # fjerner non-verbs og have manuelt - hvis man er seriøs, så brug en pakke til NLP
         total >= 3) %>%  # fjerner ord hvor n < 5
  group_by(direction = ifelse(log_ratio > 0, 'Mere "hende"', 'Mere "ham"')) %>%
  top_n(15, abs_log_ratio) %>%  # udvælger ord med størst absolut forskel
  ungroup() %>%
  mutate(word_2 = reorder(word_2, log_ratio)) %>%  # sorterer efter log_ratio
  ggplot(aes(word_2, log_ratio, fill = direction)) +
  geom_col() +
  coord_flip() +
  labs(x = "",
       y = 'Relativ forekomst af ord efter "hende" sammenlignet med efter "ham"',
       fill = "",
       title = "Post-Weinstein: Artikler fra The Guardian om Sexual Harassment",
       subtitle = 'Top 15 mest skævt kønnede verber anvendt efter ordnede "she" og "he", med mindst 3 forekomster (fra okt. 2017)') +
  scale_y_continuous(labels = c("4X", "2X", "Samme", "2X", "4X")) +
  guides(fill = guide_legend(reverse = TRUE)) +
  expand_limits(y = c(-4, 4))


# Plotter præ-Weinstein: Kønnede ord inkl. frekvens
he_she_counts_before %>%
  filter(!word_2 %in% c("himself", "herself", "she", "too", "later", "apos", "just", "says"),
         total >= 10) %>%
  top_n(100, abs_log_ratio) %>%
  ggplot(aes(total, log_ratio)) +
  geom_point() +
  geom_vline(xintercept = 5, color = "NA") +
  geom_hline(yintercept = 0, color = "red") +
  scale_x_log10(breaks = c(10, 100, 1000)) +
  geom_text_repel(aes(label = word_2), segment.alpha = .1, force = 2) +
  scale_y_continuous(labels = c('4X "he"', '2X "he"', "Samme", '2X "she"', '4X "she"')) +
  labs(x = 'Antal gange ord forekommer efter "he"/"she" (logaritmisk skala)',
       y = 'Relativ forekomst efter "she" sammenlignet med efter "he"',
       title = "Kønnet journalistik præ Weinstein: Ordbrug i artikler om Sexual Harassment i The Guardian (2012-2017)",
       subtitle = "Top 100 mest kønnede ord vist som er forekommet mindst 10 gange") +
  expand_limits(y = c(4, -4)) +
  theme_minimal()


# Plotter post-Weinstein: Kønnede ord inkl. frekvens
he_she_counts_after %>%
  filter(!word_2 %in% c("himself", "herself", "she", "too", "later", "apos", "just", "says"),
         total >= 3) %>%
  top_n(100, abs_log_ratio) %>%
  ggplot(aes(total, log_ratio)) +
  geom_point() +
  geom_vline(xintercept = 5, color = "NA") +
  geom_hline(yintercept = 0, color = "red") +
  scale_x_log10(breaks = c(10, 100, 1000)) +
  geom_text_repel(aes(label = word_2), segment.alpha = .1, force = 2) +
  scale_y_continuous(labels = c('4X "he"', '2X "he"', "Samme", '2X "she"', '4X "she"')) +
  labs(x = 'Antal gange ord forekommer efter "he"/"she" (logaritmisk skala)',
       y = 'Relativ forekomst efter "she" sammenlignet med efter "he"',
       title = "Kønnet journalistik præ Weinstein: Ordbrug i artikler om Sexual Harassment i The Guardian (2012-2017)",
       subtitle = "Top 100 mest kønnede ord vist som er forekommet mindst 10 gange") +
  expand_limits(y = c(4, -4)) +
  theme_minimal()


##################################
# EKSPORTERER BIGRAMS T. WORKSHOP
##################################

# Laver kolonner med angivelse af kilde
bigrams_before <- mutate(bigrams_before, articles = "before")
bigrams_after <- mutate(bigrams_after, articles = "after")

# Sætter de to dataframes sammen til én
bigrams <- rbind(bigrams_before, bigrams_after)

# Eksporterer bigrams_all til csv 
write_csv(bigrams, "bigrams.csv")



##################################
# SENTIMENT ANALYSIS
##################################

# Laver dataframe med alle bigrams
bigrams <- read_csv("https://raw.githubusercontent.com/jespersvejgaard/PDS/master/data/bigrams.csv")

# Joiner sentiments på bigrams og plotter gennemsnitlige sentiment-scores
bigrams %>% 
  inner_join(get_sentiments("afinn"), by = c("word_2" = "word")) %>% 
  group_by(articles, word_1) %>% 
  summarise(mean_sentiment = mean(score)) %>% 
  ggplot(aes(x = word_1, y = mean_sentiment)) +
  geom_col(aes(fill = articles), position = "dodge") +
  theme_minimal()

  
