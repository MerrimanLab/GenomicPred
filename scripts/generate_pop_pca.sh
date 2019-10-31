### preparation of phenotypes and genotypes
### within R run the models and generate the residuals SEE MARKDOWN MODELS document append all residuals as additional phenotypes to the data.fam file

POP=$1


### sort and keep our population
mkdir -p tmp
plink2 --bfile data/data --keep data/keep${POP}.txt --maf 0.01 --geno 0.05 --make-bed --out tmp/${POP}_sorteddata

######################## GCTA
#grm
# only run this line once per population to save time
software/gcta64 --bfile tmp/${POP}_sorteddata --autosome --make-grm --out results/${POP}_gcta_grm

######################## PCAs
### calculate principal components for the population using the independent markers
plink2 --bfile tmp/${POP}_sorteddata --pca 10 --out results/${POP}_pcafile --extract data/data_pca_markers.prune.in

