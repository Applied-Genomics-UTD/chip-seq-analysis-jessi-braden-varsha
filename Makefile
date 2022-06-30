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
curl $URL | tar zxv
## Download chromosome sizes
curl http://hgdownload.cse.ucsc.edu/goldenPath/sacCer3/bigZips/sacCer3.chrom.sizes > refs/sacCer3.chrom.sizes
## Move .fa files
mv *.fa refs
## Create genome
cat refs/chr*.fa > $REF