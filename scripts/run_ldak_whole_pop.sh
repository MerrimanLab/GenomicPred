### run_ldak_whole_pop.sh



BFILE=$(basename $1 .fam)


POP=$(echo $BFILE | cut -d'_' -f1)

TRAIT=$(echo $BFILE | cut -d'_' -f2)



MODEL=$2

PHENOCOL=$(echo $MODEL + 4 | bc) # ignore the first 4 columns after FID and IID



####################### LDAK 

### reml

software/LDAK/ldak5.linux --reml ${POP}_results/LDAK/${TRAIT}_${MODEL} --pheno tmp/${BFILE}.pheno --mpheno ${PHENOCOL} --grm ${POP}_results/${POP}_ldak_kinships




### blups

software/LDAK/ldak5.linux --calc-blups ${POP}_results/LDAK/${TRAIT}_${MODEL} --remlfile ${POP}_results/LDAK/${TRAIT}_${CV}_${MODEL}.reml --grm results/${POP}_ldak_kinships --bfile tmp/${BFILE} --check-root NO







## make better results files

grep "^Her\|^Com"  ${POP}_results/LDAK/${TRAIT}_${MODEL}.reml  >  ${POP}_results/LDAK/${TRAIT}_${MODEL}.h2

grep "^LRT_P"  ${POP}_results/LDAK/${TRAIT}_${MODEL}.reml > ${POP}_results/LDAK/${TRAIT}_${MODEL}.p 


