## ----set-defaults, echo=FALSE, results=FALSE, message=FALSE-------------------
knitr::opts_chunk$set(
    fig.dim=c(5, 5), fig.show="hold", out.width="50%",
    echo=TRUE, message=FALSE, warning=FALSE
)

## ----load-spectra-------------------------------------------------------------
library(metabodeconplus)
x <- sim2
y <- attr(sim2, "group")
n <- length(x)

## ----split--------------------------------------------------------------------
set.seed(1)
tr <- sort(sample(n, round(0.5 * n)))
te <- setdiff(seq_len(n), tr)
true_x0 <- attr(sim2, "true_x0")   # ppm of the discriminating peaks

## ----prep---------------------------------------------------------------------
abtr <- c(which(y[tr] == "A")[1:4], which(y[tr] == "B")[1:4])
yab <- y[tr][abtr]

## ----decon--------------------------------------------------------------------
decons <- deconvolute(x[tr], nfit=10, smit=2, smws=5, delta=10, npmax=0, verbose=FALSE)
plot_spectra(decons[abtr])
heat_spectra(decons[abtr], y=yab)

## ----align--------------------------------------------------------------------
aligns <- clupa(decons, maxShift=50, verbose=FALSE)
ref <- attr(aligns, "ref")
plot_spectra(aligns[abtr])

## ----snap---------------------------------------------------------------------
snapped <- snap_to_ref(aligns, maxCombine=5)

## ----featmat------------------------------------------------------------------
X <- peak_mat(snapped)
peakPos <- attr(X, "peakPos")
dim(X)
heat_spectra(X, y=y[tr], true_x0=true_x0)
heat_spectra(X, y=y[tr], true_x0=true_x0, scale_cols=TRUE)

## ----ranger, eval=TRUE--------------------------------------------------------
rf <- ranger::ranger(x=X, y=y[tr], probability=TRUE, num.trees=500, seed=1)
cat(sprintf("OOB error: %.1f%%\n", 100 * rf$prediction.error))

## ----fit-mdm, eval=TRUE-------------------------------------------------------
md <- fit_mdm(x[tr], y[tr], model="ranger",
              npmax=0L, maxShift=50L, maxCombine=5L,
              verbosity=0, nworkers=1)
print(md)

## ----predict, eval=TRUE-------------------------------------------------------
# Small rank-based AUC helper (positive class = second factor level).
auc <- function(y, prob) {
    pos <- y == levels(y)[2]; r <- rank(prob)
    n1 <- sum(pos); n0 <- sum(!pos)
    if (n1 == 0 || n0 == 0) NA_real_ else (sum(r[pos]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
preds <- predict(md, x[te], type="all", verbosity=0)
acc <- mean(preds$class == y[te])
au  <- auc(y[te], preds$prob)
cat(sprintf("Test accuracy: %.1f%%\n", 100 * acc))
cat(sprintf("Test AUC:      %.3f\n", au))

## ----tune, eval=TRUE----------------------------------------------------------
mt <- fit_mdm(x[tr], y[tr], model="ranger",
              npmax=c(0L, 30L), maxShift=c(20L, 50L), maxCombine=c(2L, 5L),
              verbosity=0, nworkers=1)
knitr::kable(head(mt$mog[order(-mt$mog$auc), ], 5), row.names=FALSE,
             caption="Top parameter combinations by AUC.")

## ----benchmark, eval=FALSE----------------------------------------------------
# bm <- benchmark(x, y, model="ranger", npmax=0L, maxShift=50L, maxCombine=5L, k=5)
# mean(bm$predictions$true == bm$predictions$pred)

