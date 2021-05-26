#!/bin/bash

###################################################################
# Script Name    : genome_ref_cal.sh
# Date           : 2021-05-22
# Version        : 3.5
# Author         : Dietmar Fernandez (dietmar.fernandez@crg.eu)
#                : Revised by Manuel Rueda (manuel.rueda@crg.eu)
# usage          : bash genome_ref_cal.sh input.vcf.gz
# Description    : This script allows to calculate the genome reference from a vcf file. We extracted unique nucleotides per pos in hg17, grch37, grch38 and created a dictionary.
# Description    : It searchs for matches in 3 dictionaries (one per reference genome) and takes the one having matches (only one) generating a text file with the result.
# Requirements   : gzip (tested version 1.10), awk (tested version Awk 5.0.1), grep (tested version 3.4), sed (tested sed (GNU sed) 4.7), wc (tested version (GNU coreutils) 8.30).
###################################################################

set -eu
export LC_ALL=C

# Variables
rand_var=10000 # 10K random variants
match=100      # Nuber of matches for the grep   
genomes=("hg17" "grch37" "grch38") # reference genomes

# Path for dictionary files
#path_dic="./ref_dics"
path_dic="/media/mrueda/4TB/CRG_EGA/Project_QC/EGA_genomeref/EGA_genomeref-main/ref_dics"

function usage {

    USAGE="""
    Usage: $0 input.vcf.gz
    """
    echo "$USAGE"
    exit 1
}

# Check arguments
if [ $# -eq 0 ]
 then
  usage
fi

# Load arguments
input_vcf=$1
base=$(basename $input_vcf .vcf.gz)

# We get an id from bash process to be used when we append contents ( >> $$.file ) 
echo "Job id $$"

# STEP 1 - We get the list of chromosomes from the vcf along with the number of variants sorted reverse:
zcat $input_vcf | awk '{print $1}' | grep -v '#' | sort | uniq -c | sort -r -n > $base.chr

# STEP 2 - We read the input vcf once and split it by CHROM
zcat $input_vcf | grep -v '^#' | cut -f1,2,4 | awk '{print>$1".variants"}'

# STEP 3 - For each chromosome we query a subset of variants against the dictionary
for chr in $(awk '{print $2}' $base.chr)
do
  echo "Running chromosome $chr..."

  # First we select 10K random variants
  shuf -n $rand_var $chr.variants | sort | sed 's/chr//g' > subset.$chr.variants

  # And finally we look for the first 100 matches in the 3 dictionaries
  for ref in ${genomes[@]}
  do
   ( echo -n "$chr "; zgrep -m $match -c -Ef subset.$chr.variants $path_dic/subset.chr$chr.final.dic_$ref || echo '0' ) >> $$.matches_$ref
  done 
done

# STEP 4 - We analyze the results
for ref in ${genomes[@]}
do
        tot_var=$(awk '{sum+=$2;}END{print sum;}' $$.matches_$ref)
        tot_chr=$(awk '{print $1}' $$.matches_$ref | wc -l)
	echo "There are $tot_var matches and $tot_chr chromosomes in reference $ref" >> $$.final
done
sort -nk3 $$.final | tail -1 | awk '{print $NF}' > infer_ref

# STEP 5 - Cleaning up
rm $$.*matches* *.variants

# End
echo "All done!"
