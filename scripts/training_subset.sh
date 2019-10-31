cv_training=$(basename $1)

# need to join based on number fo models 2.2 - 2.8  was for 7 models
plink1.9b6.10 --bfile data/data --keep tmp/${cv_training} --make-bed --out tmp/${cv_training}
join -1 1 -2 1 -o 1.1 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 -e "NA" <(sort -k 1 tmp/${cv_training}.fam) <(sort -k 1 tmp/${cv_training}_residuals.txt) > ${cv_training}_dummy
mv tmp/${cv_training}.fam tmp/${cv_training}.fam.bak
mv ${cv_training}_dummy tmp/${cv_training}.fam

