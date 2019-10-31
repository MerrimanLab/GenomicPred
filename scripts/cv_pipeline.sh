mkdir -p tmp results

# create lise of independent SNPs from data
plink1.9b6.10 --bfile data/data --indep-pairwise 50 5 0.2 --maf 0.1 --out data/data_pca_markers

# create the PCAs for the pops of interest
parallel 'bash scripts/generate_pop_pca.sh {}' ::: nph east west euro 


# create the cv splits and residuals for all pops and trait combos

CV=5 # number fo folds for cross validation

for POP in nph east west euro 
do
	while read line
	do
		TRAIT=$(echo $line | cut -d',' -f1)
		REGRESSION_TYPE=$(echo $line | cut -d',' -f2)
		bash scripts/generate_models.sh ${POP} ${TRAIT} ${REGRESSION_TYPE} ${CV}
	done < data/pop_trait_models.csv
done


### prune and sort the data
# prune to only those with residuals
# residual are population specific with PCAs included in the model outside this script.
# combine residuals to fam file
# this step need to be repeated for each of the groups at bayesR section
# columns 8-12 are the FIVE residuals
# height, egfr, serumurate, diabetes and gout in that order


# creates the training subsets and joins the residuals to make the new fam file.
# if needed to rerun make sure to do "rm tmp/*cv*.{bed,bim,fam,log,nosex}" first
parallel 'bash scripts/training_subset.sh {}' ::: $(ls tmp/*_training_cv* | grep -v 'residuals')


# run bayesR, GCTA and LDAK for each combo and all CVs

parallel 'bash scripts/run_gcta.sh {1} {2} ' ::: nph east west euro ::: $(cat data/pop_trait_models.csv | cut -d',' -f1 | tr "\n" " ")
parallel 'bash scripts/run_ldak.sh {1} {2} ' ::: nph east west euro ::: $(cat data/pop_trait_models.csv | cut -d ',' -f1 | tr "\n" " ")
parallel 'bash scripts/run_bayesR.sh {1} {2} ' ::: nph east west euro ::: $(cat data/pop_trait_models.csv | cut -d',' -f1 | tr "\n" " ")


