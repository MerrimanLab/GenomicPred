# Make sex specific Euro and West Poly keepfiles..

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


## Read in Euro and West (no Puka) keep files
westpca <- read.delim(file = "data/westnopukapca.keep", sep = "\t", header = F)
euro <-  read.delim(file = "data/europca.keep", sep = "\t", header = F)



## List of Sex specific IDs
tanya_men <- filter(tanya, SEX == 1) %>% select(PATIENT, ANALYSISGROUP_EASTWEST)
tanya_women <- filter(tanya, SEX == 2) %>% select(PATIENT, ANALYSISGROUP_EASTWEST)

## Renaming column so that "euro" or "westpca" have matching columns.
names(tanya_men)[1] <- 'V1'
names(tanya_women)[1] <- 'V1'



euro_men <- filter(tanya_men, ANALYSISGROUP_EASTWEST == "European") %>% select(V1)
euro_women <- filter(tanya_women, ANALYSISGROUP_EASTWEST == "European") %>% select(V1)

west_men <- filter(tanya_men, ANALYSISGROUP_EASTWEST == "West Polynesian") %>% select(V1)
west_women <- filter(tanya_women, ANALYSISGROUP_EASTWEST == "West Polynesian") %>% select(V1)


## Make sex specific population files
euromale <- merge(euro,euro_men,all = F)
eurofemale <- merge(euro,euro_women, all = F)

westmale <- merge(westpca,west_men, all = F)
westfemale <- merge(westpca, west_women, all = F)
sum(is.na(westfemale$V1))
sum(is.na(westfemale$V2))
sum(is.na(westmale$V1))
sum(is.na(westmale$V2))

ifelse(westfemale$V1==westfemale$V2,"Yes","No")

## make keep files.
write_delim(euromale, file = "/Volumes/scratch/merrimanlab/ben/genomic_predictions/data/euromalepca.keep", col_names = F, delim = "\t")

write_delim(eurofemale, file = "/Volumes/scratch/merrimanlab/ben/genomic_predictions/data/eurofemalepca.keep", col_names = F, delim = "\t")

write_delim(westmale, file = "/Volumes/scratch/merrimanlab/ben/genomic_predictions/data/westmalepca.keep", col_names = F, delim = "\t")

write_delim(westfemale, file = "/Volumes/scratch/merrimanlab/ben/genomic_predictions/data/westfemalepca.keep", col_names = F, delim = "\t")


