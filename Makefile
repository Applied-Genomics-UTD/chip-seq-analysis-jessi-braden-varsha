Data:
## Make directories for data storage
	mkdir -p data
	mkdir -p refs
	mkdir -p bam
## Perform search for run information
esearch -db sra -query PRJNA306490  | efetch -format runinfo > runinfo.csv
