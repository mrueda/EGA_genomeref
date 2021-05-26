# Name
genome_ref_cal.sh: Script for inferring the genome reference from a vcf file. Works with genome ref grch37, grch38 and hg17.

# Synopsis

This script allows to calculate the genome reference from a vcf file. We extracted unique nucleotides per pos in hg17, grch37, grch38.

We select the chromosome with more variants in the vcf file and we run the script for that specific chromosome.

It searchs for matches in 3 dictionaries (one per reference genome) and takes the one having matches (only one).

A maximum of 10K variants per chromosome are analyzed. Also a maximum of 100 matches per chromosome are analyzed.

The script includes the dictionaries for inferring the genome reference.

# Run

Before running it for the first time you need to set the variable 'path_dic=' inside 'genome_ref_cal.sh'.
In the installation directory the dictionaries are inside a folder name './ref_dics'

The script runs on Bash iand uses standard bash commands. The script was tested on Debian-based distributions.

Please note that input vcf file has to be gzipped (or bgzipped).


```
bash /path/genome_ref_cal.sh input.vcf.gz
```

# Demo

Demo folder contains a subset of vcf from chromosome 22 from 1000 Genomes data for testing purposes.

1. \*.final: contains total number of matches for each genome reference.
2. demo_subset.chr: file generated with the number of chromosomes and variants present in the demo vcf.
4. infer_ref: contains the inferred genome reference.
5. log

# Author

Written by Dietmar Fernandez, PhD. Info about EGA can be found at https://ega-archive.org/.


# Copyright

This bash script is copyrighted. See the LICENSE file included in this distribution.
