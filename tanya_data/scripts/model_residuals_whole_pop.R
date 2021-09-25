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
              help = "Name of the directory to store the results (no trailing slash needed).")
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


## Used for testing inside of an interactive session
#pop <- 'nph'
#model_type <- "linear"
#trait <- "HEIGHT"
#opt <-list(out_dir = "nph_results/")

all_dat <- read_csv(file = here("data/tanya_data.csv"), col_names = TRUE)# %>% mutate(GOUT01recode = GOUT -1, T2D01recode = T2D -1, logBMI= log(BMI))
newpca <- read_delim(file = here("results",paste0(pop,"_","pcafile.eigenvec")), delim = " ", col_names = c("FID","SUBJECT",paste0("PC",1:10)), col_types = paste0(c("c","c",rep("d", 10)),collapse = ""))

if (!trait %in% names(all_dat)){
  stop("Trait argument supplied does not match a column in the phenotypes.", call.=FALSE)
}

### add the trait information on to the samples in the PCA
new_dat <- newpca %>% left_join(., all_dat, by = "SUBJECT")



# Define list of variables for the models ####
preds <- c("AGECOL", "SEX", paste0("PC",1:10))

# generate models stepwise adding variables
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

# function to use for a given formula run the model as either linear or logistic regression
# runs the supplied model on the supplied dataset and returns the model results as a list(model, formula)
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
#run_model(model_formula = models[[1]], new_dat)



# run the set of models on a the data
model_results <- purrr::map(models, run_model, new_dat) %>% set_names(., nm =  paste0("model",seq_along(models)))
names(model_results) <- paste0("model",seq_along(models))



# put the residuals from all models into a dataframe for each cv
model_residuals <- map(model_results, list("model", "residuals"))
model_remove <-  map(model_results, list("model","na.action"))


# write out residuals, columns: SUBJECT TRAIT model1 ... modelx
new_dat %>% 
  select(SUBJECT, !!trait) %>% # pull out ids and trait column
  slice(-unlist(model_remove)) %>% # remove rows that didn't have residuals
  bind_cols(model_residuals) %>% 
  write_delim(file = here("tmp",paste0(pop,"_",trait,".residuals.txt")),
              delim = " ",
              col_names = FALSE)

  
message(paste("residuals file:", here("tmp",paste0(pop,"_",trait,".residuals.txt")))) 



saveRDS(list(model_residuals, model_remove, trait, model_type, models, preds), file = here(opt$out_dir,paste0(pop,"_",trait,".RDS")))

