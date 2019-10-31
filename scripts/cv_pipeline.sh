mkdir -p tmp results

# create lise of independent SNPs from data
plink2 --bfile data/data --indep-pairwise 50 5 0.2 --maf 0.1 --out data/data_pca_markers

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


for cv_training in ${POP}_${TRAIT}_training_cv*
do
	plink2 --bfile data/data --keep $cv_training --make-bed --out $cv_training
	join -1 1 -2 1 -o 1.1 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 -e "NA" <(sort -k 1 tmp/$cv_training.fam) <(sort -k 1 tmp/${cv_training}_residuals.txt) > dummy
	mv tmp/${cv_training}.fam tmp/${cv_training}.fam.bak
	mv dummy tmp/${cv_training}.fam
done





cat tmp/${POP}_${TRAIT}_residuals.csv | awk '{ print($1, $1)}' > tmp/trainfile.txt
# check order of filtering ie maf, geno, people
plink2 --bfile data/data --keep tmp/trainfile.txt --make-bed --out tmp/traindata

join -1 1 -2 1 -o 1.1 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 -e "NA" <(sort -k 1 tmp/traindata.fam) <(sort -k 1 tmp/residuals.csv) > dummy

mv dummy tmp/traindata.fam

# run bayesR, GCTA and LDAK for each combo and all CVs

parallel 'run_gcta.sh {1} {2} ' ::: nph east west euro ::: $(cat pop_trait_models.txt | cut -f1 | tr "\n" " ")
parallel 'run_ldak.sh {1} {2} ' ::: nph east west euro ::: $(cat pop_trait_models.txt | cut -f1 | tr "\n" " ")
parallel 'run_bayesR.sh {1} {2} ' ::: nph east west euro ::: $(cat pop_trait_models.txt | cut -f1 | tr "\n" " ")


