source venv/bin/activate
ProTECT --config mustard_variants_pretransgened.yaml --workDir /scratch/drkthomp/workDirtrans /scratch/drkthomp/jobStoretrans |& tee errors/$(date '+%Y-%m-%d-%H-%M-%S').txt
