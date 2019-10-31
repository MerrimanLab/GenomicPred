cv_training=$(basename $1)

# need to join based on number fo models 2.2 - 2.8  was for 7 models
software/plink1.9b6.10 --bfile data/data --keep tmp/${cv_training} --make-bed --out tmp/${cv_training}
#join -1 1 -2 1 -o 1.1 $(head -1 tmp/${cv_training}_residuals.txt | awk '{ for(i=1;i<=NF;i++){print "2."i}}' | tr '\n' ' ') -e "NA" <(sort -k 1 tmp/${cv_training}.fam) <(sort -k 1 tmp/${cv_training}_residuals.txt) >  tmp/${cv_training}.pheno

# this should join using IID from fam and IID from the pheno (in pheno first and second cols are duplicated) includes entire fam in output so need to adjust accordingly for model numbers (-6 cols)
join -1 2 -2 1 -o auto -e "NA" <(sort -k1 tmp/${cv_training}.fam) <(sort -k1 tmp/${cv_training}_residuals.txt | cut -f2- ) -t $'\t' > tmp/${cv_training}.pheno 
