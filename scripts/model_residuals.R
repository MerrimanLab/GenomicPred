library(here)
library(fs)
library(caret)
library(tidyverse)

# define model type: linear or logistic regression
model_type <- "linear"

# name of trait column
trait <- "HEIGHT"

all_dat <- read_csv(file = here("data/curated_data.csv"), col_names = TRUE)
newpca <- read_delim(file = here("tmp/pcafile.eigenvec"), delim = " ", col_names = c("FID","SUBJECT",paste0("PC",1:10)))

### add the trait information on to the samples in the PCA
new_dat <- newpca %>% left_join(., all_dat, by = "SUBJECT")


## create test and training sets


## set the seed to make your partition reproducible
# n-fold CV ####
n <- 5 # how many folds we want

set.seed(42)
idx <- 1:length(new_dat[["SUBJECT"]])
idx <- sample(idx, length(idx)) # shuffle up the index


testing_idxs <- split(idx, sort(idx%%n)) # splits the data into n ~equal sized chunks (test sets)

testing <- list()
training <- list()
# create the testing and training sets
# and write out keep files to be used with plink
for(i in 1:n){
  testing[[i]] <- new_dat[ testing_idxs[[i]], ]
  testing[[i]] %>% select(SUBJECT) %>% mutate(SUBJECT1 = SUBJECT) %>% write_delim(path = here("tmp/",paste0("testing_cv_", i)), col_names = FALSE)
  training[[i]] <- new_dat[ -testing_idxs[[i]], ]
  training[[i]] %>% select(SUBJECT) %>% mutate(SUBJECT1 = SUBJECT) %>% write_delim(path = here("tmp/",paste0("training_cv_", i)), col_names = FALSE)
}


#models ####
preds <- c("AGECOL", "SEX", paste0("PC",1:10))

# generate models

models <- list()
for(pred_idx in seq_along(preds)){
  if(pred_idx ==1){
    # create the base model
    models <- paste(trait,"~",preds[[pred_idx]])
  } else{
    # add the next covariate to the base model
    models[[pred_idx]] <- paste(models[[pred_idx-1]], preds[[pred_idx]], sep = " + ")
  }
}

# for a given formula run the model as either linear or logistic regression
run_model <- function(model_formula, dat){
  model_results <- list()
  if(model_type == "linear"){
    model_results[["model"]] <- lm(model_formula, data = dat, na.action = na.exclude)
  } else if(model_type == "logistic"){
    model_results[["model"]] <- glm(model_formula, family = "binomial", data = dat, na.action = na.exclude)
  }
  model_results[["formula"]] <- model_formula
  return(model_results)
}

# test example
#run_model(model_formula = models[[1]], training[[1]])

# run the set of models on a training set
run_cv <- function(training_set){
  model_results <- purrr::map(models, run_model, training_set) %>% set_names(., nm =  paste0("model",seq_along(models)))
  #names(model_results) <- paste0("model",seq_along(models))
  return(model_results)
}

# run all the training sets for all of the models
cv_results <- purrr::map(training, ~run_cv(.x) ) %>% set_names(paste0("cv", seq_along(training)))








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
