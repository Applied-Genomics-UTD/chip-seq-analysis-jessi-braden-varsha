#!/usr/bin/env nextflow

params.blacklist_bed = file("https://www.encodeproject.org/files/ENCFF001TDO/@@download/ENCFF001TDO.bed.gz")
params.H3K27ac_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_H3K27ac_peaks.broadPeak")
params.YAP1_peaks = file("/scratch/applied-genomics/chipseq/ming-results/bwa/mergedLibrary/macs2/broadPeak/WT_YAP1_peaks.broadPeak")

include { COMPARE_PEAK_SETS } from './modules/compare_peak_sets.nf'
include { YAP1_OVERLAP_H3K27AC } from './modules/yap1_overlap_h3k27ac.nf'

workflow {
    COMPARE_PEAK_SETS(
        params.blacklist_bed,
        params.H3K27ac_peaks,
        params.YAP1_peaks)
    YAP1_OVERLAP_H3K27AC(
        COMPARE_PEAK_SETS.out.H3K27ac,
        COMPARE_PEAK_SETS.out.YAP1) | view
}