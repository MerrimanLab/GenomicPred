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
  make_option(c("--keepfile"), type="character", default=NULL,
              help="Name of tab separated keep file to split into CVs with .keep suffix", metavar="character"),
  make_option(c("--outdir"), type = "character", default = "data",
              help = "Name of the directory to store the split keep files - default is data/ (no trailing slash needed)."),
  make_option(c("--cv"), type="numeric",default = 5,
	      help = "Number of cross-validations to perform (default = 5)")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

message(paste(opt$keepfile, opt$outdir, opt$cv))
# cv folds
cv_n <- opt$cv

keepfile <- read_tsv(here(opt$keepfile), col_names = c("FID","IID"))

## create test and training sets


## set the seed to make your partition reproducible
# n-fold CV ####
#n <- 5 # how many folds we want

set.seed(42)
idx <- 1:nrow(keepfile)
idx <- sample(idx, length(idx)) # shuffle up the index

new_keep <- basename(str_remove(opt$keepfile, "\\.keep"))

testing_idxs <- split(idx, sort(idx%%cv_n)) # splits the data into n ~equal sized chunks (test sets)

testing <- list()
training <- list()
# create the testing and training sets
# and write out keep files to be used with plink
for(i in 1:cv_n){
  testing[[i]] <- keepfile[ testing_idxs[[i]], ] %>% write_tsv(file = here(paste0(opt$outdir,new_keep,"-testing-cv", i, ".keep")), col_names = FALSE)
  training[[i]] <- keepfile[ -testing_idxs[[i]], ] %>% write_tsv(file = here(paste0(opt$outdir,new_keep,"-training-cv", i, ".keep")), col_names = FALSE)
}
