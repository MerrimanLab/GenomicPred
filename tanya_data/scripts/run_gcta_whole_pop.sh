### run_gcta_whole_pop.sh

## run: bash run_gcta_whole_pop.sh BFILE MODEL

BFILE=$(basename $1 .fam)


POP=$(echo $BFILE | cut -d'_' -f1)

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

software/gcta64 --reml --reml-pred-rand --grm ${POP}_results/${POP}_gcta_grm --pheno tmp/${BFILE}.pheno --mpheno ${PHENOCOL} --out ${POP}_results/GCTA/${TRAIT}_${MODEL} --threads 4





# BLUP solutions for the SNP effects

#software/plink1.9b6.10 --bfile data/data --keep tmp/$BFILE --maf 0.01 --geno 0.05 --make-bed --out tmp/$BFILE

software/gcta64 --bfile tmp/$BFILE --blup-snp ${POP}_results/GCTA/${TRAIT}_${MODEL}.indi.blp --autosome --out ${POP}_results/GCTA/${TRAIT}_${MODEL} --threads 4



cat  ${POP}_results/GCTA/${TRAIT}_${MODEL}.hsq |tr -s " " | tr " " "\t" > ${POP}_results/GCTA/${TRAIT}_${MODEL}.hsq.tsv


