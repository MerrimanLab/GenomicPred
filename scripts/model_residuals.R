if(!require(here)){
  install.packages("here", repos = "https://cloud.r-project.org")
  library("here")
}
if(!require(fs)){
  install.packages("fs", repos = "https://cloud.r-project.org")
  library(fs)
}
if(!require(tidyverse)){
  install.packages("tidyverse", repos = "https://cloud.r-project.org")
  library(tidyverse)
}
if(!require(optparse)){
  install.packages("optparse", repos = "https://cloud.r-project.org")
  library("optparse")
}


option_list = list(
  make_option(c("--trait"), type="character", default=NULL,
              help="Name of trait column that matches exactly from the phenotype file", metavar="character"),
  make_option(c("-r", "--regression"), type="character", default="linear",
              help="linear|logistic", metavar="character"),
  make_option(c("-p","--pop"), type = "character", default=NULL,
              help="Name of the population (no special characters except underscore).", metavar="character"),
  make_option(c("--out_dir"), type = "character", default = "results",
              help = "Name of the directory to store the results (no trailing slash needed)."),
  make_option(c("--cv"), type="numeric",default = 5,
	      help = "Number of cross-validations to perform (default = 5)")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


# name of trait column
#trait <- "HEIGHT"
if (is.null(opt$trait)){
  print_help(opt_parser)
  stop("Trait argument must be supplied.", call.=FALSE)
} else {
  trait <- opt$trait
}


# define model type: linear or logistic regression
#model_type <- "linear"
if(!(opt$regression == "linear" | opt$regression ==  "logistic")){
  print_help(opt_parser)
  stop("Regression argument must be 'linear' or 'logistic'.", call.=FALSE)
} else {
  model_type <- opt$regression
}

# population name
if(is.null(opt$pop)){
  print_help(opt_parser)
  stop("Population (pop) argument must be supplied.", call.=FALSE)
} else {
  pop <- opt$pop
}

# cv folds
cv_n <- opt$cv


all_dat <- read_csv(file = here("data/curated_data.csv"), col_names = TRUE) %>% mutate(GOUT01recode = GOUT -1, T2D01recode = T2D -1)
newpca <- read_delim(file = here("results",paste0(pop,"_","pcafile.eigenvec")), delim = " ", col_names = c("FID","SUBJECT",paste0("PC",1:10)), col_types = paste0(c("c","c",rep("d", 10)),collapse = ""))

if (!trait %in% names(all_dat)){
  stop("Trait argument supplied does not match a column in the phenotypes.", call.=FALSE)
}

### add the trait information on to the samples in the PCA
new_dat <- newpca %>% left_join(., all_dat, by = "SUBJECT")


## create test and training sets


## set the seed to make your partition reproducible
# n-fold CV ####
#n <- 5 # how many folds we want

set.seed(42)
idx <- 1:length(new_dat[["SUBJECT"]])
idx <- sample(idx, length(idx)) # shuffle up the index


testing_idxs <- split(idx, sort(idx%%cv_n)) # splits the data into n ~equal sized chunks (test sets)

testing <- list()
training <- list()
# create the testing and training sets
# and write out keep files to be used with plink
for(i in 1:cv_n){
  testing[[i]] <- new_dat[ testing_idxs[[i]], ]
  testing[[i]] %>% select(SUBJECT) %>% mutate(SUBJECT1 = SUBJECT) %>% write_delim(path = here("tmp/",paste0(pop,"_",trait,"_testing_cv", i)), col_names = FALSE)
  training[[i]] <- new_dat[ -testing_idxs[[i]], ]
  training[[i]] %>% select(SUBJECT) %>% mutate(SUBJECT1 = SUBJECT) %>% write_delim(path = here("tmp/",paste0(pop,"_",trait,"_training_cv", i)), col_names = FALSE)
}
names(training) <- paste0("cv",seq_along(training))
names(testing) <- paste0("cv",seq_along(training))

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
    model_results[["model"]] <- glm(model_formula, family = binomial(link='logit'), data = dat, na.action = na.exclude)
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

# funcntion to return the residuals from a cv model
get_residuals_df <- function(dat){
  res <- list()
  res$residuals <- map(dat, list("model","residuals"))
  res$remove <- map(dat, list("model","na.action"))
  #res <- map(names(res), ~ bind_cols(res[[.x]])  )
  return(res)
}

# put the residuals from all models into a dataframe for each cv
cv_residuals <- map(cv_results, ~get_residuals_df(.x))


# write out each cv residuals with the subject and trait
walk(names(cv_residuals), ~write_delim(bind_cols((select(training[[.x]], SUBJECT, !!trait)) %>% slice(-unlist(cv_residuals[[.x]][["remove"]])), bind_cols(cv_residuals[[.x]][["residuals"]])), path = here("tmp",paste0(pop,"_",trait,"_training_",.x,"_residuals",".txt")), delim = " ", col_names = FALSE))


saveRDS(list(cv_results = cv_results, trait, model_type, models, preds, testing, training), file = here(opt$out_dir,paste0(pop,"_",trait,".RDS")))



# Old Matt code below here ####







# ggroc <- function(roc, showAUC = TRUE, interval = 0.2, breaks = seq(0, 1, interval)){
#   require(pROC)
#   if(class(roc) != "roc")
#     simpleError("Please provide roc object from pROC package")
#   plotx <- rev(roc$specificities)
#   ploty <- rev(roc$sensitivities)
#
#   ggplot(NULL, aes(x = plotx, y = ploty)) +
#     geom_segment(aes(x = 0, y = 1, xend = 1,yend = 0), alpha = 0.5) +
#     geom_step() +
#     scale_x_reverse(name = "Specificity",limits = c(1,0), breaks = breaks, expand = c(0.001,0.001)) +
#     scale_y_continuous(name = "Sensitivity", limits = c(0,1), breaks = breaks, expand = c(0.001, 0.001)) +
#     theme_bw() +
#     theme(axis.ticks = element_line(color = "grey80")) +
#     coord_equal() +
#     annotate("text", x = interval/2, y = interval/2, vjust = 0, label = paste("AUC =",sprintf("%.3f",roc$auc)))
# }

# ls()
#
# bc <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/heightCOVAR.indi.blp", delim = "\t", col_names = F)
#
# b1 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height1.indi.blp", delim = "\t", col_names = F)
# b2 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height2.indi.blp", delim = "\t", col_names = F)
# b3 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height3.indi.blp", delim = "\t", col_names = F)
# b4 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height4.indi.blp", delim = "\t", col_names = F)
# b5 <- read_delim("/media/xsan/staff_groups/merrimanlab/Merriman_Documents/Matt/GP_June/output_poly_height/LDAK/height5.indi.blp", delim = "\t", col_names = F)
#
# head(b1)
#
# plot(b1$X3,b4$X3)
#
#
# mod_0 <- lm(HEIGHT ~ SEX + AGECOL, data = all.dat, na.action = na.exclude)
# mod_1 <- lm(log(HEIGHT) ~ SEX + AGECOL, data = all.dat, na.action = na.exclude)
#
# summary(mod_1)
#
# BIC(mod_0)
