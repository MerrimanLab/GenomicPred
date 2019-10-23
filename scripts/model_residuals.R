library(tidyverse)
all.dat <- read.csv(file="/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/data/curated_data.csv",header=T)
newpca <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/tmp/pcafile.eigenvec", delim = " ", col_names = F)

### look at jpoin function, inner or right join
new.dat <- all.dat %>% left_join(., newpca, by = c("SUBJECT" = "X1")) %>% 
  filter(PCAETHBROAD == "Polynesian" | PCAETHBROAD == "West Polynesian" | PCAETHBROAD == "East Polynesian")

new.dat <- all.dat %>% left_join(., newpca, by = c("SUBJECT" = "X1")) %>% 
  filter(str_detect(SUBJECT, 'CNP|NPH'))

data(new.dat)

## create test and training sets
## 80% of the sample size
smp_size <- floor(0.80 * nrow(new.dat))

## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(new.dat)), size = smp_size)

train <- new.dat[train_ind, ]
test <- new.dat[-train_ind, ]

all.dat <- train


#models

#sqrt(DIABETES) ~ AGE2 + BMI
#variates <- c("SEX","AGECOL","AGE2","BMI")

#URATE ~ 
#variates <- c("URATELOWERING","SEX","AGECOL","BMI")

#HEIGHT ~ 
variates <- c("SEX" , "AGECOL")

#EGFRCALC ~ SEX+AGECOL
#variates <- c("SEX" , "AGECOL")

#BMI ~ SEX + AGECOL + AGE2
#variates <- c("SEX","AGECOL","AGE2")

#GOUT ~ SEX + AGECOL + AGE2 + BMI
#variates <- c( "SEX" , "AGECOL" , "AGE2" , "BMI")

step(lm(HEIGHT ~ SEX+AGECOL+AGE2,data=all.dat),direction="both")

### write models for 0, 2, 4, 6, 8, 10 PCs 
mod_0 <- lm(HEIGHT ~ SEX + AGECOL, data = all.dat, na.action = na.exclude)
mod_2 <- lm(HEIGHT ~ X3 +X4 +SEX + AGECOL, data = all.dat, na.action = na.exclude)
mod_4 <- lm(HEIGHT ~ X3 +X4 +X5 +X6 +SEX + AGECOL, data = all.dat, na.action = na.exclude)
mod_6 <- lm(HEIGHT ~ X3 +X4 +X5 +X6 +X7 +X8 +SEX + AGECOL, data = all.dat, na.action = na.exclude)
mod_8 <- lm(HEIGHT ~ X3 +X4 +X5 +X6 +X7 +X8 +X9 +X10 +SEX + AGECOL, data = all.dat, na.action = na.exclude)
mod_10 <- lm(HEIGHT ~ X3 +X4 +X5 +X6 +X7 +X8 +X9 +X10 +X11 +X12 +SEX + AGECOL, data = all.dat, na.action = na.exclude)

length(na.omit(all.dat$X4))

mod_0 <- glm(GOUT-1 ~ SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)
mod_2 <- glm(GOUT-1 ~ X3 +X4 +SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)
mod_4 <- glm(GOUT-1 ~ X3 +X4 +X5 +X6 +SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)
mod_6 <- glm(GOUT-1 ~ X3 +X4 +X5 +X6 +X7 +X8 +SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)
mod_8 <- glm(GOUT-1 ~ X3 +X4 +X5 +X6 +X7 +X8 +X9 +X10 +SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)
mod_10 <- glm(GOUT-1 ~ X3 +X4 +X5 +X6 +X7 +X8 +X9 +X10 +X11 +X12 +SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)



summary(mod_2)

#mod_urate <- lm(SERUMURATE ~ X3 +X4 +X5 +X6 +X7 +X8 +URATELOWERING + SEX + AGECOL + BMI, data = all.dat, na.action=na.exclude)
#mod_EGFR <- lm(EGFRCALC ~ X3 +X4 +X5 +X6 +X7 +X8 +SEX + AGECOL, data = all.dat, na.action=na.exclude)
#mod_diabetes <- glm(DIABETES-1 ~ X3 +X4 +X5 +X6 +X7 +X8 +SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)
#mod_gout <- glm(GOUT-1 ~ X3 +X4 +X5 +X6 +X7 +X8 +SEX + AGECOL + AGE2 + BMI, data = all.dat, family=binomial(link='logit'),na.action=na.exclude)

#residuals <- cbind(all.dat$SUBJECT,resid(mod_height),resid(mod_EGFR), resid(mod_urate), resid(mod_diabetes), resid(mod_gout))
residuals <- cbind(all.dat$SUBJECT,all.dat$HEIGHT,resid(mod_0),resid(mod_2),resid(mod_4),resid(mod_6),resid(mod_8),resid(mod_10))

write.table(residuals, "/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/tmp/residuals.csv", quote = F, row.names = F, sep = " ", col.names = F)


#plot(mod_0)
#dim(all.dat)

#pairs(all.dat[31:40], col = as.numeric(as.factor(all.dat$PCAETHBROAD)))

#pairs(all.dat[31:34], col = as.numeric(as.factor(all.dat$PCAETHBROAD)))
#pairs(all.dat[35:38], col = as.numeric(as.factor(all.dat$PCAETHBROAD)))
#pairs(all.dat[39:40], col = as.numeric(as.factor(all.dat$PCAETHBROAD)))



ggroc <- function(roc, showAUC = TRUE, interval = 0.2, breaks = seq(0, 1, interval)){
  require(pROC)
  if(class(roc) != "roc")
    simpleError("Please provide roc object from pROC package")
  plotx <- rev(roc$specificities)
  ploty <- rev(roc$sensitivities)
  
  ggplot(NULL, aes(x = plotx, y = ploty)) +
    geom_segment(aes(x = 0, y = 1, xend = 1,yend = 0), alpha = 0.5) + 
    geom_step() +
    scale_x_reverse(name = "Specificity",limits = c(1,0), breaks = breaks, expand = c(0.001,0.001)) + 
    scale_y_continuous(name = "Sensitivity", limits = c(0,1), breaks = breaks, expand = c(0.001, 0.001)) +
    theme_bw() + 
    theme(axis.ticks = element_line(color = "grey80")) +
    coord_equal() + 
    annotate("text", x = interval/2, y = interval/2, vjust = 0, label = paste("AUC =",sprintf("%.3f",roc$auc)))
}

ls()

bc <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/heightCOVAR.indi.blp", delim = "\t", col_names = F)

b1 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height1.indi.blp", delim = "\t", col_names = F)
b2 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height2.indi.blp", delim = "\t", col_names = F)
b3 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height3.indi.blp", delim = "\t", col_names = F)
b4 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height4.indi.blp", delim = "\t", col_names = F)
b5 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height5.indi.blp", delim = "\t", col_names = F)

head(b1)

plot(b1$X3,b4$X3)


mod_0 <- lm(HEIGHT ~ SEX + AGECOL, data = all.dat, na.action = na.exclude)
mod_1 <- lm(log(HEIGHT) ~ SEX + AGECOL, data = all.dat, na.action = na.exclude)

summary(mod_1)

BIC(mod_0)
