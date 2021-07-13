
POP=nphpca
RESULTS=${POP}_results
mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
for covar in ls ${RESULTS}/*.covar
do
 TRAIT=gout
 MODEL=$(basename ${covar} .covar)
 PREV=0.049
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
 software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4

done > ${POP}_${TRAIT}.log

for covar in ls ${RESULTS}/*.covar
do
 TRAIT=t2d
 MODEL=$(basename ${covar} .covar)
 PREV=0.078
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
  software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4
done > ${POP}_${TRAIT}.log


## East

POP=eastpca
RESULTS=${POP}_results
mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
for covar in ls ${RESULTS}/*.covar
do
 TRAIT=gout
 MODEL=$(basename ${covar} .covar)
 PREV=0.049
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
 software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4

done > ${POP}_${TRAIT}.log

for covar in ls ${RESULTS}/*.covar
do
 TRAIT=t2d
 MODEL=$(basename ${covar} .covar)
 PREV=0.078
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
  software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4
done > ${POP}_${TRAIT}.log

## West

POP=westpca
RESULTS=${POP}_results
mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
for covar in ls ${RESULTS}/*.covar
do
 TRAIT=gout
 MODEL=$(basename ${covar} .covar)
 PREV=0.049
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
 software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4

done > ${POP}_${TRAIT}.log

for covar in ls ${RESULTS}/*.covar
do
 TRAIT=t2d
 MODEL=$(basename ${covar} .covar)
 PREV=0.078
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
  software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4
done > ${POP}_${TRAIT}.log


## Euro


POP=europca
RESULTS=${POP}_results
mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
for covar in ls ${RESULTS}/*.covar
do
 TRAIT=gout
 MODEL=$(basename ${covar} .covar)
 PREV=0.049
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
 software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4

done > ${POP}_${TRAIT}.log

for covar in ls ${RESULTS}/*.covar
do
 TRAIT=t2d
 MODEL=$(basename ${covar} .covar)
 PREV=0.078
 mkdir -p ${RESULTS}/{LDAK,GCTA}/${TRAIT}
 software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}/${MODEL} --pheno data/tanya_${TRAIT}.pheno  --grm ${RESULTS}/${POP}_ldak_kinships --prevalence ${PREV} --covar ${covar}
  software/gcta64 --reml --reml-pred-rand --grm ${RESULTS}/${POP}_gcta_grm --pheno data/tanya_${TRAIT}.pheno --prevalence ${PREV} --out ${RESULTS}/GCTA/${TRAIT}/${MODEL} --qcovar ${covar} --threads 4
done > ${POP}_${TRAIT}.log


#Code for transferring directories to local computer..
# scp -r benrangihuna@biochemcompute1.uod.otago.ac.nz:/Volumes/scratch/merrimanlab/ben/genomic_predictions/{nph,euro,west,east}pca_results ~/Documents/genomic_prediction_results/




