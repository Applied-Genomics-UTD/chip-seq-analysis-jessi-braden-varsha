process YAP1_OVERLAP_H3K27AC {
    conda 'bedtools'

    input:
    path H3K27ac
    path YAP1
    
    output:
    stdout

    script:
    """
    bedtools intersect -a $YAP1 -b $H3K27ac -wa | wc -l

    bedtools intersect -a $YAP1 -b $H3K27ac -wa | sort | uniq | wc -l

    bedtools intersect -a $H3K27ac -b $YAP1 -wa | wc -l

    bedtools intersect -a $H3K27ac -b $YAP1 -wa | sort | uniq | wc -l

    bedtools intersect -a $H3K27ac -b $YAP1 -wa | sort | uniq -c | sort -k1,1nr | head
    """
}