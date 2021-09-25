for origkeep in data/{east,euro,west,westnopuka,nph}pca.keep
do
     Rscript scripts/create_cv.R --keep $origkeep --outdir data/ --cv 5 
done

for keepfile in $(ls data/*.keep)
do
    echo ${keepfile}
    POP=$(basename -s .keep ${keepfile} )
    bash scripts/whole_pop_pipeline.sh data/data_filtered $POP 1> ${POP}.pre.log 2>> ${POP}.pre.log
    mv ${POP}_results ${POP}_results_pre
    bash scripts/whole_pop_pipeline.sh data/dataPolySNPS $POP 1> ${POP}.post.log 2>> ${POP}.post.log
    mv ${POP}_results ${POP}_results_post
done

bash scripts/cv_make_profiles.sh
