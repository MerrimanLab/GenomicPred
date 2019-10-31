
BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
MODEL=$2
PHENOCOL=$(echo $2 + 1 | bc) # in the special pheno file have to ignore first 6 columns (bayesR counts starting at 6 so need to offset by 1)
TEST=${POP}_${TRAIT}_testing_${CV}
DIR=results/${POP}_${TRAIT}
REGRESSION=$(grep -w "$TRAIT" data/pop_trait_models.csv | cut -d',' -f2)
###################### bayesR

# run bayes
# need 3 blank columns first as bayes counts from the 6th not the third
mv tmp/${BFILE}.fam tmp/${BFILE}.fam.bak
cp tmp/${BFILE}.pheno tmp/${BFILE}.fam
software/bayesR -bfile tmp/${BFILE} -out $DIR/bayesR/${TRAIT}_${CV}_${MODEL} -numit 1000 -burnin 200 -n $PHENOCOL -seed 333

software/bayesR -bfile tmp/${POP}_${TRAIT}_testing_${CV} -out $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.2 -predict -model $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.model -freq $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.frq -param $DIR/bayesR/${TRAIT}_${CV}_${MODEL}.param
mv tmp/${BFILE}.fam.bak tmp/${BFILE}.fam


