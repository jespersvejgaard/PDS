
###########################################
## OPGAVE 1
###########################################

## 1.1: LOADER PAKKER (skal installeres, hvis de ikke allerede er det)
library(rio)
library(dplyr)
library(ggplot2)
library(purrr)


## 1.2: IMPORTERER DATA
holdninger <- import("https://github.com/jespersvejgaard/PDS/raw/master/data/holdninger.rdata")
partivalg <- import("https://github.com/jespersvejgaard/PDS/raw/master/data/partivalg.rdata")


###########################################
## OPGAVE 2: PCA
###########################################

## 2.1: UNDERSØGER DATA
map(holdninger, mean)  # variablenes gns. er ca. det samme
map(holdninger, sd)  # variablenes standard deviation er ogs ca. det samme => skalering ikke strengt nødvendigt, men skader ikke og er fint for at sikre maksimal sammenlignelighed


## 2.2: BEREGNER PRINCIPAL COMPONENTS
holdninger_pca <- prcomp(holdninger, center = TRUE, scale = TRUE)  # vi centrerer og skalerer 


## 2.2: HVAD BESTÅR OUTPUTTET AF?
names(holdninger_pca)


## 2.2: TJEKKER OUTPUTTETS ELEMENTER UD
holdninger_pca$sdev       # SD for hver PC
holdninger_pca$rotation   # variablenes loadings på hver PC (dvs. PC'ernes loadings vector)
holdninger_pca$center     # variablenes center før centrering
holdninger_pca$scale      # variablenes SD før skalering 
holdninger_pca$x          # hver PC's principal component score vector (denne svarer til at gange det oprindelige data med PC'ernes loading vectors) 


## 2.3: BIPLOTS: PLOTTING AF DE FØRSTE TO PCs
biplot(holdninger_pca, scale = 0) # scale = 0 sørger for at pilene er skaleret til at vise loadings
                                  # biplottet pile viser variablenes loaders på hver PC. Positiv holdning til lighed
                                  # og grøn politik loader højt og positivt på den første PC, mens positiv holdning
                                  # til strengere straffe og færre flygtninge loader højt og negativt. Det tyder på, at PC'en
                                  # opfanger en værdidimension i dansk politik. Den anden PC er primært drevet at holdningen til EU
                                  # og globalisering, sekundært af noget det kan minde om fordelingspolitik i form af størrelsen
                                  # på den offentlige sektor samt holdningen til lighed. 


## 2.4: VARIANCE EXPLAINED: BEREGNING AF VARIANS OG VARIANS EXPLAINED
(holdninger_pca_var <- holdninger_pca$sdev^2)  # variansen for hver PC
(holdninger_pca_PVE <- holdninger_pca$sdev^2/sum(holdninger_pca$sdev^2))  # pve, percentage variance explained for hver PC
(holdninger_pca_CVE <- cumsum(holdninger_pca$sdev^2/sum(holdninger_pca$sdev^2)))  # kumulativ variance explained
summary(holdninger_pca)  # beregner også PVE og CVE, det er dog sværere at selecte elementerne her


## 2.4: VARIANCE EXPLAINED: VISUALISERET
plot(holdninger_pca_PVE, xlab="Principal Component", ylab="Proportion of Variance Explained ", ylim = c(0,1),type = "b")
plot(holdninger_pca_CVE, xlab="Principal Component ", ylab=" Cumulative Proportion of Variance Explained ", ylim = c(0,1), type = "b")


## 2.5: LAVER DATAFRAME DER KOBLER PCA SCORES OG PARTIVALG
holdninger_df <- data.frame(holdninger_pca$x,
                            partivalg)


## 2.6: SAMMENLIGNING AF PCA-SCORES OG FAKTISK PARTIVALG
ggplot(holdninger_df, aes(x = PC1, y = PC2)) +
  geom_point(aes(color = partivalg), alpha = 0.5) +
  facet_wrap(~ partivalg) +
  ylim(-4, 4) +
  xlim(-5, 5)


