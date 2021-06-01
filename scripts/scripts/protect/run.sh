source venv/bin/activate
toil clean /scratch/drkthomp/jobStore
ProTECT --config mustard_fullbam_variants.yaml --workDir /scratch/drkthomp/workDir2 /scratch/drkthomp/jobStore |& tee errors/$(date '+%Y-%m-%d-%H-%M-%S').txt
