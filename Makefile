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