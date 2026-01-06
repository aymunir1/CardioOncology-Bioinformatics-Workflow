
# 1. Load packages

library(GEOquery)
library(arrayQualityMetrics)
library(pheatmap)
library(EnhancedVolcano)
library(clusterProfiler)
library(org.Hs.eg.db)
library(msigdbr)
library(fgsea)
library(sva)
library(oligo)
library(pd.huex.1.0.st.v2)
library(huex10sttranscriptcluster.db)
library(AnnotationDbi)
library(dplyr)
library(limma)
library(ggplot2)
library(ggrepel)
library(ReactomePA)
library(enrichplot)

# 2. Download CEL files + metadata
# Download series matrix file
gse <- getGEO("GSE109169", GSEMatrix = TRUE)
pheno <- pData(gse[[1]]) %>% as.data.frame()

# Download raw CELs
getGEOSuppFiles("GSE109169")
untar("GSE109169/GSE109169_RAW.tar")

# 3. Read CEL files & create ExpressionSet
setwd("~/GSE109169_RAW")
gz_files <- list.files(pattern = "CEL.gz$", full.names = TRUE)
for (f in gz_files) {
  message("Extracting: ", f)
  
  if (!file.exists(f)) {
    warning("File not found: ", f)
    next
  }
  
  out <- sub("\\.gz$", "", f)
  
  con_in  <- gzfile(f, open="rb")
  con_out <- file(out, open="wb")
  
  writeBin(readBin(con_in, what="raw", n=1e9), con_out)
  
  close(con_in)
  close(con_out)
}

cel_files <- list.files(pattern = "\\.CEL$", ignore.case = TRUE)
raw_data <- read.celfiles(cel_files)

# 4. Raw Quality Control
arrayQualityMetrics(raw_data, outdir = "QC_raw", force = TRUE)

boxplot(raw_data, target = "probeset", main = "Raw Intensities")

pm_means <- pm(raw_data)  # PM probe intensities
head(pm_means)


# 5. RMA Normalization
norm_data <- rma(raw_data)
expr_matrix <- exprs(norm_data)

# 6. Batch detection (optional)
pheno$source_name_ch1 <- make.names(pheno$source_name_ch1)
mod <- model.matrix(~ pheno$source_name_ch1)
sv <- svaseq(as.matrix(expr_matrix), mod, mod0 = NULL)
design <- cbind(mod, sv$sv)
fit <- lmFit(expr_matrix, design)


# 7. limma design + DEG
pheno$source_name_ch1 <- make.names(pheno$source_name_ch1)
group <- factor(pheno$source_name_ch1)
pData(raw_data)$group <- group
pData(raw_data)
colnames(expr_matrix) <- sub("_.*", "", colnames(expr_matrix))
rownames(pheno) == colnames(expr_matrix)

design <- model.matrix(~0 + group)
colnames(design) <- levels(group)
design

fit <- lmFit(expr_matrix, design)
contrast_matrix <- makeContrasts(breast.cancer.tissue - breast.tumor.adjacent.normal.tissue, levels = design)
fit2 <- contrasts.fit(fit, contrast_matrix)
fit2 <- eBayes(fit2)

deg_results <- topTable(fit2, number = Inf, adjust.method = "BH")


# 8.  Annotation: probe → gene
probe_ids <- rownames(deg_results)
annotation <- AnnotationDbi::select(
  huex10sttranscriptcluster.db,
  keys = probe_ids,
  columns = c("SYMBOL", "GENENAME", "ENTREZID"),
  keytype = "PROBEID"
)
deg_results <- merge(
  deg_results,
  annotation,
  by.x = "row.names",
  by.y = "PROBEID",
  all.x = TRUE
)

# 9. Analysis by generating Up/Down-regulated genes and PCA analysis
deg_results <- deg_results[!duplicated(deg_results$Row.names), ]
deg_results <- deg_results[complete.cases(deg_results), ]

# Upregulated genes
deg_up <- deg_results[deg_results$logFC > 1 & deg_results$P.Value < 0.05, ]
# Downregulated genes
deg_down <- deg_results[deg_results$logFC < -1 & deg_results$P.Value < 0.05, ]

rownames(deg_results) <- deg_results$Row.names
deg_results$Row.names = NULL
top50 <- rownames(deg_results)[1:50]
mat <- expr_matrix[top50, ]
gene_symbols <- deg_results$SYMBOL[match(rownames(mat), rownames(deg_results))]

