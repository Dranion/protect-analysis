source venv/bin/activate
ProTECT --config mustard_1percentbam.yaml --workDir /scratch/drkthomp/1p_workdir  /scratch/drkthomp/1p_jobStore |& tee errors/$(date '+%Y-%m-%d-%H-%M-%S').txt
