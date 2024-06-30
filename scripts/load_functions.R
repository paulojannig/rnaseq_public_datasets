# load libraries
required_Packages_Install <- c(
  "tidyverse",
  "DESeq2",
  "viridis",
  "egg",
  "ggtext",
  "scales"
)

for (Package in required_Packages_Install) {
  if (!require(Package, character.only = TRUE)) {
    BiocManager::install(Package, dependencies = TRUE)
  }
  library(Package, character.only = TRUE)
}

# attributes <- listAttributes(useMart("ensembl", dataset = "mmusculus_gene_ensembl"))
if (species == "human") {
  dataset <- "hsapiens_gene_ensembl"
  symbol <- "hgnc_symbol"
  organism <- "org.Hs.eg.db"
} else if (species == "mouse") {
  dataset <- "mmusculus_gene_ensembl"
  symbol <- "mgi_symbol"
  organism <- "org.Mm.eg.db"
} else if (species == "pig") {
  dataset <- "sscrofa_gene_ensembl"
  symbol <- "hgnc_symbol"
} else {
  stop("Error at defining species")
}



# DESeqDataSetFromFeatureCounts ==========================================
# Check https://www.biostars.org/p/277316/#277350
DESeqDataSetFromFeatureCounts <- function(sampleTable,
                                          directory = ".",
                                          design,
                                          ignoreRank = FALSE, ...) {
  names(sampleTable)[1:2] <- c("sample", "file")
  if (missing(design)) {
    stop("design is missing")
  }
  l <- lapply(as.character(sampleTable$file), function(fn) {
    read.table(file.path(directory, fn), skip = 2)
  }
  )
  if (!all(sapply(l, function(a) { 
    all(a$V1 == l[[1]]$V1)
  }))) 
  {
    stop("Gene IDs (first column) differ between files.")
  }
  tbl <- sapply(l, function(a) a$V7)
  colnames(tbl) <- sampleTable$sample
  rownames(tbl) <- l[[1]]$V1
  rownames(sampleTable) <- sampleTable$sample
  dds <- DESeqDataSetFromMatrix(countData = tbl, colData = sampleTable[,
                                                                       -(2),
                                                                       drop = FALSE
  ], design = design, ignoreRank, ...)
  return(dds)
}


# PCA plot DESeq2 function ==========================================
plot_pca_deseq <- function(dds,
                           group = "group",
                           plot_center = TRUE,
                           linetype = "solid",
                           palette = NULL) {
  vsd <- DESeq2::vst(dds, blind = FALSE)
  
  pca_data <- DESeq2::plotPCA(vsd, intgroup = c(group), returnData = TRUE)
  percent_var <- round(100 * attr(pca_data, "percentVar"))
  segments <- pca_data %>%
    dplyr::group_by(!!as.symbol("group")) %>%
    dplyr::summarise(xend = mean(PC1), yend = mean(PC2))
  pca_data <- merge(pca_data, segments, by = "group")
  
  no_colors <- pca_data[, "group"] %>%
    unique() %>%
    length()
  
  if (plot_center == TRUE) {
    p <- pca_data %>%
      ggplot2::ggplot(ggplot2::aes(PC1, PC2, fill = !!as.symbol("group"))) +
      ggplot2::geom_segment(
        ggplot2::aes(x = PC1, y = PC2, xend = xend, yend = yend),
        linewidth = 0.3,
        linetype = linetype
      ) +
      ggplot2::geom_point(
        data = segments,
        ggplot2::aes(x = xend, y = yend),
        size = 0.5
      )
  } else {
    p <- pca_data %>%
      ggplot2::ggplot(ggplot2::aes(PC1, PC2, fill = !!as.symbol("group")))
  }
  
  # ggplot2::geom_point(size = 2)
  p <- p + ggplot2::geom_point(size = 2, shape = 21, color = "black") +
    ggplot2::xlab(paste0("PC1: ", percent_var[1], "% variance")) +
    ggplot2::ylab(paste0("PC2: ", percent_var[2], "% variance")) +
    gg_theme() +
    ggplot2::theme(legend.position = "top")
  
  if (is.null(palette)) {
    p <- p +
      ggplot2::scale_color_manual(values = viridis::viridis(no_colors + 1)) +
      ggplot2::scale_fill_manual(values = viridis::viridis(no_colors + 1))
  } else {
    p <- p +
      ggplot2::scale_color_manual(
        values = palette,
        aesthetics = c("color", "fill")
      )
  }
  return(p)
}