#PCA
mat_t <- t(mat)
pca <- prcomp(mat_t, scale. = TRUE)
pca_df <- data.frame(
  Sample = rownames(pca$x),
  PC1 = pca$x[,1],
  PC2 = pca$x[,2],
  Group = pData(raw_data)$group
)

ggplot(pca_df, aes(x = PC1, y = PC2, color = Group, label = Sample)) +
  geom_point(size = 2) +
  geom_text(vjust = -0.5, size = 2) +  # optional: show sample names
  theme_minimal(base_size = 14) +
  labs(
    title = "PCA of Top 50 DEGs",
    x = paste0("PC1 (", round(summary(pca)$importance[2,1]*100, 1), "%)"),
    y = paste0("PC2 (", round(summary(pca)$importance[2,2]*100, 1), "%)")
  )

# 10. Visualization
#Volcano Plot
deg_results$threshold <- "Not Sig"
deg_results$threshold[deg_results$logFC > 1 & deg_results$P.Value < 0.05] <- "Up"
deg_results$threshold[deg_results$logFC < -1 & deg_results$P.Value < 0.05] <- "Down"
ggplot(deg_results, aes(x = logFC, y = -log10(P.Value), color = threshold)) +
  geom_point(alpha = 0.7, size = 0.7) +
  scale_color_manual(values = c("Up" = "red", "Down" = "blue", "Not Sig" = "grey")) +
  theme_minimal(base_size = 14) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  labs(
    title = "Volcano Plot",
    x = "log2 Fold Change",
    y = "-log10(P-value)",
    color = "Regulation"
  )

#Heatmap
pheatmap(
  mat,
  scale = "row",
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  show_rownames = TRUE,
  labels_row = gene_symbols,   
  show_colnames = TRUE,
  fontsize = 3,
  color = colorRampPalette(c("blue", "white", "red"))(100)
)


# 11. Functional enrichment
#Preparing gene list
deg2 <- deg_results %>% filter(!is.na(SYMBOL))
deg_unique <- deg2 %>%
  group_by(SYMBOL) %>%
  slice_max(order_by = abs(logFC), n = 1) %>%
  ungroup()
entrez_map <- bitr(deg_unique$SYMBOL,
                   fromType = "SYMBOL",
                   toType = "ENTREZID",
                   OrgDb = org.Hs.eg.db)
entrez_map <- entrez_map %>% distinct(SYMBOL, .keep_all = TRUE)
deg_mapped <- deg_unique %>% filter(SYMBOL %in% entrez_map$SYMBOL)
gene_list <- deg_mapped$logFC
names(gene_list) <- entrez_map$ENTREZID[match(deg_mapped$SYMBOL, entrez_map$SYMBOL)]
gene_list <- sort(gene_list, decreasing = TRUE)

# GO Biological Process GSEA
gsea_go <- gseGO(geneList = gene_list,
                 OrgDb = org.Hs.eg.db,
                 ont = "BP",
                 keyType = "ENTREZID",
                 minGSSize = 10,
                 maxGSSize = 500,
                 pvalueCutoff = 0.05,
                 verbose = FALSE)

dotplot(gsea_go, showCategory = 50) +
  theme(axis.text.y = element_text(size = 2.5), 
        axis.text.x = element_text(size = 4), 
        axis.title = element_text(size = 5))

# KEGG enrichment (ORA)
kegg_ora <- enrichKEGG(gene = names(gene_list), 
                       organism = "hsa", 
                       pvalueCutoff = 0.05)

dotplot(kegg_ora, showCategory = 50) +
  theme(axis.text.y = element_text(size = 2.5), 
        axis.text.x = element_text(size = 4), 
        axis.title = element_text(size = 5))


# 12. Save DEG table and up/down-regulated genes
write.csv(deg_results, "DEG_GSE109169.csv")
write.csv(deg_up, "UP_DEG_GSE109169.csv")
write.csv(deg_down, "DOWN_DEG_GSE109169.csv")


# 13. Save normalized expression matrix
write.csv(expr_matrix, "GSE109169_normalized_expression_matrix.csv")


# 14. Save GO enrichment results
write.csv(as.data.frame(gsea_go), "GO_enrichment_results.csv")
write.csv(as.data.frame(kegg_ora), "KEGG_enrichment_results.csv")


# 15. Save R session info (reproducibility)
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")


