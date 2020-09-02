
BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
MODEL=$2
PHENOCOL=$(echo $2 + 5 | bc) # in the special pheno file have to ignore first 5 columns in the pheno file (IID FID PID MID SEX) 
TEST=${POP}_${TRAIT}_testing_${CV}
DIR=results/${POP}_${TRAIT}
REGRESSION=$(grep -w "$TRAIT" data/pop_trait_models.csv | cut -d',' -f2)
###################### bayesR

# run bayes
# need 3 blank columns first as bayes counts from the 6th not the third

plink1.9b6.10 --bfile tmp/${BFILE} --pheno tmp/${BFILE}.pheno --mpheno ${PHENOCOL} --make-bed --out tmp/${BFILE}_model${MODEL} --output-missing-phenotype NA

#cp tmp/${BFILE}.pheno tmp/${BFILE}_${MODEL}.fam
#cp tmp/${BFILE}.bed tmp/${BFILE}_${MODEL}.bed
#cp tmp/${BFILE}.bim tmp/${BFILE}_${MODEL}.bim

# plink has put the appropriate pheno column in as the AFF col in the fam so no longer need to specify a specific column here
software/bayesR/bin/bayesR -bfile tmp/${BFILE}_model${MODEL} -out $DIR/bayesR/${TRAIT}_${CV}_${MODEL} -numit 1000 -burnin 200 -seed 333

software/bayesR/bin/bayesR -bfile tmp/${POP}_${TRAIT}_testing_${CV} -out $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.2 -predict -model $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.model -freq $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.frq -param $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.param
#rm tmp/${BFILE}_${MODEL}.{fam,bed,bim}


