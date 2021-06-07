# Name

genome_ref_cal.sh: Script for inferring the genome reference from a vcf file. Works with genome ref grch37, grch38 and hg17.

# Synopsis

This script allows to calculate the genome reference from a vcf file. The algorithm works as follows:

   *	First we created 3 dictionaries (one for each of the three reference genomes hg17, grch37, grch38) consisting of SNP positions (chr, pos, ref) exclusive to each genome.
   *	The script searches for matches in the 3 dictionaries and outputs a file (infer_ref) with the reference genome having more matches.  We use a maximum of 10K variants and a maximum of 100 matches per chromosome.

Note that the script includes the [dictionaries](https://github.com/mrueda/EGA_genomeref/tree/main/ref_dics) for inferring the genome reference.


# How to run the script

Before running it for the first time you need to set the variable 'path_dic' inside 'genome_ref_cal.sh'.
In the installation directory the dictionaries are inside a folder named './ref_dics'

The script is written in _Bash_ and uses standard bash commands. The script was tested on Debian-based (e.g., Ubuntu, Mint) distributions.

The script takes a VCF as input, however any tsv (consisting of CHROM\tPOS\tID\tREF) will work as we only use columns 1,2 and 4 (we discard the header).

Please note that input vcf file has to be gzipped (or bgzipped).


```
bash /path/genome_ref_cal.sh input.vcf.gz
```

Once completed you should check if the number of matches in the inferred genome reference is enough for your purposes (displayed in \*.final). 

Intermediate files (\*matches\* and \*.variants\*) are deleted by default at the end. Feel free to uncomment the line that deletes them (toward the end of the script) and explore their contents. 

**Notes on execution time**

The script was built to be run in the [EGA](https://ega-archive.org) archive and we established our thresholds to provide enough confidence to infer genomes there. 

The script speed scales almost linearly with the number of variants. With the default thresholds the (approximate) execution time is ~ 1 min * 1 Million variants.

The thresholds ```rand_var=10000, match=100``` do not affect much the speed, yet you may want to tune them according to your needs. 

Most the calculation times goes to reading/splitting the input file, thus, for very large VCFs you may want to downsample the number of variants prior to the calculation. For instance, you can run ```zgrep -v '^#' input.vcf.gz | awk 'NR % 10 == 0' | gzip > smaller.vcf.gz``` to print every 10th line, thus reducing the file size (and execution time) by a factor of 10.

**Notes about finding matches on multiple reference genomes**

The dictionary was built using SNPs only, thus, if your VCF contains complex INDELS then it is possible that get a few matches in more than one reference genome. Note that these matches will not affect the results for the final infered genome (infer_ref).

In any case, these cross-matches should disspear if you pre-filter your VCF to retain SNPs only. The simplest solution would be to fetch biallelic SNPs by using ```zcat input.vcf.gz | awk 'length($4) == 1 && length($5) == 1'  | gzip > snp_biallelic.vcf.gz```. Alternatively, you can use [BCFtools](http://samtools.github.io/bcftools/bcftools.html), which allows for more precise filtering.


# Demo

Demo folder contains a subset of vcf from chromosome 22 from 1000 Genomes data for testing purposes.

1. \*.final: contains total number of matches for each genome reference.
2. \*.demo_subset.chr: file generated with the number of variants per chromosome present in the demo vcf.
4. infer_ref: contains the inferred genome reference.
5. log: A log file of the STDOUT.

# Author

Written by Dietmar Fernandez, PhD. Info about EGA can be found at https://ega-archive.org/.


# Copyright

This Bash script is copyrighted. See the LICENSE file included in this distribution.
