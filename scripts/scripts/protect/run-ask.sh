source venv/bin/activate
read -p 'config name: ' name
toil clean /scratch/drkthomp/${name}Store
mkdir /scratch/drkthomp/${name}Work
ProTECT --config ${name}.yaml --workDir /scratch/drkthomp/${name}Work /scratch/drkthomp/${name}Store |& tee errors/$(date '+%Y-%m-%d-%H-%M-%S').txt
