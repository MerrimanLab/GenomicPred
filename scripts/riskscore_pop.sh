# assume a directory structure with software, data directories
# data contains keepfiles for lists of samples labelled keep????.txt and bed, bim, fam files. also contains a residuals.csv
# with ID and columns of residuals
# software contains the GCTA, LDAK and BayesR tools
# run commands from the base directory, script can be kept in scripts
# variable to create and output folder for each run
#
# this version is for a single population and a single trait, pass population and trait in as variables in the future



### pass in an argument making a batch/output directory for each run
OUTPUT=output
POP=nph
TRAIT=height
DIR=$OUTPUT"_"$POP"_"$TRAIT

mkdir $DIR $DIR/bayesR $DIR/LDAK $DIR/GCTA
 
### prune and sort the data
# prune to only those with residuals
# residual are population specific with PCAs included in the model outside this script.
# combine residuals to fam file
# this step need to be repeated for each of the groups at bayesR section
# columns 8-12 are the FIVE residuals
# height, egfr, serumurate, diabetes and gout in that order


cat tmp/residuals.csv | awk '{ print($1, $1)}' > tmp/trainfile.txt
# check order of filtering ie maf, geno, people
plink2 --bfile data/data --keep tmp/trainfile.txt --maf 0.01 --geno 0.05 --make-bed --out tmp/traindata

join -1 1 -2 1 -o 1.1 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 -e "NA" <(sort -k 1 tmp/traindata.fam) <(sort -k 1 tmp/residuals.csv) > dummy

mv dummy tmp/traindata.fam


######################## GCTA
#grm
# only run this line once per population to save time
# transfered to the phenoprep script

# software/gcta64 --bfile tmp/traindata --autosome --make-grm --out $DIR/GCTA/grm

#reml
# $(seq 1 to how many trait/residual columns 
#parallel "nice -n 10 software/gcta64 --reml --grm $DIR/GCTA/grm --pheno tmp/traindata.fam --mpheno {} --prevalence 0.15 --out $DIR/GCTA/$TRAIT" ::: $(seq 1 7)
parallel "nice -n 10 software/gcta64 --reml-pred-rand --grm $DIR/GCTA/grm --pheno tmp/traindata.fam --mpheno {} --out $DIR/GCTA/$TRAIT{}" ::: $(seq 1 7)

# One GRM (case-control studies)
# parallel "nice -n 10 software/gcta64 --reml-pred-rand --grm $DIR/GCTA/grm --pheno tmp/traindata.fam --mpheno {} --prevalence 0.1 --out $DIR/GCTA/$TRAIT{1}" ::: $(seq 1 7)

# BLUP solutions for the SNP effects
plink2 --bfile data/data --keep tmp/trainfile.txt --maf 0.01 --geno 0.05 --make-bed --out tmp/traindata
parallel "nice -n 10 software/gcta64 --bfile tmp/traindata --blup-snp $DIR/GCTA/$TRAIT{}.indi.blp --autosome --out $DIR/GCTA/$TRAIT{}" ::: $(seq 1 7)

# Then use plink --score $DIR/GCTA/height1.snp.blp 1 2 3 to do the prediction on the test set, ie bfile for the test set
parallel "nice -n 10 plink2 --noweb --bfile tmp/testdata --score $DIR/GCTA/$TRAIT{}.snp.blp 1 2 3 --out $DIR/GCTA/$TRAIT{}" ::: $(seq 1 7)


####cvBLUP
# To obtain cvBLUP solutions for the genetic values of individuals
#parallel "nice -n 10 software/gcta64 --reml --grm $DIR/GCTA/grm --pheno tmp/traindata.fam --cvblup --mpheno {} --out $DIR/GCTA/$TRAIT{}" ::: $(seq 1 7)

# To obtain cvBLUP solutions for the SNP effects
# software/gcta64 --bfile tmp/traindata --update-freq reference.frq --blup-snp $DIR/GCTA/$TRAIT{}.indi.cvblp --out $DIR/GCTA/$TRAIT{}" ::: $(seq 1 7)

# To compute the polygenic risk score (PRS) in the discovery or an independent sample
# plink --bfile geno_to_predict --score test.snp.blp 1 2 3



####################### LDAK 
### calculate the weights and kinships for LDAK prior to GRM
software/LDAK/ldak5.linux --cut-weights $DIR/LDAK/sections --bfile tmp/traindata

software/LDAK/ldak5.linux --calc-weights-all $DIR/LDAK/sections --bfile tmp/traindata

software/LDAK/ldak5.linux --calc-kins-direct $DIR/LDAK/kinships --bfile tmp/traindata --weights $DIR/LDAK/sections/weights.short --power -0.25

### reml
parallel "nice -n 10 software/LDAK/ldak5.linux --reml $DIR/LDAK/$TRAIT{} --pheno tmp/traindata.fam --mpheno {} --grm $DIR/LDAK/kinships" ::: $(seq 1 7)

### blups
parallel "nice -n 10 software/LDAK/ldak5.linux --calc-blups $DIR/LDAK/$TRAIT{} --remlfile $DIR/LDAK/$TRAIT{}.reml --grm $DIR/LDAK/kinships --bfile tmp/traindata --check-root NO" ::: $(seq 1 7)



###################### bayesR

# run bayes
# need 3 blank columns first as bayes counts from the 6th not the third
join -1 1 -2 1 -o 1.1 2.1 2.1 2.1 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 -e "NA" <(sort -k 1 tmp/traindata.fam) <(sort -k 1 tmp/residuals.csv) -t $'\t' > dummy
mv dummy tmp/traindata.fam

parallel "nice -n 10 bayesR -bfile tmp/traindata -out $DIR/bayesR/$TRAIT{} -numit 10000 -burnin 2000 -n {} -seed 333" ::: $(seq 1 7)

parallel "nice -n 10 bayesR -bfile tmp/testdata -out $DIR/bayesR/$TRAIT{}.2 -predict -model $DIR/bayesR/$TRAIT{}.model -freq $DIR/bayesR/$TRAIT{}.frq -param $DIR/bayesR/$TRAIT{}.param" ::: $(seq 1 7)


###################### GCTB


