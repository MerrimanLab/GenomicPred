## Remove Pukapuka from West Polynesian Pops


tanya <- read_csv(file = here("data/tanya_data.csv"), col_names = TRUE) %>%
  filter(SUBJECT != "Blank") %>%
  mutate(GOUT_orig_code = GOUT, GOUT = case_when(str_detect(GOUT,"Control") ~ 1,
                                                 GOUT %in% c("ACR Gout","GP Gout") ~ 2,
                                                 TRUE ~ NA_real_
  ),
  T2D = case_when(TYPE2D == "No" ~ 1,
                  TYPE2D == "Yes" ~ 2,
                  TRUE ~ NA_real_
  ))

## west_pca_tanya.keep is the same as the current westpca.keep file (same PATIENT IDs)
keep_files <- list.files("/Volumes/scratch/merrimanlab/ben/genomic_predictions/data/", pattern = "pca.keep", full.names = TRUE)

pops <- map_dfr(keep_files, read_tsv, col_names = FALSE)
tanya_filtered <- tanya  %>% filter(SUBJECT %in% pops$X1)

tanya_no_puka <- tanya_filtered %>% mutate(Westkeep= ifelse(ETH_SPECIFIC == "Pukapukan",0,1))

tanya_no_puka2 <- filter(tanya_no_puka, Westkeep == 1)

height <- tanya_no_puka2 %>% drop_na(HEIGHT)
BMI <- tanya_no_puka2 %>% drop_na(BMI)
HDL <- tanya_no_puka2 %>% drop_na(HDL)
T2D<- tanya_no_puka2 %>% drop_na(T2D)
GOUT <- tanya_no_puka2 %>% drop_na(GOUT)

library(dplyr)

# There are 2 Mixed Polys, these are NPH participants (NPH group wasnt run)
data.table::setDT(height)[,list(Mean=mean(HEIGHT), Max=max(HEIGHT), Min=min(HEIGHT), Mean=as.numeric(mean(HEIGHT)), Std=sd(HEIGHT)), by=ANALYSISGROUP_EASTWEST]
data.table::setDT(BMI)[,list(Mean=mean(BMI), Max=max(BMI), Min=min(BMI), Mean=as.numeric(mean(BMI)), Std=sd(BMI)), by=ANALYSISGROUP_EASTWEST]
data.table::setDT(HDL)[,list(Mean=mean(HDL), Max=max(HDL), Min=min(HDL), Median=as.numeric(median(HDL)), Std=sd(HDL)), by=ANALYSISGROUP_EASTWEST]

table(height$ANALYSISGROUP_EASTWEST)
table(BMI$ANALYSISGROUP_EASTWEST)
table(HDL$ANALYSISGROUP_EASTWEST)
table(T2D$ANALYSISGROUP_EASTWEST)
table(height$ANALYSISGROUP_EASTWEST)
table(height$ANALYSISGROUP_EASTWEST)
table(tanya$ANALYSISGROUP_EASTWEST)

# Gout and T2D tables
tanya_no_puka2 %>% group_by(T2D, ANALYSISGROUP_EASTWEST) %>% tally(sort = F)
tanya_no_puka2 %>% group_by(GOUT, ANALYSISGROUP_EASTWEST) %>% tally(sort = F)
tanya_no_puka2 %>% group_by(SEX, ANALYSISGROUP_EASTWEST) %>% tally(sort = F)