# ggplot theme ==========================================
gg_theme <- function() {
  theme_bw() +
    theme(
      text = element_text(family = "Helvetica", color = "black", size = 6 / ggplot2:::.pt),
      rect = element_rect(fill = "transparent"),
      plot.title = ggtext::element_markdown(size = 7, hjust = 0.5),
      
      # panel options
      panel.background = element_rect(fill = "transparent"),
      panel.border = element_rect(
        linetype = "solid",
        color = "black",
        linewidth = 0.5,
        fill = NA
      ),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.25),
      panel.grid.minor = element_blank(),
      panel.spacing.y = unit(0, "lines"),
      
      # axis options
      axis.title = ggtext::element_markdown(size = 6, vjust = 0.5),
      axis.title.x = ggtext::element_markdown(size = 6, vjust = 0.5),
      axis.title.y = ggtext::element_markdown(size = 6, vjust = 0.5),
      axis.text = ggtext::element_markdown(size = 6, colour = "black"),
      axis.text.x = ggtext::element_markdown(size = 6, colour = "black"),
      axis.ticks = element_line(linewidth = 0.25, color = "black"),
      axis.ticks.length = unit(0.5, "mm"),
      
      # legend options
      legend.background = element_rect(fill = "transparent"),
      legend.key.size = unit(3, "mm"),
      legend.title = ggtext::element_markdown(size = 6),
      legend.text = element_text(size = 6, colour = "black"),
      legend.box.spacing = unit(-1, "mm"),
      legend.position = "none",
      
      # other
      strip.background = element_blank(),
      strip.text = element_text(size = 6, 
                                colour = "black", 
                                vjust = 0, 
                                face = "italic")
    )
}

# ggsave function ==========================================
ggsave_fixed = function(file, plot = ggplot2::last_plot(), 
                        units = "mm",
                        margin = 1, 
                        plot_width = 4,
                        plot_height = 4, 
                        width = round(dev.size()[1], digits = 1), 
                        height = round(dev.size()[1], digits = 1)) {
  pf = egg::set_panel_size(p = plot,
                           file = NULL, 
                           margin = unit(margin, units),
                           width = unit(plot_width, units), 
                           height = unit(plot_height, units))
  ggsave(file, plot = pf, units = units, width = width, height = height, dpi = 300)
}

# MA plot function ==========================================
ma_common <- function(results,
                      plot_title = "*MA Plot*",
                      log2fc_threshold = 1) {
  p <- ggplot(results, mapping = aes(
    x = log2(baseMean), y = log2FoldChange,
    text = paste0(
      symbol, "<br>padj: ",
      sprintf("%.3f", padj), "<br>FC: ",
      sprintf("%.2f", 2^log2FoldChange)
    )
  ))
  if ((results %>% filter(padj < 0.05) %>% summarise(length(padj))) == 0) {
    p <- p + ggplot2::geom_point(
      data = filter(results, padj > 0.05 | is.na(padj)),
      colour = color_1,
      size = 0.01
    )
  } else if (log2fc_threshold == 0) {
    p <- p +
      ggplot2::geom_point(
        data = filter(results, padj > 0.05 | is.na(padj)),
        colour = color_1,
        size = 0.01
      ) +
      ggplot2::geom_point(
        data = filter(results, padj < 0.05), colour = color_2, size = 0.05
      )
  } else {
    p <- p +
      ggplot2::geom_point(
        data = filter(results, 
                      between(log2FoldChange, -log2fc_threshold, log2fc_threshold) | is.na(padj)), 
        colour = color_1, size = 0.01
      ) +
      ggplot2::geom_point(
        data = filter(
          results, padj < 0.05 & abs(log2FoldChange) > log2fc_threshold), 
        colour = color_2, size = 0.05
      ) +
      ggplot2::geom_hline(yintercept = c(-log2fc_threshold, log2fc_threshold), 
                          linetype = "dotted")
  }
  p <- p + 
    #xlab(expression(paste("lo", g[2], " mean expression"))) +
    #ylab(expression(paste("lo", g[2], " fold-change"))) +
    xlab("log<sub>2</sub> mean expression") +
    ylab("log<sub>2</sub> fold-change") +
    geom_hline(yintercept = 0, linetype = "dotted") +
    theme_bw(base_size = 10, base_family = "Helvetica") +
    ggtitle(plot_title) +
    gg_theme() #+ theme(axis.text = element_text(size = 5, colour = "black"))
  return(p)
}


