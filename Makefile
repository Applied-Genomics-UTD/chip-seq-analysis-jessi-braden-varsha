All: Data Align Trim Visualize

Data:
## Make directories for data storage
	mkdir -p data
	mkdir -p refs
	mkdir -p bam
## Perform search for run information
	conda run -n biostars esearch -db sra -query PRJNA306490  | conda run -n biostars efetch -format runinfo > runinfo.csv
## Isolate run ids
	cat runinfo.csv | cut -f 1 -d , | grep SRR > runids.txt
## Download fastq files
	cat runids.txt | conda run -n biostars parallel --eta --verbose  "fastq-dump -O data --split-files -F {}"
## Run esummary
	conda run -n biostars esearch -db sra -query PRJNA306490 | conda run -n biostars esummary > summary.xml
## Turn xml into tabular file
	cat summary.xml | conda run -n biostars xtract -pattern DocumentSummary -element Run@acc Title
## Download chromosomes
	URL=http://hgdownload.cse.ucsc.edu/goldenPath/sacCer3/bigZips/chromFa.tar.gz
	curl ${URL} | tar zxv
## Download chromosome sizes
	curl http://hgdownload.cse.ucsc.edu/goldenPath/sacCer3/bigZips/sacCer3.chrom.sizes > refs/sacCer3.chrom.sizes
## Move .fa files
	mv *.fa refs
## Create genome
	cat refs/chr*.fa > ${REF}
## Index the reference
	bwa index ${REF}
	samtools faidx ${REF}

Align:
	cat runids.txt | conda run -n biostars parallel --eta --verbose "bwa mem -t 4 ${REF} data/{}_1.fastq | samtools sort -@ 8 > bam/{}.bam"

Trim:
## Trim each bam file.
	cat runids.txt | conda run -n biostars parallel --eta --verbose "bam trimBam bam/{}.bam bam/temp-{}.bam -R 70 --clip"
## Re-sort alignments.
	cat runids.txt | conda run -n biostars parallel --eta --verbose "samtools sort -@ 8 bam/temp-{}.bam > bam/trimmed-{}.bam"
## Get rid of temporary BAM files.
	rm -f bam/temp*
## Reindex trimmed bam files.
	cat runids.txt | conda run -n biostars parallel --eta --verbose "samtools index bam/trimmed-{}.bam"

Visualize:
# Create a genome file for bedtools
	samtools faidx ${REF}
# Create the coverage files for all BAM files.
	ls bam/*.bam | parallel --eta --verbose "bedtools genomecov -ibam {} -g ${REF}.fai -bg | sort -k1,1 -k2,2n > {.}.bedgraph"
# Generate all bigwig coverages from bedgraphs.
	ls bam/*.bedgraph | parallel --eta --verbose "bedGraphToBigWig {} ${REF}.fai {.}.bw"