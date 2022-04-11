`scripts/` contains the scripts that are used for the calculation of genomic profile scores 

The main workflow script is `cv_pipeline.sh` which will run each of the required steps. (This pipeline is used to estimate trait heritabilities for each Polynesian Population of interest (i.e not for the CV-trait profile score stages)). 

It starts with a plink formatted dataset containing all populations of interest, subsets out each population, and does cross-validation for each trait of interest in each population using both GCTA and LDAK.

`scripts/create_model_reports.R` will create reports for each pop/trait combo as listed in `data/pop_trait_models.csv` and apply a template RMarkdown to pull in and summarise the results from LDAK and GCTA. The template document is `scripts/model_selection_doc.Rmd`.
