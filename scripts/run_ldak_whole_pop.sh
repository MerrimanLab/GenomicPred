### run_ldak_whole_pop.sh



BFILE=$(basename $1 .fam)


POP=$(echo $BFILE | cut -d'_' -f1)
RESULTS=${POP}_results
TRAIT=$(echo $BFILE | cut -d'_' -f2)



MODEL=$2

PHENOCOL=$(echo $MODEL + 7 | bc) # ignore the first 7 columns: FID IID MID PID SEX AFF TRUEPHENOVALUE
cut -d' ' -f1,2,${PHENOCOL} <  ${RESULTS}/${BFILE}.pheno >  ${RESULTS}/${BFILE}.pheno${MODEL}_ldak


####################### LDAK 

### reml

software/LDAK/ldak5.linux --reml ${RESULTS}/LDAK/${TRAIT}_${MODEL} --pheno ${RESULTS}/${BFILE}.pheno${MODEL}_ldak  --grm ${RESULTS}/${POP}_ldak_kinships




### blups

software/LDAK/ldak5.linux --calc-blups ${RESULTS}/LDAK/${TRAIT}_${MODEL} --remlfile ${RESULTS}/LDAK/${TRAIT}_${MODEL}.reml --grm ${RESULTS}/${POP}_ldak_kinships --bfile tmp/${BFILE} --check-root NO







## make better results files

grep "^Her\|^Com"  ${RESULTS}/LDAK/${TRAIT}_${MODEL}.reml  >  ${RESULTS}/LDAK/${TRAIT}_${MODEL}.h2

grep "^LRT_P"  ${RESULTS}/LDAK/${TRAIT}_${MODEL}.reml > ${RESULTS}/LDAK/${TRAIT}_${MODEL}.p 


