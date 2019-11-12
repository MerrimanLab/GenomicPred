
BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
MODEL=$2
PHENOCOL=$(echo $MODEL + 4 | bc)
TEST=${POP}_${TRAIT}_testing_${CV}
DIR=results/${POP}_${TRAIT}
REGRESSION=$(grep -w "$TRAIT" data/pop_trait_models.csv | cut -d',' -f2)

echo "****** $REGRESSION ******"

######################## GCTA
#grm only run this line once per population to save time
# transfered to the phenoprep script

# software/gcta64 --bfile tmp/ --autosome --make-grm --out $DIR/GCTA/grm

#reml
# $(seq 1 to how many trait/residual columns 
software/gcta64 --reml --reml-pred-rand --grm results/${POP}_gcta_grm --pheno tmp/${BFILE}.pheno --mpheno ${PHENOCOL} --out ${DIR}/GCTA/${TRAIT}_${CV}_${MODEL}



# BLUP solutions for the SNP effects
#software/plink1.9b6.10 --bfile data/data --keep tmp/$BFILE --maf 0.01 --geno 0.05 --make-bed --out tmp/$BFILE
software/gcta64 --bfile tmp/$BFILE --blup-snp $DIR/GCTA/${TRAIT}_${CV}_${MODEL}.indi.blp --autosome --out $DIR/GCTA/${TRAIT}_${CV}_${MODEL}

cat  ${DIR}/GCTA/${TRAIT}_${CV}_${MODEL}.hsq |tr -s " " | tr " " "\t" > ${DIR}/GCTA/${TRAIT}_${CV}_${MODEL}.hsq.tsv


# Then use plink --score $DIR/GCTA/height1.snp.blp 1 2 3 to do the prediction on the test set, ie bfile for the test set
software/plink1.9b6.10 --bfile data/data --keep tmp/${POP}_${TRAIT}_testing_${CV} --make-bed --out tmp/${POP}_${TRAIT}_testing_${CV}
software/plink1.9b6.10 --bfile tmp/${POP}_${TRAIT}_testing_${CV} --score $DIR/GCTA/${TRAIT}_${CV}_${MODEL}.snp.blp 1 2 3 --out $DIR/GCTA/${TRAIT}_testing_${CV}_${MODEL}



