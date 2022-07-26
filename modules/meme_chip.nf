process MEME_CHIP {
    conda 'meme'
    publishDir 'results/meme_chip'

    input:
    path YAP1_500bp_fasta
    path meme_db

    output: 
path "meme-chip.html"
path "summary.tsv"

    script:
    """
    meme-chip -oc . -time 240 -ccut 100 -dna -order 2 \\
        -minw 6 -maxw 15 \\
        -db ${meme_db} \\
        -meme-mod zoops -meme-nmotifs 3 \\
        -meme-searchsize 100000 -streme-pvt 0.05 -streme-totallength 4000000 \\
        -centrimo-score 5.0 -centrimo-ethresh 10.0 $YAP1_500bp_fasta
    """
}