### whole_pop_pipeline.sh

## Run:


## bash scripts/whole_pop_pipeline.sh data/data {POP_NAME} 

## 




ORIG_DATA=$1
POP=$2
RESULTS=${POP}_results/




echo "START"

date


#### Initial setup #####
mkdir -p tmp ${RESULTS}/


software/plink1.9b6.10 --bfile ${ORIG_DATA} --make-bed --out tmp/data_sorted


## sort and keep our population
software/plink1.9b6.10 --bfile tmp/data_sorted --keep data/${POP}.keep --maf 0.01 --geno 0.05 --make-bed --out tmp/${POP}_sorteddata


# create list of population specific independent SNPs from data
software/plink1.9b6.10 --bfile tmp/${POP}_sorteddata --indep-pairwise 50 5 0.2 --maf 0.1 --out ${RESULTS}/${POP}_pca_markers

######################## GCTA
#grm

# only run this line once per population to save time
software/gcta64 --bfile tmp/${POP}_sorteddata --autosome --make-grm --out ${RESULTS}/${POP}_gcta_grm --threads 4



######################## PCAs

### calculate principal components for the population using the independent markers
software/plink1.9b6.10 --bfile tmp/${POP}_sorteddata --pca 10 --out ${RESULTS}/${POP}_pcafile --extract ${RESULTS}/${POP}_pca_markers.prune.in --allow-no-sex





####################### LDAK

echo "Start LDAK $(date)"
### calculate the weights and kinships for LDAK prior to GRM
software/LDAK/ldak5.linux --cut-weights ${RESULTS}/${POP}_ldak_sections --bfile tmp/${POP}_sorteddata


software/LDAK/ldak5.linux --calc-weights-all ${RESULTS}/${POP}_ldak_sections --bfile tmp/${POP}_sorteddata


software/LDAK/ldak5.linux --calc-kins-direct ${RESULTS}/${POP}_ldak_kinships --bfile  tmp/${POP}_sorteddata --weights ${RESULTS}/${POP}_ldak_sections/weights.short --power -0.25

echo "Start traits $(date)"
# example line to use for testing one iteration
#line="HEIGHT,linear",
while read line
do
	TRAIT=$(echo $line | cut -d',' -f1)
	REGRESSION_TYPE=$(echo $line | cut -d',' -f2)

	echo "Start ${TRAIT} $(date)"
	mkdir -p ${RESULTS}/{GCTA,LDAK}
	##### Generate regression residuals for each model #####
	# makes tmp/${POP}_${TRAIT}_residuals.txt
	
	#bash scripts/generate_models_whole_pop.sh ${POP} ${TRAIT} ${REGRESSION_TYPE} 
	Rscript scripts/model_residuals_whole_pop.R --trait ${TRAIT} --pop ${POP} --regression ${REGRESSION_TYPE} --out_dir ${RESULTS}/

	##### Create phone files with the residuals
	### prune and sort the data
	# prune to only those with residuals
	# residual are population specific with PCAs included in the model outside this script.
	# combine residuals to fam file
	# this step need to be repeated for each of the groups at bayesR section
	# columns 8-12 are the FIVE residuals
	# height, egfr, serumurate, diabetes and gout in that order
	# need to join based on number fo models 2.2 - 2.8  was for 7 models
	software/plink1.9b6.10 --bfile data/data --keep data/${POP}.keep --make-bed --out tmp/${POP}_${TRAIT}
	# this should join using IID from fam and IID from the pheno (in pheno first and second cols are duplicated) includes entire fam in output so need to adjust accordingly for model numbers (-6 cols)
	join -1 2 -2 1 -o auto -e "NA" <(sort -k2 tmp/${POP}_${TRAIT}.fam) <(sort -k1 ${RESULTS}/${POP}_${TRAIT}.residuals.txt)  > ${RESULTS}/${POP}_${TRAIT}.pheno 

	# calculate the column indexes, offset by 2 (to account for FID and IID) from all of the residuals -> should be equal to $(seq 1 number_of_models)
	pheno_cols=$( head -1 ${RESULTS}/${POP}_${TRAIT}.residuals.txt | awk '{ for(i=1;i<=NF-2;i++){print i}}' | sort -u)	


	#### GCTA REML for each model of current trait
	# run the following with 16 parallel jobs
	parallel -j 16 'nice -n 10 bash scripts/run_gcta_whole_pop.sh {1} {2}' ::: tmp/${POP}_${TRAIT}.fam  ::: ${pheno_cols} 

	#### LDAK for each model of current trait
	parallel -j 16 'nice -n 10 bash scripts/run_ldak_whole_pop.sh {1} {2} ' :::  tmp/${POP}_${TRAIT}.fam  ::: ${pheno_cols} 

done < data/pop_trait_models.csv




echo "FINISH"

date


