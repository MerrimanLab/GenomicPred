
## Run:
## bash scripts/cv_pipeline.sh data/data
## 

ORIG_DATA=$1

echo "START"
date
mkdir -p tmp results
software/plink1.9b6.10 --bfile ${ORIG_DATA} --make-bed --out tmp/data_sorted
# create lise of independent SNPs from data
software/plink1.9b6.10 --bfile tmp/data_sorted --indep-pairwise 50 5 0.2 --maf 0.1 --out tmp/data_pca_markers

# create the PCAs for the pops of interest
parallel 'bash scripts/generate_pop_pca.sh {}' ::: nph east west euro 


# create the cv splits and residuals for all pops and trait combos

# ****  traits must not contain underscores in their names ****
CV=2 # number fo folds for cross validation

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


### run bayesR, GCTA and LDAK for each combo and all

# calculate the column indexs from all of the residuals -> should be equal to $(seq 1 number_of_models)
pheno_cols=$(for cv_residuals in tmp/*residuals.txt; do  head -1 $cv_residuals | awk '{ for(i=1;i<=NF-2;i++){print i}}' ; done | sort -u)
echo 16 > cpus
parallel -j cpus 'nice -n 10 bash scripts/run_gcta.sh {1} {2}' ::: $(ls tmp/*training_cv*.fam | grep 'cv[0-9]\+.fam') ::: ${pheno_cols} 
echo 32 > cpus
parallel -j cpus 'nice -n 10 bash scripts/run_ldak.sh {1} {2} ' :::  $(ls tmp/*training_cv*.fam | grep 'cv[0-9]\+.fam') ::: ${pheno_cols}
#parallel -j cpus 'nice -n 10 bash scripts/run_bayesR.sh {1} {2} ' ::: $(ls tmp/*training_cv*.fam | grep 'cv[0-9]\+.fam') ::: ${pheno_cols}

echo "FINISH"
date

