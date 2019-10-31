BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
TEST=${POP}_${TRAIT}_testing_${CV}
DIR=results/${POP}_${TRAIT}
REGRESSION=$(grep -w "$TRAIT" data/pop_trait_models.csv | cut -d',' -f2)

### calculate the weights and kinships for LDAK prior to GRM
software/LDAK/ldak5.linux --cut-weights $DIR/LDAK/${TRAIT}_${CV}_sections --bfile tmp/${BFILE}

software/LDAK/ldak5.linux --calc-weights-all $DIR/LDAK/${TRAIT}_${CV}_sections --bfile tmp/${BFILE}

software/LDAK/ldak5.linux --calc-kins-direct $DIR/LDAK/${TRAIT}_${CV}_kinships --bfile tmp/${BFILE} --weights $DIR/LDAK/${TRAIT}_${CV}_sections/weights.short --power -0.25



