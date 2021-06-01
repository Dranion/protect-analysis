source venv/bin/activate
ProTECT --config mustard_manyvariants_chr6.yaml --workDir /scratch/drkthomp/workVariantsDir /scratch/drkthomp/jobStoreVariants --restart |& tee errors/$(date '+%Y-%m-%d-%H-%M-%S').txt
