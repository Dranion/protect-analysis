source venv/bin/activate
ProTECT --config mustard_chr6.yaml --workDir /scratch/drkthomp/workDir /scratch/drkthomp/jobStoreChr6 |& tee errors/$(date '+%Y-%m-%d-%H-%M-%S').txt
