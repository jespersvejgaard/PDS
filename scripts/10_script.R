

##########################################################################
## OPGAVER 1: INDLÆSNING AF DATA
##########################################################################

## LOADER PAKKER
library(rio)
library(dplyr)
library(ggplot2)
library(pROC)

## INDLÆSER DATA 
valg2015 <- import("https://github.com/jespersvejgaard/PDS/raw/master/data/valg2015.rdata")

# TJEKKER DATA UD (inkl. kodebog)
glimpse(valg2015)


##########################################################################
## OPGAVER 2: TRÆNING- OG TESTSÆT
##########################################################################

## LAVER TRÆNINGS- OG TESTSÆT
set.seed(42)
index <- sample(nrow(valg2015), nrow(valg2015)*0.8)

valg2015_train <- valg2015[index, ]
valg2015_test <- valg2015[-index, ]


##########################################################################
## OPGAVER 3: TRÆNER MODELLER 
##########################################################################

## TRÆNER MODELLER
m_ols <- lm(partivalg ~ ., data = valg2015_train)  # svarer til lm() når vi ikke specificerer argumentet family
m_logit <- glm(partivalg ~ ., data = valg2015_train, family = "binomial")

## TJEKKER RESULTATER
summary(m_ols)  # R^2 er ca. 0.09 = vi indfanger kun begrænset del af variationen i Y
summary(m_logit)  # 1 - deviance/null.deviance er i cirka samme størrelsesorden, hvormed pseudo R^2 er lav


##########################################################################
## OPGAVER 4: TEST MODELLER OG PLOT PRÆDIKTIONER
##########################################################################

## PRÆDIKTERER PARTIVALG
valg2015_test$pred_ols <- predict(m_ols, newdata = valg2015_test) 
valg2015_test$pred_logit <- predict(m_logit, newdata = valg2015_test, type = "response") 

## PLOTTER PRÆDIKTEREDE PARTIVAL MOD FAKTISKE PARTIVALG
ggplot(valg2015_test, aes(pred_ols, partivalg)) + geom_point()  # vi er ikke gode til at adskille y pba. y_hat - varlser lav performance
ggplot(valg2015_test, aes(pred_logit, partivalg)) + geom_point()  # samme 


##########################################################################
## OPGAVER 5: PRÆDIKTIONS-PERFORMANCE: CONFUSION-MATRICE OG ACCURACY 
##########################################################################

## TRANSFORMERER VORES PRÆDIKTEREDE OUTCOME FRA KONTINUERT TIL KATEGORISK VARIABEL
valg2015_test <- valg2015_test %>% mutate(pred_ols_kat = ifelse(pred_ols > mean(pred_ols, na.rm = TRUE), 1, 0))
valg2015_test <- valg2015_test %>% mutate(pred_logit_kat = ifelse(pred_logit > mean(pred_logit, na.rm = TRUE), 1, 0))

## CONFUSION-MATRICER (første argument vises i rækkerne, andet argument vises i kolonnerne)
table(valg2015_test$partivalg, valg2015_test$pred_ols_kat)
table(valg2015_test$partivalg, valg2015_test$pred_logit_kat)  # umiddelbart ser logit-modellen ud til at levere marginalt bedre prædiktioner

## BEREGNER ACCURACY
mean(valg2015_test$partivalg == valg2015_test$pred_ols_kat, na.rm = T)  # 0.587
mean(valg2015_test$partivalg == valg2015_test$pred_logit_kat, na.rm = T)  # 0.615

## SER FORDELINGEN PÅ OUTCOME-VARIABLEN
table(valg2015_test$partivalg)  # 0 = 225 (62,8 %) ; 1 = 133 (37,2 %)

## KOMMENTARER
# 1) Logit-modellen har den højeste accuracy, når tærskelværdien sættes til gennemsnittet på det prædikterede outcome
# 2) Accuracy er lav - vi kunne have fået en højere accuracy (på 62,8 %) ved bare at gætte på y = 0, at ingen stemte venstreorienteret
# 3) Accuracy er ikke et specielt godt mål her, fordi a) det er betinget af tærskelværdien, b) outome-variablen er i nogen grad ubalanceret 


##########################################################################
## OPGAVE 6: PRÆDIKTIONS-PERFORMANCE: ROC-KURVER OG AUC 
##########################################################################

## BEREGNER ROC-KURVER
ROC_ols <- roc(valg2015_test$partivalg, valg2015_test$pred_ols)
ROC_logit <- roc(valg2015_test$partivalg, valg2015_test$pred_logit)

## PLOTTER ROC-KURVER
plot(ROC_ols)
plot(ROC_logit)  # ved øjemål ser de ganske ens ud 

## BEREGNER AUC
auc(ROC_ols)  # 0.6294
auc(ROC_logit)  # 0.6295 - forskellen er ubetydelig 






