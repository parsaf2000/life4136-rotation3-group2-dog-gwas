# Notes on reproducibility

This repository documents the original analysis workflow used for the LIFE4136 Rotation 3 Group 2 dog GWAS project.

## Known issues in the original scripts
- `02_trim.sh` defines `OUTPUT` but uses `$OUT` in the `fastp` command. This should be corrected before rerunning.
- `04b_sort_bam.sh` appears to use paths such as `/aligned/` and `/sorted/`, which may need correction depending on the working directory.
- `05_call_variants.sh` refers to `~/ROS_Cfam.fa`, while other parts of the workflow use the shared project reference location.
- `01_fastqc.sh` is not yet included because the original `fastqc.sh` file was not readable at the time of repository preparation.
- Plot files were not present in the project directory at the time of repository preparation and can be added later.

## Large output files
The following outputs were generated successfully on the shared system but are too large for a clean GitHub repository:
- `gwas/gwas_height.assoc.linear`
- `gwas/gwas_weight.assoc.linear`
- `PCA/pca3_height.assoc.linear`
- `PCA/pca3_weight.assoc.linear`
- `vcf/doggies_snps.vcf.gz`

The repository therefore contains compact summaries and references to the full shared-path outputs.
