### pass in an argument making a batch/output directory for each run
OUTPUT=results
POP=$1
TRAIT=$2
REGRESSION_TYPE=$3
CV_N=$4
DIR="${POP}"_"${TRAIT}"


mkdir -p  results/$DIR/{bayesR,LDAK,GCTA}


# create the residuals for each training set for a trait/pop combo
Rscript scripts/model_residuals.R --trait ${TRAIT} -p ${POP} -r ${REGRESSION_TYPE} --out_dir results/${DIR} --cv ${CV_N}