# MA plot function ==========================================
plot_ma <- function(results,
                    plot_title = "*MA Plot*",
                    log2fc_threshold = 0, 
                    size_sig = 0.05,
                    size_ns = 0.01,
                    color_ns = "#878787",
                    color_low = "#67001F",
                    color_high = "#F4A582"
) {
  results <- results %>% arrange(-padj)
  p <- ggplot(results, mapping = aes(
    x = log2(baseMean), y = log2FoldChange,
    text = paste0(
      symbol, "<br>padj: ",
      sprintf("%.3f", padj), "<br>FC: ",
      sprintf("%.2f", 2^log2FoldChange)
    )
  ))
  if ((results %>% filter(padj < 0.05) %>% summarise(length(padj))) == 0) {
    p <- p + ggplot2::geom_point(
      data = filter(results, padj > 0.05 | is.na(padj)),
      colour = color_ns,
      size = size_ns
    )
  } else if (log2fc_threshold == 0) {
    p <- p +
      ggplot2::geom_point(
        data = filter(results, padj > 0.05 | is.na(padj)),
        colour = color_ns,
        size = size_ns
      ) +
      ggplot2::geom_point(
        data = filter(results, padj < 0.05) %>% 
          arrange(-padj), aes(colour = padj), size = size_sig
      )
  } else {
    p <- p +
      ggplot2::geom_point(
        data = filter(results, 
                      between(log2FoldChange, -log2fc_threshold, log2fc_threshold) | is.na(padj)), 
        colour = color_ns, 
        size = size_ns
      ) +
      ggplot2::geom_point(
        data = filter(
          results, padj < 0.05 & abs(log2FoldChange) > log2fc_threshold), 
        colour = color_2, 
        size = size_sig
      ) +
      ggplot2::geom_hline(yintercept = c(-log2fc_threshold, log2fc_threshold), 
                          linetype = "dotted")
  }
  p <- p + 
    #xlab(expression(paste("lo", g[2], " mean expression"))) +
    #ylab(expression(paste("lo", g[2], " fold-change"))) +
    xlab("log<sub>2</sub> mean expression") +
    ylab("log<sub>2</sub> fold-change") +
    geom_hline(yintercept = 0, linetype = "dotted") +
    ggtitle(plot_title) +
    gg_theme() + 
    theme(legend.position = "right") + 
    scale_color_gradient(
      low = "#67001F", high = "#F4A582",
      limits = c(0, 0.05), oob = scales::squish
    )
  return(p)
}

# volcano plot function ==========================================
plot_volcano <- function(results,
                         plot_title = "*Volcano Plot*",
                         log2fc_threshold = 1, 
                         sig_point_size = 0.05,
                         NS_point_size = 0.01) {
  p <- ggplot(results, mapping = aes(
    x = log2FoldChange, y = -log10(padj),
    text = paste0(
      symbol, "<br>padj: ",
      sprintf("%.3f", padj), "<br>FC: ",
      sprintf("%.2f", 2^log2FoldChange)
    )
  ))
  if ((results %>% filter(padj < 0.05) %>% summarise(length(padj))) == 0) {
    p <- p + ggplot2::geom_point(
      data = filter(results, padj > 0.05 | is.na(padj)),
      colour = color_1,
      size = NS_point_size
    )
  } else if (log2fc_threshold == 0) {
    p <- p +
      ggplot2::geom_point(
        data = filter(results, padj > 0.05 | is.na(padj)),
        colour = color_1,
        size = NS_point_size
      ) +
      ggplot2::geom_point(
        data = filter(results, padj < 0.05), colour = color_2, size = sig_point_size
      )
  } else {
    p <- p +
      ggplot2::geom_point(
        data = filter(results, 
                      between(log2FoldChange, -log2fc_threshold, log2fc_threshold) | is.na(padj)), 
        colour = color_1, size = NS_point_size
      ) +
      ggplot2::geom_point(
        data = filter(
          results, padj < 0.05 & abs(log2FoldChange) > log2fc_threshold), 
        colour = color_2, size = sig_point_size
      ) +
      ggplot2::geom_vline(xintercept = c(-log2fc_threshold, log2fc_threshold), 
                          linetype = "dotted")
  }
  p <- p + 
    #xlab(expression(paste("lo", g[2], " mean expression"))) +
    #ylab(expression(paste("lo", g[2], " fold-change"))) +
    xlab("log<sub>2</sub> fold-change") +
    ylab("-log<sub>10</sub> padj") +
    geom_vline(xintercept = 0, linetype = "dotted") +
    geom_hline(yintercept = -log10(0.05), linetype = "dotted") +
    theme_bw(base_size = 10, base_family = "Helvetica") +
    ggtitle(plot_title) +
    gg_theme() #+ theme(axis.text = element_text(size = 5, colour = "black"))
  return(p)
}