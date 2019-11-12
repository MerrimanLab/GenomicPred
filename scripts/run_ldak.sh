BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
MODEL=$2
PHENOCOL=$(echo $MODEL + 4 | bc) # ignore the first 4 columns after FID and IID
TEST=${POP}_${TRAIT}_testing_${CV}_${MODEL}
DIR=results/${POP}_${TRAIT}
REGRESSION=$(grep -w "$TRAIT" data/pop_trait_models.csv | cut -d',' -f2)


####################### LDAK 
### reml
software/LDAK/ldak5.linux --reml $DIR/LDAK/${TRAIT}_${CV}_${MODEL} --pheno tmp/${BFILE}.pheno --mpheno ${PHENOCOL} --grm results/ldak_kinships

### blups
software/plink1.9b6.10 --bfile data/data --keep tmp/${POP}_${TRAIT}_testing_${CV} --make-bed --out tmp/${TEST}
software/LDAK/ldak5.linux --calc-blups $DIR/LDAK/${TRAIT}_${CV}_${MODEL} --remlfile $DIR/LDAK/${TRAIT}_${CV}_${MODEL}.reml --grm results/ldak_kinships --bfile tmp/${TEST} --check-root NO


## make better results files
grep "^Her\|^Com"  $DIR/LDAK/${TRAIT}_${CV}_${MODEL}.reml  >  $DIR/LDAK/${TRAIT}_${CV}_${MODEL}.h2
grep "^LRT_P"  $DIR/LDAK/${TRAIT}_${CV}_${MODEL}.reml > $DIR/LDAK/${TRAIT}_${CV}_${MODEL}.p 


### needs an apply step to the testing set
#software/plink1.9b6.10 --bfile data/data --keep tmp/${POP}_${TRAIT}_testing_${CV} --make-bed --out tmp/${TEST}
#software/LDAK/ldak5.linux --calc-blups $DIR/LDAK/${TRAIT}_${CV}_${MODEL} --remlfile $DIR/LDAK/${TRAIT}_${CV}_${MODEL}.reml --grm $DIR/LDAK/${TRAIT}_${CV}_kinships --bfile tmp/${TEST} 
