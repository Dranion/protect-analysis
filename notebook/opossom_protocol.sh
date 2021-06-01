# YAY INSTALLS 
#yay -S pip samtools htslib

source venv/bin/activate 
# check for RNA Tumor bam 
homedir=$(pwd)
datadir=/scratch/drkthomp/fullbams
DATA=https://xfer.genome.wustl.edu/gxfer1/project/gms/testdata/bams/hcc1395
#RNA_TUMOR_BASE=gerald_C1TD1ACXX_8_ACAGTG
#RNA_TUMOR=/scratch/drkthomp/fullbams/${RNA_TUMOR_BASE}.sorted.bam
for i in "X" "Y" "M"
do
RNA_TUMOR_BASE=rna_chr${i}
RNA_TUMOR=${datadir}/${RNA_TUMOR_BASE}.bam
#RNA_TUMOR_MD=/scratch/drkthomp/${RNA_TUMOR_BASE}md.bam
RNA_TUMOR_MD=${datadir}/callmd_${RNA_TUMOR_BASE}.bam
RNA_NORMAL=/scratch/drkthomp/fullbams/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
PICARD=picard.jar 
echo "============"
echo "====chr${i}===="
echo "============"

if [ -f "$PICARD" ]; then
      echo "$PICARD exists."
    else
      wget https://github.com/broadinstitute/picard/releases/download/2.23.9/picard.jar $PICARD
fi

if [ -f "$RNA_NORMAL" ]; then
    echo "$RNA_NORMAL exists."
   else
    wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz ${RNA_NORMAL}.gz 
    gunzip ${RNA_NORMAL}.gz
fi

echo "====CALMD"
if [ -f "$RNA_TUMOR_MD" ]; then
      echo "$RNA_TUMOR_MD exists."
    else 
      samtools calmd ${RNA_TUMOR} ${RNA_NORMAL} > ${RNA_TUMOR_MD}
fi

echo "====INDEX"
if [ -f "${RNA_TUMOR}.bai" ]; then
      echo "${RNA_TUMOR}.bai exists."
    else
      samtools index -b $RNA_TUMOR
      echo "${RNA_TUMOR}.bai created"
fi

echo "====OPOSSUM"
PROCESSED=${datadir}/opossum_${RNA_TUMOR_BASE}.bam
OPOSSUM=Opossum.py
if [ -f "$OPOSSUM" ]; then 
    echo "$OPOSSUM exists."
  else
    wget -O $OPOSSUM https://raw.githubusercontent.com/BSGOxford/Opossum/master/Opossum.py
    2to3 -w $OPOSSUM 
fi
# pip dependencies for opossum 
pip install pysam 

#woot 
if [ -f "${PROCESSED}" ]; then
    echo "${PROCESSED} exists."
  else
    python $OPOSSUM --BamFile=$RNA_TUMOR --OutFile=$PROCESSED --SoftClipsExist=True 
fi 
# okay install HTSLib
HTSLIB_TAR=htslib-1.11
if [ -f "${HTSLIB_TAR}.tar.bz2" ]; then
    echo "${HTSLIB_TAR} exists."
  else
    wget -O ${HTSLIB_TAR}.tar.bz2 https://github.com/samtools/htslib/releases/download/1.11/htslib-1.11.tar.bz2
    tar -xf ${HTSLIB_TAR}.tar.bz2
    cd $HTSLIB_TAR
    make install prefix=${homedir}/htslib
    # had to run these manually
fi

echo "====PLATYPUS"
export C_INCLUDE_PATH=${homedir}/htslib/include
export LIBRARY_PATH=${homedir}/htslib/lib
export LD_LIBRARY_PATH=${homedir}/htslib/lib
cd $homedir
PLATYPUS_DIR=platypus
PLATYPUS=${PLATYPUS_DIR}/bin/Platypus.py
if [ -f "$PLATYPUS" ]; then
    echo "$PLATYPUS exists."
  else
    git clone --depth=1 --branch=master https://github.com/andyrimmer/Platypus.git ${PLATYPUS_DIR}
    rm -rf ./${PLATYPUS_DIR}/.git
    cd ${PLATYPUS_DIR}
    make
fi
cd $homedir

#2to3 -w ${PLATYPUS_DIR}/
# first is suggested with opossum
python2 ~/miniconda3/envs/platypus/share/platypus-variant-0.8.1.2-0/Platypus.py callVariants --bamFiles=${PROCESSED} --refFile=${RNA_NORMAL} --filterDuplicates=0 --minMapQual=0 --minFlank=0 --maxReadLength=500 --minGoodQualBases=10 --minBaseQual=25 --output=${datadir}/variants_opossum_${RNA_TUMOR_BASE}.vcf

done 


