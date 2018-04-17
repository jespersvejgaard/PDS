
###########################################
## CHALLENGE
###########################################

## LOADER PAKKER (skal installeres, hvis de ikke allerede er det)
library(rio)
library(dplyr)
library(caret)
library(pROC)


## IMPORTERER DATA
valg2015_train <- import("https://github.com/jespersvejgaard/PDS/raw/master/data/valg2015_train.rdata")
valg2015_test <- import("https://github.com/jespersvejgaard/PDS/raw/master/data/valg2015_test.rdata") 


## KODEBOG
## Find kodebogen på GitHub! 


###########################################
## PRÆPROCESSERING
###########################################

## ANTAL CELLER MED MISSING DATA I DATASÆTTET
sum(is.na(valg2015_train))  # 4634 celler


## MEDIAN IMPUTATION
preprocess_scheme <- preProcess(
  x = valg2015_train,
  method = c("medianImpute")
)

valg2015_train <- predict(preprocess_scheme, valg2015_train)  

## ANTAL CELLER MED MISSING DATA I DATASÆTTET NU
sum(is.na(valg2015_train))  # 0 celler 


###########################################
## DEFINERER CONTROLS
###########################################

## LAVER FOLDS
set.seed(42)  # sætter seed mulighed for at kunne replicere senere 
folds <- createFolds(valg2015_train$stemte_roedt, k = 5)  # laver 5-fold CV


## DEFINERER CONTROLS
controls <- trainControl(
  method = "cv",                      # angiver vi vil lave CV - der findes også andre muligheder såsom "repeatedcv"
  number = 5,                         # angiver her at vi vil lave 5-fold CV
  #repeats = 5,                       # dette argument kun relevant hvis vi ikke laver "cv", men "repeatedcv" 
  summaryFunction = twoClassSummary,  # bestemmer hvilket performancemål, som beregnes, her sens, spec og ROC
  classProbs = TRUE,                  # angiver om vi vil have beregnes sandsynligheder for, at en obs. tilhører en bestemt klasse - det vil vi som regel gerne ved klassifikationsproblemer 
  verboseIter = TRUE,                 # angiver om vi vil have printet en training log så vi fx kan følge med i vores CV
  index = folds                       # argumentet bruges til at definere nogle bestemte folds, dem vi lavere ovenfor, hvilket er en god idé når vi vil sammenligne modeller
)


###########################################
## TRÆNER OG TUNER MODEL 
###########################################

## LOGIT-MODEL
m_glm <- train(
  stemte_roedt ~ .,                                              # modellens formula
  data = valg2015_train,                                         # datasættet 
  metric = "ROC",                                                # performancemål, som skal optimeres 
  method = "glm",                                                # algoritme, her glm (logit-model) 
  trControl = controls                                           # sætter controls for træningen 
)

## KLASSIFIKATIONSTRÆ
m_tree <- train(
  stemte_roedt ~ .,                                              # modellens formula
  data = valg2015_train,                                         # datasættet 
  metric = "ROC",                                                # performancemål, som skal optimeres 
  method = "rpart",                                              # algoritme, her et klassifikationstræ
  trControl = controls,                                          # sætter controls for træningen 
  tuneGrid = expand.grid(cp = 10^(seq(-3, 0, length = 40)))      # definerer grid af parameter-værdier til tuning, her afprøver 40 værdier i intervallet cp = 0.001 til cp = 1
)


###########################################
## CHALLENGE: TRÆN FLERE MODELLER
###########################################

## Fx glmnet (rdige/lasso), ranger (RF), xgbTree (gradient boosted trees), nnet (neuralt netværk)
## ... 


## TIP: TJEK TUNINGSPARAMETRE 
modelLookup(model = "xgbTree")





###########################################
## EVALUERING AF MODEL 
###########################################

## RESULTAT AF TRÆNING
m_glm
m_tree


## MODELLENS MAKSIMALE ROC (AUC)
max(m_glm$results$ROC)
max(m_tree$results$ROC)


## PLOTTER MODELLENS PERFORMANCE PÅ TVÆR AF VÆRDIER I TUNING GRID
plot(m_tree)


## SAMMENLIGNING AF MODELLER
model_list <- list(glm = m_glm, tree = m_tree)  # flere modeller kan tilføjes til listen
resamples <- resamples(model_list)

summary(resamples)  # outputter tabel med modellernes performance
dotplot(resamples, metric = "ROC")  # plotter modellernes performance og usikkerheden ifm. deres performance 




###########################################
###########################################
## BONUS: PERFORMANCE I TESTSÆTTET   
###########################################
###########################################

###########################################
## PERFORMANCE I TESTSÆTTET 1: ACCURACY  
###########################################

## PRÆDIKTERER OUTCOMES
valg2015_test$pred_glm <- predict.train(object = m_glm, valg2015_test, type = "raw")  # bemærk: type = "raw" for faktiske outcomes, dvs y er enten "Ja" eller "Nej"
valg2015_test$pred_tree <- predict.train(object = m_tree, valg2015_test, type = "raw")

## BEREGNER CONFUSION MATRIX
confusionMatrix(data = valg2015_test$pred_glm, reference = valg2015_test$stemte_roedt)
confusionMatrix(data = valg2015_test$pred_tree, reference = valg2015_test$stemte_roedt)


###########################################
## PERFORMANCE I TESTSÆTTET 2: AUC  
###########################################

## PRÆDIKTERER OUTCOMES 
pred_glm_prob <- predict.train(object = m_glm, valg2015_test, type = "prob")  # bemærk: type = "prob" for at forudsige en sandsynlighed ml. 0 og 1 for at y = 1
pred_tree_prob <- predict.train(object = m_tree, valg2015_test, type = "prob")


## LAVER ROC-OBJEKTER FOR MODELLERNE
ROC_glm <- roc(valg2015_test$stemte_roedt, pred_glm_prob$Ja) 
ROC_tree <- roc(valg2015_test$stemte_roedt, pred_tree_prob$Ja) 


## PLOTTER ROC-KURVER
plot(ROC_glm)
plot(ROC_tree)


## BEREGNER AUC
auc(ROC_glm)
auc(ROC_tree)


###########################################
###########################################


