
BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
MODEL=$2
PHENOCOL=$(echo $2 + 2 | bc) # in the special pheno file have to ignore first 6 columns (bayesR counts starting at 6 so need to offset by 2, eg pheno file has fam + trait + 12 models)
TEST=${POP}_${TRAIT}_testing_${CV}
DIR=results/${POP}_${TRAIT}
REGRESSION=$(grep -w "$TRAIT" data/pop_trait_models.csv | cut -d',' -f2)
###################### bayesR

# run bayes
# need 3 blank columns first as bayes counts from the 6th not the third

cp tmp/${BFILE}.pheno tmp/${BFILE}_${MODEL}.fam
cp tmp/${BFILE}.bed tmp/${BFILE}_${MODEL}.bed
cp tmp/${BFILE}.bim tmp/${BFILE}_${MODEL}.bim
software/bayesR/bin/bayesR -bfile tmp/${BFILE}_${MODEL} -out $DIR/bayesR/${TRAIT}_${CV}_${MODEL} -numit 1000 -burnin 200 -n $PHENOCOL -seed 333

software/bayesR/bin/bayesR -bfile tmp/${POP}_${TRAIT}_testing_${CV} -out $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.2 -predict -model $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.model -freq $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.frq -param $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.param
#rm tmp/${BFILE}_${MODEL}.{fam,bed,bim}


