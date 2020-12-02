`scripts/` contains the scripts that are used for the calculation of genomic profile scores 

The main workflow script is `cv_pipeline.sh` which will run each of the required steps.

It starts with a plink formatted dataset containing all populations of interest, subsets out each population, and does cross-validation for each trait of interest in each population using both GCTA and LDAK.
