##############################################
# 16. MACHINE LEARNING FEATURE SELECTION
##############################################

library(caret)
library(glmnet)
library(randomForest)
library(tidyverse)

#-------------------------------
# Prepare ML dataset
#-------------------------------

# Use only DEGs for ML
deg_mat <- expr_matrix[rownames(deg_results), ]

# Transpose: samples as rows, genes as columns
ml_data <- t(deg_mat) %>% as.data.frame()

# Add phenotype labels (CANCER vs NORMAL)
ml_data$Class <- group   # from your DEG script

table(ml_data$Class)




set.seed(123)

train_index <- createDataPartition(ml_data$Class, p = 0.8, list = FALSE)
train_data <- ml_data[train_index, ]
test_data  <- ml_data[-train_index, ]




##############################################
# 17. LASSO (GLMNET)
##############################################

x_train <- as.matrix(train_data[, -ncol(train_data)])
y_train <- as.factor(train_data$Class)

cv_lasso <- cv.glmnet(
  x_train,
  y_train,
  family = "binomial",
  alpha = 1,
  nfolds = 10
)

best_lambda <- cv_lasso$lambda.min
lasso_model <- glmnet(x_train, y_train, family = "binomial", lambda = best_lambda)

# Extract selected genes
lasso_genes <- rownames(coef(lasso_model))[coef(lasso_model)[, 1] != 0]
lasso_genes <- lasso_genes[lasso_genes != "(Intercept)"]
lasso_genes





##############################################
# 18. RANDOM FOREST
##############################################

rf_model <- randomForest(
  x = train_data[, colnames(train_data) != "Class"],
  y = train_data$Class,
  importance = TRUE,
  ntree = 1000
)

rf_imp <- importance(rf_model)
rf_genes <- names(sort(rf_imp[, 1], decreasing = TRUE))[1:50]   # top 50 important genes
rf_genes






##############################################
# 19. CONSENSUS BIOMARKERS
##############################################

consensus_genes <- intersect(lasso_genes, rf_genes)
consensus_genes




##############################################
# 20. MODEL EVALUATION
##############################################

x_test  <- as.matrix(test_data[, -ncol(test_data)])
y_test  <- as.factor(test_data$Class)

# LASSO prediction
lasso_pred <- predict(lasso_model, newx = x_test, type = "class")
confusionMatrix(as.factor(lasso_pred), y_test)

# Random forest prediction
rf_pred <- predict(rf_model, newdata = test_data)
confusionMatrix(as.factor(rf_pred), y_test)





##############################################
# 21. VARIABLE IMPORTANCE PLOTS
##############################################

# LASSO Coefficients
lasso_coef_df <- data.frame(
  Gene = lasso_genes,
  Coef = as.numeric(coef(lasso_model)[lasso_genes, 1])
)

ggplot(lasso_coef_df, aes(x = reorder(Gene, Coef), y = Coef)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "LASSO-selected genes", x = "Genes", y = "Coefficient")

# Random Forest Importance
rf_imp_df <- data.frame(
  Gene = rownames(rf_imp),
  Importance = rf_imp[, 1]
)

rf_imp_df_top <- rf_imp_df %>% top_n(30, Importance)

ggplot(rf_imp_df_top, aes(x = reorder(Gene, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "darkred") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Random Forest – Top Important Genes")





##############################################
# 22. SAVE RESULTS
##############################################

write.csv(lasso_genes, "LASSO_selected_genes.csv", row.names = FALSE)
write.csv(rf_genes, "RF_selected_genes.csv", row.names = FALSE)
write.csv(consensus_genes, "Consensus_ML_biomarkers.csv", row.names = FALSE)






