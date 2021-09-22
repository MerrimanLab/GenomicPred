## 12 July 2021.

## PCA based Pop selection.
library(tidyverse)
library(here)
library(patchwork)
#CREBRF MASTER FILE (FROM TANYA)
tanya <- read_csv(file = here("data/tanya_data.csv"), col_names = TRUE) # %>% mutate(GOUT01recode = GOUT -1, T2D01recode = T2D -1, logBMI= log(BMI))

orig <- read_csv(here("data/curated_data.csv"))

east <- read_tsv(here("data/east597btanya.keep"), col_names = FALSE) %>% mutate(pop = "east")

west <- read_tsv(here("data/west597btanya.keep"), col_names = FALSE) %>% mutate(pop = "west")

euro <- read_tsv(here("data/euro597btanya.keep"), col_names = FALSE) %>% mutate(pop = "euro")

nph <- read_tsv(here("data/nphtanya.keep"), col_names = FALSE) %>% mutate(pop ="nph")

pops <- bind_rows(east, west, euro, nph)

pops <- pops %>% left_join(orig %>%
                             select(SUBJECT, starts_with("PC")),
                           by = c("X2" = "SUBJECT")) %>%
  drop_na()


# make plots using the original global coreExome PCs
theme_set(theme_bw())
p1 <- pops %>% ggplot(aes(x = PCA2, y = PCA3, colour = pop)) + geom_point() +
  ggtitle("Original") +
  geom_hline(yintercept = 0.0025, colour = "red", linetype = "dashed") +
  geom_vline(xintercept = 0, colour = 'red', linetype = "dashed")

## 19 July 2021 Re-run NPH again
new_nph <- pops %>% filter(pop == "nph" & PCA2 > 0 & PCA3 > 0.0025) %>%
  select(X1,X2) %>% write_delim(file = here("data/nphpca.keep"),
                                delim = "\t",
                                col_names = FALSE) %>% mutate(pop = "nph")

new_east <- pops %>% filter(pop == "east" & PCA2 > 0 & PCA3 > 0.0025) %>%
  select(X1,X2) %>% write_delim(file = here("data/eastpca.keep"),
                                delim = "\t",
                                col_names = FALSE) %>% mutate(pop ="east")

new_west <- pops %>% filter(pop == "west" & PCA2 > 0 & PCA3 < 0.0025) %>%
  select(X1,X2) %>% write_delim(file = here("data/westpca.keep"),
                                delim = "\t",
                                col_names = FALSE) %>% mutate(pop = "west")

new_euro <- pops %>% filter(pop == "euro" & PCA2 < 0) %>%
  select(X1,X2) %>% write_delim(file = here("data/europca.keep"),
                                delim = "\t",
                                col_names = FALSE) %>% mutate(pop = "euro")



new_pops <- bind_rows(new_east, new_west, new_euro, new_nph)

new_pops <- new_pops %>% left_join(orig %>%
                                     select(SUBJECT, starts_with("PC")),
                                   by = c("X2" = "SUBJECT")) %>%
  drop_na()


# make plots using the original global coreExome PCs

p2 <- new_pops %>% ggplot(aes(x = PCA2, y = PCA3, colour = pop)) +
  geom_point() +
  ggtitle("After PCA Thresholds") +
  geom_hline(yintercept = 0.0025, colour = "red", linetype = "dashed") +
  geom_vline(xintercept = 0, colour = 'red', linetype = "dashed")

p1 + p2 + patchwork::plot_layout(guides = "collect")


# make covar files
new_pops %>% left_join(tanya %>% select(X1 = SUBJECT, AGECOL, SEX), by = "X1") %>%
  relocate(AGECOL, SEX, .after = X2) %>% rename(FID = X1, IID = X2) %>%
  select(-pop) %>% write_tsv("data/tanya_covar.csv")

