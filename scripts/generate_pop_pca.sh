### preparation of phenotypes and genotypes
### within R run the models and generate the residuals SEE MARKDOWN MODELS document append all residuals as additional phenotypes to the data.fam file

POP=$1
DIR=results/

### sort and keep our population
mkdir -p tmp
software/plink1.9b6.10 --bfile tmp/data_sorted --keep data/keep${POP}.txt --maf 0.01 --geno 0.05 --make-bed --out tmp/${POP}_sorteddata

######################## GCTA
#grm
# only run this line once per population to save time
software/gcta64 --bfile tmp/${POP}_sorteddata --autosome --make-grm --out results/${POP}_gcta_grm --threads 4



######################## PCAs
### calculate principal components for the population using the independent markers
software/plink1.9b6.10 --bfile tmp/${POP}_sorteddata --pca 10 --out results/${POP}_pcafile --extract data/data_pca_markers.prune.in

####################### LDAK
### calculate the weights and kinships for LDAK prior to GRM
software/LDAK/ldak5.linux --cut-weights $DIR/${POP}_ldak_sections --bfile tmp/${POP}_sorteddata

software/LDAK/ldak5.linux --calc-weights-all $DIR/${POP}_ldak_sections --bfile tmp/${POP}_sorteddata

software/LDAK/ldak5.linux --calc-kins-direct $DIR/${POP}_ldak_kinships --bfile  tmp/${POP}_sorteddata --weights $DIR/${POP}_ldak_sections/weights.short --power -0.25

