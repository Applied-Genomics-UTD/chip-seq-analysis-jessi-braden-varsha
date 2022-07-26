process ANNOTATE_PEAKS {
    conda './envs/annotate_peaks.yml'

    publishDir 'results/annotate_peaks'

    input:
    path H3K27ac_bed
    path YAP1_bed

    output:
    path "YAP1_peaks_anno.txt"
    path "Rplots.pdf"

    shell:
    '''
    #!/usr/bin/env Rscript
    ## Load required packages
    library (ChIPseeker)
    library (TxDb.Hsapiens.UCSC.hg19.knownGene)
    library (rtracklayer)
    library ("org.Hs.eg.db")

    txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene

    ## Read in YAP1 peaks
    YAP1 <- readPeakFile("!{YAP1_bed}", as="GRanges")
    YAP1
    
    YAP1_anno <- annotatePeak(YAP1, tssRegion=c(-3000, 3000), TxDb=txdb, level = "gene", annoDb="org.Hs.eg.db", sameStrand = FALSE, ignoreOverlap = FALSE, overlap = "TSS")

    ## Visualization
    plotAnnoPie(YAP1_anno)
    upsetplot(YAP1_anno, vennpie=FALSE)

    ## Save to txt file
    head(as.data.frame(YAP1_anno))
    write.table(as.data.frame(YAP1_anno), "YAP1_peaks_anno.txt", row.names =F, col.names=T, sep ="\t", quote = F)
    '''
}