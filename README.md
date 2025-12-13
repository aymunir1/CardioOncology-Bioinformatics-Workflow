# Identifying Shared Molecular Biomarkers Linking Cardiovascular Diseases and Breast Cancer

## Overview
Breast cancer (BC) and cardiovascular diseases (CVDs) are leading causes of global morbidity and mortality. Growing evidence suggests that these conditions share converging biological mechanisms, including chronic inflammation, oxidative stress, metabolic dysregulation, hormonal signaling, and epigenetic regulation. Clinical observations further indicate a bidirectional interaction, where cancer therapies may induce cardiotoxicity and pre-existing cardiovascular dysfunction may influence tumor progression and recurrence.

This project implements an **R-based bioinformatics and machine learning workflow** to identify **shared molecular biomarkers and pathways** linking breast cancer and cardiovascular diseases using transcriptomic data and curated cardiovascular-related evidence.

---


## Contributors
- Yusuf Munir Aliyu (`aymunir1`) Abeer Ali (`abeer_ali_`)
- Rashi Gupta (`rashig_23`)
- Rawan Ateff (`rawanateff1080`)
- Rihab (`biotechexplorer_79059`)
- Imoleayo (`imoleayo0964`)
---

## Objectives
--

- Identify differentially expressed genes (DEGs) in breast cancer t
- Functionally characterize dysregulated genes using GO, KEGG, MSigDB, and GSEA  
- Cross-reference BC-derived DEGs with cardiovascular disease–associated genes and pathways  
- Apply machine learning feature selection to reinforce biologically relevant shared biomarkers  
- Highlight candidate genes relevant to cardio-oncology risk stratification  

---

## Dataset
- **Platform:** Affymetrix Human Gene 1.0 ST Array  
- **Accession:** GSE109169  
- **Data type:** Microarray gene expression  
- **Samples:** Breast cancer and normal controls  

---

## Workflow Summary
1. Data quality control and RMA normalization  
2. Probe-to-gene annotation  
3. Exploratory analysis (PCA and hierarchical clustering)  
4. Differential expression analysis  
5. Functional enrichment (GO, KEGG, MSigDB, GSEA)  
6. Machine learning feature selection (LASSO and Random Forest)  
7. Consensus biomarker identification  
8. Model evaluation and result export  

---

## Methods

### Differential Expression Analysis
- Gene symbols were filtered and redundant probes collapsed by selecting genes with the maximum absolute log fold change.
- Gene identifiers were mapped from SYMBOL to ENTREZ ID for downstream enrichment analyses.

### Functional Enrichment
- **GO Biological Process (GSEA):** Performed using ranked gene lists.
- **KEGG Pathway Analysis:** Over-representation analysis of DEG-associated pathways.
- Results were visualized using dot plots.

### Machine Learning Feature Selection
Two complementary approaches were applied:

**LASSO (GLMNET)**
- Logistic regression with L1 regularization
- 10-fold cross-validation
- Selection of genes with non-zero coefficients

**Random Forest**
- Ensemble learning with 1,000 trees
- Variable importance ranking

**Consensus biomarkers** were defined as the intersection of genes selected by both methods.

---

## Outputs
The analysis generates the following files:

- `DEG_GSE109169.csv`  
- `UP_DEG_GSE109169.csv`  
- `DOWN_DEG_GSE109169.csv`  
- `GSE109169_normalized_expression_matrix.csv`  
- `GO_enrichment_results.csv`  
- `KEGG_enrichment_results.csv`  
- `LASSO_selected_genes.csv`  
- `RF_selected_genes.csv`  
- `Consensus_ML_biomarkers.csv`  
- `sessionInfo.txt`  

---

## Reproducibility
- All analyses were conducted in **R**
- Package versions and system information are recorded using `sessionInfo()`
- The workflow can be reproduced by running the scripts in sequence

---

## Expected Outcomes
- Identification of shared genes and pathways linking breast cancer and cardiovascular diseases  
- Insights into mechanisms of cardiotoxic susceptibility and cardiovascular-driven tumor progression  
- Support for integrated cardio-oncology biomarker development  

---

## Keywords
Breast cancer, cardiovascular diseases, shared biomarkers, differentially expressed genes, bioinformatics, machine learning, cardio-oncology

