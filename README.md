```sh
## To log into compute node
srun -p normal --time 1-00 --mem=8G --ntasks=8 --pty bash -i

## Load anaconda3
ml load anaconda3

## To log out of compute node
exit
```

```sh
## Set up for analyses
## Update biostars environment
conda env export -n biostars > environment.yml
conda env update --name biostars --file environment.yml --prune

## Download data
make Data

## Create macs environment
make Environment

## Run analyses
make
```
