All: Index Align Trim Visualize Summarize Call Motifs

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

Environment:
## Create macs conda environment
	conda create -n macs bioconda::macs2=2.2.7

REF ?= refs/saccer3.fa
Index:
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
## Create a genome file for bedtools
	samtools faidx ${REF}
## Create the coverage files for all BAM files.
	ls bam/*.bam | conda run -n biostars parallel --eta --verbose "bedtools genomecov -ibam {} -g ${REF}.fai -bg | sort -k1,1 -k2,2n > {.}.bedgraph"
## Generate all bigwig coverages from bedgraphs.
	ls bam/*.bedgraph | conda run -n biostars parallel --eta --verbose "bedGraphToBigWig {} ${REF}.fai {.}.bw"

Summarize:
## Merge all replicates into one file
	samtools merge -f -r bam/glucose.bam bam/SRR3033154.bam bam/SRR3033155.bam
	samtools merge -f -r bam/ethanol.bam bam/SRR3033156.bam bam/SRR3033157.bam
	samtools index bam/glucose.bam 
	samtools index bam/ethanol.bam
## Generate coverages
	bedtools genomecov -ibam bam/glucose.bam  -g ${REF}.fai -bg > bam/glucose.bedgraph
	bedtools genomecov -ibam bam/ethanol.bam  -g ${REF}.fai -bg > bam/ethanol.bedgraph

## Glucose samples
GLU1 = bam/trimmed-SRR3033154.bam
GLU2 = bam/trimmed-SRR3033155.bam
## Ethanol samples
ETH1 = bam/trimmed-SRR3033156.bam
ETH2 = bam/trimmed-SRR3033157.bam

Call:
	conda run -n macs macs2 callpeak -t ${ETH1} ${ETH2} -c ${GLU1} ${GLU2} --gsize 1E7  --name ethanol --outdir ethanol/

Motifs:
## Turn output into 9 column gff files
	cat ${REF} | conda run -n biostars seqkit locate -p GTGACGT | grep -v seqID | conda run -n biostars awk ' { OFS="\t"; print $$1, ".", ".", $$5, $$6, ".", $$4, ".", "." }' > motifs.gff
## Check published peaks
	curl -O http://data.biostarhandbook.com/chipseq/peaks-published.bed
	conda run -n biostars bedtools intersect -u -a peaks-published.bed -b motifs.gff | wc -l
