library(tidyverse)
library(here)

traits <- read_csv(here("data/pop_trait_models.csv"), col_names = c("trait", "model_type")) %>% filter(!str_detect(trait,"#"))


pops <- tibble(pop = c("nph", "east","west","euro"))

reports <- crossing(pops, traits)

render_template <- function(pop, trait){
  rmarkdown::render(here("scripts/model_selection_doc.Rmd"),
                   params = list(pop = pop, trait = trait),
                   output_file = here("results",paste0("report_",pop,"_",trait,".html")))
}


# example:
# render_template("nph","HEIGHT")


map2(reports$pop, reports$traits, render_template)
