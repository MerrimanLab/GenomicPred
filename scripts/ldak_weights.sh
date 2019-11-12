DIR=results/


### calculate the weights and kinships for LDAK prior to GRM
software/LDAK/ldak5.linux --cut-weights $DIR/ldak_sections --bfile data/data

software/LDAK/ldak5.linux --calc-weights-all $DIR/ldak_sections --bfile data/data

software/LDAK/ldak5.linux --calc-kins-direct $DIR/ldak_kinships --bfile data/data --weights $DIR/ldak_sections/weights.short --power -0.25



