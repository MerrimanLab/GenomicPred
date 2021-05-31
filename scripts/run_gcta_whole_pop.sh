### run_gcta_whole_pop.sh

## run: bash run_gcta_whole_pop.sh BFILE MODEL

BFILE=$(basename $1 .fam)


POP=$(echo $BFILE | cut -d'_' -f1)
RESULTS=${POP}_results
TRAIT=$(echo $BFILE | cut -d'_' -f2)



MODEL=$2

PHENOCOL=$(echo $MODEL + 4 | bc)









echo "****** $REGRESSION ******"




######################## GCTA

#grm only run this line once per population to save time

# transfered to the phenoprep script




# software/gcta64 --bfile tmp/ --autosome --make-grm --out $DIR/GCTA/grm



#reml

# $(seq 1 to how many trait/residual columns 

software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno ${RESULTS}/${BFILE}.pheno --mpheno ${PHENOCOL} --out ${RESULTS}/GCTA/${TRAIT}_${MODEL} --threads 4





# BLUP solutions for the SNP effects

#software/plink1.9b6.10 --bfile data/data --keep tmp/$BFILE --maf 0.01 --geno 0.05 --make-bed --out tmp/$BFILE

software/gcta64 --bfile tmp/$BFILE --blup-snp ${RESULTS}/GCTA/${TRAIT}_${MODEL}.indi.blp --autosome --out ${RESULTS}/GCTA/${TRAIT}_${MODEL} --threads 4



cat  ${RESULTS}/GCTA/${TRAIT}_${MODEL}.hsq |tr -s " " | tr " " "\t" > ${RESULTS}/GCTA/${TRAIT}_${MODEL}.hsq.tsv