## 2.6: SAMMENLIGNING AF PCA SCORES OG OM VALGTE PARTI ER RØD/BLÅ BLOK
ggplot(holdninger_df, aes(x = PC1, y = PC2)) +
  geom_point(aes(color = partivalg_blok), alpha = 0.5) +
  ylim(-4, 4) +
  xlim(-5, 5)


###########################################
## OPGAVE 3: K-MEANS
###########################################

## 3.1: NORMALISERING AF DATA
holdninger_scaled <- scale(holdninger) %>% as.data.frame()


## 3.2: TJEKKER GNS OG SD UD - DE ER NU CENTRERET OG SKALERET
map(holdninger_scaled, mean)  # de er 0 (nærmest)
map(holdninger_scaled, sd)  # de er 1 


## 3.3: K-MEANS CLUSTERING PBA DATAFRAMEN MED PRINCIPAL COMPONENTS
set.seed(42)
holdninger_km <- kmeans(holdninger_scaled, centers = 2, nstart = 50)  # kører algoritmen 50 gange og returnerer resultatet med den laveste within sum of squares 


## 3.3: TJEK CLUSTER ASSIGNMENT UD
holdninger_km$cluster  # alle obs. er nu tilskrevet et cluster


## 3.4: LAVER DATAFRAME MED PCA, PARTIVALG OG CLUSTER ASSIGNMENTS (MHP AT KUNNE PLOTTE DEM SAMMEN)
holdninger_df <- data.frame(holdninger_pca$x,
                            partivalg,
                            cluster_km = holdninger_km$cluster)

## 3.5: PLOTTER RESPONDENTERS PCA-SCORES OG VÆLGER SHAPE TIL AT AFSPEJLER CLUSTERS 
ggplot(holdninger_df, aes(x = PC1, y = PC2)) +
  geom_point(aes(shape = as.factor(cluster_km)), alpha = 0.5)

## 3.5: PLOTTER RESPONDENTERS PCA-SCORES, SHAPE AFSPEJLER CLUSTER, COLOR AFSPEJLER OM PARTIVALG ER BLÅ/RØD 
ggplot(holdninger_df, aes(x = PC1, y = PC2)) +
  geom_point(aes(color = partivalg_blok, shape = as.factor(cluster_km)))


###########################################
## BONUS-OPGAVE: HIERARKISK CLUSTERING
###########################################

## B.1: LAVER HIERARKISK CLUSTERING MED 3 TYPER LINKAGE
holdninger_hc_com <- hclust(dist(holdninger_scaled), method = "complete")
holdninger_hc_avg <- hclust(dist(holdninger_scaled), method = "average")
holdninger_hc_sin <- hclust(dist(holdninger_scaled), method = "single")

## B.2: PLOTTER DE TRE CLUSTERINGS
# par(mfrow = c(1, 3))  # med denne vises de tre plots ved siden af hinanden
plot(holdninger_hc_com, main="Complete Linkage", xlab="", sub="", cex =.9)
plot(holdninger_hc_avg, main="Average Linkage", xlab="", sub="", cex =.9)
plot(holdninger_hc_sin, main="Single Linkage", xlab="", sub="", cex =.9)

## B.3: CUTTER TRÆ SÅ VI FÅR 2 CLUSTERS 
cluster_hc <- cutree(holdninger_hc_com, 2)  # ved at specificere argumentet h kan vi cutte pba en højde 

## B.3: LAVER DF HVOR VI KOMBINERER RESULTATER FRA PCA, KM OG HC
holdninger_df <- data.frame(holdninger_pca$x,
                            partivalg,
                            cluster_km = holdninger_km$cluster, 
                            cluster_hc = cluster_hc)

## B.3: HVOR ENIGE ER K-MEANS OG HIERARKISK CLUSTERING I VORES CASE?
mean(holdninger_df$cluster_hc == holdninger_df$cluster_km)  # de er enige for 80 % af observationerne




