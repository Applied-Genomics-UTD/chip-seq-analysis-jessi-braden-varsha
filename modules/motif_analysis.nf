process MOTIF_ANALYSIS {
    conda 'bedtools'
    publishDir 'results/motif_analysis'

    input:
    path YAP1_summits
    path fasta

    output: 
path "YAP1_500bp.fa"

    script:
"""
    # get the coordinates of 500bp centered on the summit of the YAP1 peaks
    cat ${YAP1_summits} | awk '\$2=\$2-249, \$3=\$3+250' OFS="\t" > YAP1_500bp_summits.bed

    # Use bedtools get fasta http://bedtools.readthedocs.org/en/latest/content/tools/getfasta.html 
    bedtools getfasta -fi ${fasta} -bed YAP1_500bp_summits.bed -fo YAP1_500bp.fa
    """
}