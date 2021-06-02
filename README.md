# Name

genome_ref_cal.sh: Script for inferring the genome reference from a vcf file. Works with genome ref grch37, grch38 and hg17.

# Synopsis

This script allows to calculate the genome reference from a vcf file. The algorithm works as follows:

   *	First we created 3 dictionaries (one for each of the three reference genomes hg17, grch37, grch38) consisting of positions (chr, pos, ref) exclusive to each genome.
   *	The script searches for matches in the 3 dictionaries and outputs a file (infer_ref) with the reference genome having more matches.  We use a maximum of 10K variants and a maximum of 100 matches per chromosome.

Note that the script includes the [dictionaries](https://github.com/mrueda/EGA_genomeref/tree/main/ref_dics) for inferring the genome reference.


# How to run

Before running it for the first time you need to set the variable 'path_dic' inside 'genome_ref_cal.sh'.
In the installation directory the dictionaries are inside a folder named './ref_dics'

The script is written in _Bash_ and uses standard bash commands. The script was tested on Debian-based (e.g., Ubuntu, Mint) distributions.

The script takes a VCF as input, however any tsv (consisting of CHROM\tPOS\tID\tREF) will work as we only use columns 1,2 and 4 (we discard the header).

Please note that input vcf file has to be gzipped (or bgzipped).


```
bash /path/genome_ref_cal.sh input.vcf.gz
```

Once run you should check if the number of matches in the inferred genome reference is enough for your purposes (displayed in \*.final). 

We have established that having 100 matches in one the reference genomes (and 0 in the others) provides enough confidence to infer the genome. However, you may change such threshold according to your needs.

Intermediate files (\*matches\* and \*.variants\*) are deleted by default at the end. If you find inconsistencies in your results (e.g matches in more than one genome ref) feel free to uncomment the line that deletes them and explore their contents.

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
