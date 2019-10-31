
BFILE=$(basename $1 .fam)
POP=$(echo $BFILE | cut -d'_' -f1)
TRAIT=$(echo $BFILE | cut -d'_' -f2)
CV=$(echo $BFILE | cut -d'_' -f4)
MODEL=$2
TEST=${POP}_${TRAIT}_testing_${CV}
DIR=results/${POP}_${TRAIT}

######################## GCTA
#grm only run this line once per population to save time
# transfered to the phenoprep script

# software/gcta64 --bfile tmp/ --autosome --make-grm --out $DIR/GCTA/grm

#reml
# $(seq 1 to how many trait/residual columns 
#software/gcta64 --reml --grm results/${POP}_gcta_grm --pheno tmp/${BFILE}.fam --mpheno $MODEL --prevalence 0.15 --out $DIR/GCTA/${TRAIT}_${CV}_${MODEL}
software/gcta64 --reml-pred-rand --grm results/${POP}_gcta_grm --pheno tmp/${BFILE}.fam --mpheno ${MODEL} --out ${DIR}/GCTA/${TRAIT}_${CV}_${MODEL}

### One GRM (case-control studies)
### parallel "software/gcta64 --reml-pred-rand --grm $DIR/GCTA/grm --pheno tmp/traindata.fam --mpheno {} --prevalence 0.1 --out $DIR/GCTA/$TRAIT{1}" ::: $(seq 1 7)

# BLUP solutions for the SNP effects
plink1.9b6.10 --bfile data/data --keep tmp/$TEST --maf 0.01 --geno 0.05 --make-bed --out tmp/$TEST
software/gcta64 --bfile tmp/$BFILE --blup-snp $DIR/GCTA/${TRAIT}_${CV}_${MODEL}.indi.blp --autosome --out $DIR/GCTA/${TRAIT}_${CV}_${MODEL}

# Then use plink --score $DIR/GCTA/height1.snp.blp 1 2 3 to do the prediction on the test set, ie bfile for the test set
plink1.9b6.10 --bfile tmp/${POP}_${TRAIT}_testing_${CV} --score $DIR/GCTA/${TRAIT}_${CV}_${MODEL}.snp.blp 1 2 3 --out $DIR/GCTA/${TRAIT}_${CV}_${MODEL}


