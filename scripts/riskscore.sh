# assume a directory structure with software, data directories
# data contains keepfiles for lists of samples labelled keep????.txt and bed, bim, fam files. also contains a residuals.csv
# with ID and columns of residuals
# software contains the GCTA, LDAK and BayesR tools
# run commands from the base directory, script can be kept in scripts
# variable to create and output folder for each run
#


### pass in an argument making a batch/output directory for each run
OUTPUT=output

mkdir $OUTPUT/bayesR $OUTPUT/LDAK $OUTPUT/GCTA

### prune and sort the data
#prune to only those with residuals
cat residuals | awk '{print $1, $1}' > keepall.txt

plink2 --bfile data/data --keep data/keepall.txt --maf 0.001 --geno 0.05 --make-bed --out data/sorteddata

# combine residuals to fam file
# this step need to be repeated for each of the groups at bayesR section
# columns 8-12 are the FIVE residuals
# height, egfr, serumurate, diabetes and gout in that order

paste data/sorteddata.fam data/residuals.csv | awk '{print $1, $2, $3, $4, $5, $8, $9, $10, $11, $12}' > data/test.fam

######################## GCTA
#grm
parallel -j4 "software/gcta64 --bfile data/sorteddata --keep data/keep{}.txt --autosome --maf 0.01 --make-grm --out $OUTPUT/GCTA/{}" ::: east west poly euro

#reml
parallel -j4 "software/gcta64 --reml --grm $OUPUT/GCTA/{1} --keep data/keep{}.txt --pheno data/{1}.fam --mpheno {2} --prevalence 0.15 --out $OUTPUT/GCTA/{1}_{2}" ::: east west poly euro ::: $(seq 1 5)

# One GRM (quantitative traits)
#gcta64  --reml  --grm test --pheno test.phen  --reml-pred-rand –qcovar test_10PCs.txt  --out test
#gcta64  --reml  --grm test --pheno test.phen  --grm-adj 0  --grm-cutoff 0.05  --out test
#gcta64  --reml  --grm test --pheno test.phen  --keep test.indi.list  --grm-adj 0  --out test

# One GRM (case-control studies)
# gcta64  --reml  --grm test  --pheno test_cc.phen  --prevalence 0.01  --out test_cc
# gcta64  --reml  --grm test  --pheno test_cc.phen  --prevalence 0.01  --qcovar test_10PCs.txt  --out test_cc

# BLUP solutions for the SNP effects
gcta64  --bfile   test   --blup-snp test.indi.blp  --out test
# Then use plink --score test.snp.blp 1 2 3 

####################### LDAK

### calculate the weights and kinships for LDAK prior to GRM
parallel -j4 "software/LDAK/ldak5.linux --keep data/keep{}.txt --cut-weights $OUTPUT/LDAK/{}_sections --bfile data/sorteddata" ::: east west poly euro

parallel -j4 "software/LDAK/ldak5.linux --keep data/keep{}.txt --calc-weights-all $OUTPUT/LDAK/{}_sections --bfile data/sorteddata" ::: east west poly euro

parallel -j4 "software/LDAK/ldak5.linux --keep data/keep{}.txt --calc-kins-direct $OUTPUT/LDAK/{}_kinships --bfile data/sorteddata --weights $OUTPUT/LDAK/{}_sections/weights.short --power -0.25" ::: east west poly euro

# reml
# LDAK counts the first phenotype as colum 3 of the fam file, so 1-5 is actually probably 4, 5, 6, 7  
parallel -j4 "software/LDAK/ldak5.linux --reml $OUTPUT/LDAK/{1}_{2} --keep data/keep{1}.txt --pheno data/test.fam --mpheno {2} --grm $OUTPUT/LDAK/{1}_kinships" ::: east west poly euro ::: $(seq 4 8)

parallel -j4 "software/LDAK/ldak5.linux --calc-blups $OUTPUT/LDAK/{1}_{2} --remlfile $OUTPUT/LDAK/{1}_{2}.reml --grm $OUTPUT/LDAK/{1}_kinships --bfile data/sorteddata --check-root NO" ::: east west poly euro ::: $(seq 4 8)

###################### bayesR

# split data to the various populations
parallel -j4 "plink2 --bfile data/sorteddata --keep data/keep{}.txt --make-bed --out data/data_{}" ::: east west poly euro

# this step need to be repeated for each of the groups at bayesR section

parallel -j18 "join -1 1 -2 1 -o 1.1 2.1 1.3 1.4 1.5 2.2 2.3 2.4 2.5 2.6 -e "NA" <(sort -k 1 data/data_{}.fam) <(sort -k 1 data/residuals.csv) > tmp{}
rm data/data_{}.fam
cp tmp{} data/data_{}.fam
rm tmp{}" ::: east west poly euro



# run bayes
parallel "nice -n 10 bayesR -bfile data/data_{1} -out $OUTPUT/bayesR/{1}_{2} -numit 100000 -burnin 20000 -n {2} -seed 333" ::: east west poly euro ::: $(seq 1 5)

bayesR -bfile data/data_poly -out poly_1 -numit 100 -n 1 -burnin 20 -seed 333

###################### GCTB

