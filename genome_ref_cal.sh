#!/bin/bash

###################################################################
# Script Name    : genome_ref_cal.sh
# Date           : 2021-05-27
# Version        : 3.5
# Author         : Dietmar Fernandez (dietmar.fernandez@crg.eu)
#                : Revised by Manuel Rueda (manuel.rueda@crg.eu)
# Usage          : bash genome_ref_cal.sh input.vcf.gz
# Description    : This script infers the reference genome from a vcf file. 
# Description    :  - We created a dictionary consisting of unique chr/pos/ref in hg17, grch37, grch38 reference genomes.
# Description    :  - The script searches for matches in the 3 dicts and outputs (infer_ref) the reference genome having more matches.
# Requirements   : gzip (tested version 1.10), awk (tested version Awk 5.0.1), grep (tested version 3.4), sed (tested sed (GNU sed) 4.7), wc (tested version (GNU coreutils) 8.30).
###################################################################

set -eu
export LC_ALL=C

# Variables
rand_var=10000 # 10K random variants
match=100      # Nuber of matches for the grep   
genomes=("hg17" "grch37" "grch38") # reference genomes

# Path for dictionary files (put here your own path)
path_dic="./ref_dics"

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

# STEP 1 - We split the file by CHROM into multiple files
echo "Splitting vcf by chr..."
zcat $input_vcf | cut -f1,2,4 | grep -v '^#' | awk '{print>$1".variants"}'

# STEP 2 - For each chromosome we query a subset of variants against the dictionary
for chr in $(ls -1 *.variants | awk -F'.' '{print $1}' |sort -V)
do
  chr_str=$(echo $chr | sed 's/chr//')
  echo "Running chr$chr_str..."
  
  # First we add var|chr stats to $base.chr
  { echo -n "$chr " ; wc -l $chr.variants | awk '{print $1}'; } >> $$.$base.chr

  # Secondly we select 10K random variants
  shuf -n $rand_var $chr.variants | sort | sed 's/chr//g' > subset.$chr.variants

  # And finally we look for the first 100 matches in the 3 dictionaries
  for ref in ${genomes[@]}
  do
   { echo -n "$chr "; zgrep -m $match -Ef subset.$chr.variants $path_dic/subset.chr$chr_str.final.dic_$ref | wc -l; } >> $$.matches_$ref
  done 
done

# STEP 3 - We analyze the results
for ref in ${genomes[@]}
do
        tot_var=$(awk '{sum+=$2;}END{print sum;}' $$.matches_$ref)
        tot_chr=$(awk '{print $1}' $$.matches_$ref | wc -l)
	echo "There are $tot_var matches and $tot_chr chromosomes in reference $ref" >> $$.final
done
sort -nk3 $$.final | tail -1 | awk '{print $NF}' > infer_ref

# STEP 4 - Cleaning up
rm $$.*matches* *.variants

# End
echo "All done!"
