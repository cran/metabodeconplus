## ----set-defaults, echo=FALSE, results=FALSE, message=FALSE-------------------
knitr::opts_chunk$set(
    fig.dim = c(5, 5), # Size of stored figures in inches
    fig.show = "hold", # Render images as inline elements
    out.width = "50%", # [^1]
    eval = FALSE,
    echo = FALSE,
    results = FALSE,
    message = FALSE
    # [^1]: Either out.width or out.height must be set or rmarkdown will
    # not put a div.figure around the individual img elements. Furthermore,
    # we must not use out.width = "auto" or out.height = "auto", as LaTeX
    # cannot handle that.
)

## ----chunk-deconvolute, echo=TRUE, eval=TRUE----------------------------------
sim_dir <- metabodeconplus::metabodeconplus_file("bruker/sim")
sim <- metabodeconplus::read_spectra(sim_dir)
deconvoluted_spectra <- metabodeconplus::deconvolute(
    sim,                 # The object containing spectra
    sfr = c(3.35, 3.55), # Borders of signal free region (SFR) in ppm
    smit = 2, smws = 5,  # Smoothing parameters
    verbose = FALSE      # Disable verbose output
)

## ----chunk-plot-spectrum, echo=TRUE-------------------------------------------
# # Visualize the first spectrum.
# metabodeconplus::plot_spectrum(deconvoluted_spectra[[1]])
# 
# # Visualize the second spectrum, this time without the legend.
# metabodeconplus::plot_spectrum(deconvoluted_spectra[[1]], lgd = FALSE)
# 
# # Visualize all spectra and save them to a pdf file
# pdfpath <- tempfile(fileext = ".pdf")
# pdf(pdfpath)
# for (x in deconvoluted_spectra) {
#     metabodeconplus::plot_spectrum(x, main = x$filename)
# }
# dev.off()
# cat("Plots saved to", pdfpath, "\n")

## ----fig-plot-spectrum, eval=TRUE---------------------------------------------
# Visualize the first spectrum.
metabodeconplus::plot_spectrum(deconvoluted_spectra[[1]])

# Visualize the second spectrum, this time without the legend.
metabodeconplus::plot_spectrum(deconvoluted_spectra[[1]], lgd = FALSE)

# Visualize all spectra and save them to a pdf file
pdfpath <- tempfile(fileext = ".pdf")
pdf(pdfpath)
for (x in deconvoluted_spectra) {
    metabodeconplus::plot_spectrum(x, main = x$filename)
}
dev.off()
cat("Plots saved to", pdfpath, "\n")

## ----chunk-align, echo=TRUE---------------------------------------------------
# # Plot spectra before alignment. Only show spectra 1-8 for clarity.
# metabodeconplus::plot_spectra(deconvoluted_spectra[1:8], lgd = FALSE)
# 
# # Align spectra and plot again.
# aligned_spectra <- metabodeconplus::align(deconvoluted_spectra)
# metabodeconplus::plot_spectra(aligned_spectra[1:8])

## ----fig-align, eval=TRUE-----------------------------------------------------
# Plot spectra before alignment. Only show spectra 1-8 for clarity.
metabodeconplus::plot_spectra(deconvoluted_spectra[1:8], lgd = FALSE)

# Align spectra and plot again.
aligned_spectra <- metabodeconplus::align(deconvoluted_spectra)
metabodeconplus::plot_spectra(aligned_spectra[1:8])

