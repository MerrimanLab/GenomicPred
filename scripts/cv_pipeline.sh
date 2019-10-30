# create the PCAs for the pops of interest

parallel 'generate_pop_pca.sh {1} {2}' ::: nph east west euro ::: keepnph.txt ...


# create the cv splits and residuals for all pops and trait combos

CV=5 # number fo folds for cross validation

for POP in nph east west euro 
do
	while read line
	do
		TRAIT=$(echo $line | cut -f1)
		REGRESSION_TYPE=$(echo $line | cut -f2)
		generate_models.sh ${POP} ${TRAIT} ${REGRESSION_TYPE} ${CV}
	done < pop_trait_models.txt
done

# run bayesR, GCTA and LDAK for each combo and all CVs

parallel 'run_gcta.sh {1} {2} ' ::: nph east west euro ::: $(cat pop_trait_models.txt | cut -f1 | tr "\n" " ")
parallel 'run_ldak.sh {1} {2} ' ::: nph east west euro ::: $(cat pop_trait_models.txt | cut -f1 | tr "\n" " ")
parallel 'run_bayesR.sh {1} {2} ' ::: nph east west euro ::: $(cat pop_trait_models.txt | cut -f1 | tr "\n" " ")

