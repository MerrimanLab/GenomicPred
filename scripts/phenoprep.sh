### preparation of phenotypes and genotypes
### within R run the models and generate the residuals SEE MARKDOWN MODELS document append all residuals as additional phenotypes to the data.fam file

### sort and keep our population
mkdir tmp
plink2 --bfile data/data --keep data/keepnph.txt --maf 0.01 --geno 0.05 --make-bed --out tmp/sorteddata

######################## GCTA
#grm
# only run this line once per population to save time
software/gcta64 --bfile tmp/sorteddata --autosome --make-grm --out $DIR/GCTA/grm

######################## PCAs
### calculate principal components for the population
plink2 --bfile tmp/sorteddata --pca 10 --out tmp/pcafile

### run R script to create the residuals file for the model
### residuals contains trait, 0 2 ... 10 PCAS
model_residuals.R


