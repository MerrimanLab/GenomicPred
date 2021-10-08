# for each training blup file
# find the matching test files and use the training blups to predict on
# the test data

Rscript -e 'library(readr);library(dplyr); read_csv("data/tanya_data.csv") %>% transmute(FID = PATIENT, IID = PATIENT, SEX) %>% write_tsv("data/tanya_data.sex", col_names = FALSE)'
cat data/*.keep | sort -u | cut -f2 > data/all_keep_IID.txt                                                                           
grep -Fwf data/all_keep_IID.txt data/tanya_data.sex | grep -v "Blank" | sed 's/NA/0/g' > data/tanya_data.keep.sex    


## GCTA
mkdir -p gcta_pre gcta_post
for SNPBLUP in $(find ./ -type f -name \*snp.blp | sort | sed 's%\./%%g' | grep 'training') 
do
    PHENO=$(basename -s .snp.blp ${SNPBLUP} | sed 's/_.*//g')
    MODEL=$(basename -s .snp.blp ${SNPBLUP} |  sed "s/${PHENO}_//g")
    TRAIN_DIR=$(echo ${SNPBLUP} | cut -d'/' -f1 )
    PREPOST=$(echo ${TRAIN_DIR} | sed 's/.*results_//g')
    TRAIN=$(echo ${SNPBLUP} | cut -d'/' -f1 | sed 's/_results.*//g')
    TEST=$(echo ${TRAIN} | sed 's/training/testing/g')
    TEST_DIR=$(echo ${TRAIN_DIR} | sed 's/training/testing/g')
    TEST_KEEPFILE="data/${TEST}.keep"
    
    TEST_PLINK=data/data_filtered
    if [[ $PREPOST == "post" ]]
    then
        TEST_PLINK=data/dataPolySNPS
    fi
    
    
    # nb the _gcta and _ldak version of the same model pheno file are identical
    # --prune removes people with no phenotype
    software/plink1.9b6.10 --bfile ${TEST_PLINK} --keep ${TEST_KEEPFILE} --pheno ${TEST_DIR}/${TEST}_${PHENO}.pheno${MODEL}_gcta --out gcta_${PREPOST}/${TEST}_${PHENO}_model${MODEL} --make-bed --prune --update-sex data/tanya_data.keep.sex --allow-no-sex
    
    software/plink1.9b6.10 --bfile gcta_${PREPOST}/${TEST}_${PHENO}_model${MODEL} --score ${SNPBLUP} 1 2 3 --out gcta_${PREPOST}/${TEST}_${PREPOST}_${PHENO}_model${MODEL} 
done


## LDAK
mkdir -p ldak_pre ldak_post
for BLUP in $(find ./ -type f -name \*.blup | sort | sed 's%\./%%g' | grep 'training') 
do
    PHENO=$(basename -s .blup ${BLUP} | sed 's/_.*//g')
    MODEL=$(basename -s .blup ${BLUP} |  sed "s/${PHENO}_//g")
    TRAIN_DIR=$(echo ${BLUP} | cut -d'/' -f1 )
    PREPOST=$(echo ${TRAIN_DIR} | sed 's/.*results_//g')
    TRAIN=$(echo ${BLUP} | cut -d'/' -f1 | sed 's/_results.*//g')
    TEST=$(echo ${TRAIN} | sed 's/training/testing/g')
    TEST_DIR=$(echo ${TRAIN_DIR} | sed 's/training/testing/g')
    TEST_KEEPFILE="data/${TEST}.keep"
    
    TEST_PLINK=data/data_filtered
    if [[ $PREPOST == "post" ]]
    then
        TEST_PLINK=data/dataPolySNPS
    fi
    
    
    # nb the _gcta and _ldak version of the same model pheno file are identical
    software/plink1.9b6.10 --bfile ${TEST_PLINK} --keep ${TEST_KEEPFILE} --pheno ${TEST_DIR}/${TEST}_${PHENO}.pheno${MODEL}_ldak --out ldak_${PREPOST}/${TEST}_${PHENO}_model${MODEL} --make-bed --prune --update-sex data/tanya_data.keep.sex --allow-no-sex
    
    software/LDAK/ldak5.linux --calc-scores ldak_${PREPOST}/${TEST}_${PHENO}_model${MODEL} --scorefile ${BLUP} --bfile ldak_${PREPOST}/${TEST}_${PHENO}_model${MODEL} --power 0
done
