BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
MODEL=$2
TEST=${POP}_${TRAIT}_testing_${CV}
DIR=results/${POP}_${TRAIT}
REGRESSION=$(grep -w "$TRAIT" data/pop_trait_models.csv | cut -d',' -f2)


####################### LDAK 
### reml
software/LDAK/ldak5.linux --reml $DIR/LDAK/${TRAIT}_${CV}_${MODEL} --pheno tmp/${BFILE}.pheno --mpheno ${MODEL} --grm $DIR/LDAK/${TRAIT}_${CV}_kinships

### blups
software/LDAK/ldak5.linux --calc-blups $DIR/LDAK/${TRAIT}_${CV}_${MODEL} --remlfile $DIR/LDAK/${TRAIT}_${CV}_${MODEL}.reml --grm $DIR/LDAK/${TRAIT}_${CV}_kinships --bfile tmp/${POP}_${TRAIT}_testing_${CV} --check-root NO


