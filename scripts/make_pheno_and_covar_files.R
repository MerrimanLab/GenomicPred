library(tidyverse)
library(here)

#CREBRF MASTER FILE (FROM TANYA)
tanya <- read_csv(file = here("data/tanya_data.csv"), col_names = TRUE) %>%
  filter(SUBJECT != "Blank")



nph <- read_delim(here("nphpca_results/nphpca_pcafile.eigenvec"), col_names = c("FID","IID",paste0("PCA",1:10)), delim = ' ')
east <- read_delim(here("eastpca_results/eastpca_pcafile.eigenvec"), col_names = c("FID","IID",paste0("PCA",1:10)), delim = ' ')
west <- read_delim(here("westpca_results/westpca_pcafile.eigenvec"), col_names = c("FID","IID",paste0("PCA",1:10)), delim = ' ')
euro <- read_delim(here("europca_results/europca_pcafile.eigenvec"), col_names = c("FID","IID",paste0("PCA",1:10)), delim = ' ')

# pheno files

all_IIDS <- c(nph$IID, east$IID, west$IID, euro$IID)

tanya <- tanya %>% filter(SUBECT %in% all_IIDS)

tanya %>% select(IID = SUBJECT, GOUT) %>%
  mutate(GOUT_recode = case_when(str_detect(GOUT,"Control") ~ 1,
                          GOUT %in% c("ACR Gout","GP Gout") ~ 2,
                          TRUE ~ NA_real_
                          ),
         FID = IID) %>% select(FID, IID, GOUT = GOUT_recode) %>%
  write_tsv(here("data/tanya_gout.pheno"))


tanya %>% select(IID = SUBJECT, TYPE2D) %>%
  mutate(TYPE2D_recode = case_when(TYPE2D == "No" ~ 1,
                                 TYPE2D == "Yes" ~ 2,
                                 TRUE ~ NA_real_
  ),
  FID = IID) %>% select(FID, IID, TYPE2D = TYPE2D_recode) %>% write_tsv(here("data/tanya_t2d.pheno"))

# covar files
nph_covar <- tanya %>% mutate(FID = SUBJECT, IID = SUBJECT) %>%
  select(FID,IID, AGECOL, SEX) %>%
  right_join(nph)

east_covar <- tanya %>% mutate(FID = SUBJECT, IID = SUBJECT) %>%
  select(FID,IID, AGECOL, SEX) %>%
  right_join(east)

west_covar <- tanya %>% mutate(FID = SUBJECT, IID = SUBJECT) %>%
  select(FID,IID, AGECOL, SEX) %>%
  right_join(west)

euro_covar <- tanya %>% mutate(FID = SUBJECT, IID = SUBJECT) %>%
  select(FID,IID, AGECOL, SEX) %>%
  right_join(euro)

cols <- names(nph_covar)[-1:-2]
for(n in cols){
  p <- nph_covar %>% select(FID, IID:!!n)
  fn <- paste(names(p)[-1:-2], collapse = "_")
  print(fn)
  write_tsv(p, here("nphpca_results/",paste0("nphpca_", fn,".covar")))

  east_covar %>% select(FID, IID:!!n) %>%
    write_tsv( here("eastpca_results/",paste0("eastpca_", fn,".covar")))

  west_covar %>% select(FID, IID:!!n) %>%
    write_tsv( here("westpca_results/",paste0("westpca_", fn,".covar")))

  euro_covar %>% select(FID, IID:!!n) %>%
    write_tsv( here("europca_results/",paste0("europca_", fn,".covar")))

}


