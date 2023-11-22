# bioMart function ==========================================
get_biomart_gene_mapping <- function(mart, id_attribute, mapped_attribute, ...) {
  if (!all(c(
    id_attribute %in% list(...)[["attributes"]],
    mapped_attribute %in% list(...)[["attributes"]]
  ))) {
    stop("Id attribute or mapped attribute not present in attribute list.")
  }

  mapping <- getBM(mart = mart, ...)
  all_values <- data.frame(id = list(...)[["values"]], stringsAsFactors = F) %>%
    left_join(mapping, by = c("id" = id_attribute)) %>%
    mutate(!!as.symbol(mapped_attribute) := case_when(
      is.na(!!as.symbol(mapped_attribute)) ~ id,
      !!as.symbol(mapped_attribute) == "" ~ id,
      TRUE ~ !!as.symbol(mapped_attribute)
    )) %>%
    group_by(id) %>%
    filter(row_number() == 1) %>%
    ungroup() %>%
    mutate(!!as.symbol(id_attribute) := id, .before = id) %>%
    dplyr::select(-id)

  return(all_values)
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
  
  no_colors <- pca_data[, "group"] %>% unique() %>% length()
  
  p <- pca_data %>%
    ggplot2::ggplot(ggplot2::aes(PC1, PC2, color = !!as.symbol("group"))) +
    ggplot2::geom_point(size = 2)
  
  if (plot_center == TRUE) {
    p <- p +
      ggplot2::geom_segment(
        ggplot2::aes(x = PC1, y = PC2, xend = xend, yend = yend), 
        linewidth = 0.3, 
        linetype = linetype) +
      ggplot2::geom_point(
        data = segments, 
        ggplot2::aes(x = xend, y = yend), 
        size = 0.5)
  }
  
  p <- p +
    ggplot2::xlab(paste0("PC1: ", percent_var[1], "% variance")) +
    ggplot2::ylab(paste0("PC2: ", percent_var[2], "% variance")) +
    gg_theme() + 
    ggplot2::theme(legend.position = "top")
  
  if (is.null(palette)) {
    p <- p +
      ggplot2::scale_color_manual(values = viridis::viridis(no_colors + 1))
  } else {
    p <- p +
      ggplot2::scale_color_manual(values = palette)
  }
  return(p)
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
  ggsave(file, 
         plot = pf, 
         units = units, 
         width = width, 
         height = height,
         limitsize = FALSE,
         dpi = 300)
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
      mgi_symbol, "<br>padj: ",
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
        data = filter(results, padj < 0.05) %>% arrange(-padj), aes(colour = padj), size = size_sig
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
      mgi_symbol, "<br>padj: ",
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



# GSEA rank function ==========================================
create_gsea_rank <- function(data,
                             out = NULL,
                             ranking_equation = ~ -log10(pvalue) * sign(log2FoldChange),
                             gene_id_column = ensembl_gene_id,
                             .inf = "replace",
                             remove_ensembl_gene_id = 0) {
  out_df <- data %>%
    dplyr::mutate(rank = !!lazyeval::f_rhs(ranking_equation)) %>%
    dplyr::select({{ gene_id_column }}, rank) %>%
    dplyr::arrange(desc(rank)) %>%
    dplyr::filter({{ gene_id_column }} != {{ remove_ensembl_gene_id }}) %>%
    tidyr::drop_na()

  if (.inf == "drop") {
    out_df <- out_df %>%
      dplyr::filter(is.finite(rank))
  } else if (.inf == "replace") {
    min_val <- out_df %>%
      dplyr::filter(is.finite(rank)) %>%
      dplyr::pull(rank) %>%
      min()
    max_val <- out_df %>%
      dplyr::filter(is.finite(rank)) %>%
      pull(rank) %>%
      max()

    out_df$rank[which(out_df$rank == Inf)] <- max_val + 0.01 * max_val
    out_df$rank[which(out_df$rank == -Inf)] <- min_val + 0.01 * min_val
  }

  if (!is.null(out)) {
    write.table(out_df,
      out,
      sep = "\t",
      row.names = F,
      quote = F
    )
  } else {
    return(out_df)
  }
}

# ggplot theme ==========================================
gg_theme <- function() {
  theme_bw() +
    theme(
      text = element_text(family = "Helvetica", color = "black", size = 6),
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
      panel.grid.minor = element_line(color = NA),
      panel.spacing.y = unit(0, "lines"),

      # axis options
      axis.title = ggtext::element_markdown(size = 7, vjust = 0.5),
      axis.title.x = ggtext::element_markdown(size = 7, vjust = 0.5),
      axis.title.y = ggtext::element_markdown(size = 7, vjust = 0.5),
      axis.text = ggtext::element_markdown(size = 7, colour = "black"),
      axis.ticks = element_line(linewidth = 0.25, color = "black"),
      axis.ticks.length = unit(0.5, "mm"),

      # legend options
      legend.background = element_rect(fill = "transparent"),
      legend.key.size = unit(3, "mm"),
      legend.title = element_text(size = 6),
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

# Read amiGO json ==========================================
read_amigo_json = function(jsonfile) {
  map_dfr(jsonfile$overrepresentation$group, function(y) {
    if(length(y$result) == 3 &
       !is.list(y$result[[2]])) {
      data.frame(t(c(id = y$result$term$id,
                     label = y$result$term$label,
                     fold_enrichment = y$result$input_list$fold_enrichment,
                     pvalue = y$result$input_list$pValue,
                     level = y$result$term$level)))
    } else {
      map_dfr(y$result, function(x) {
        data.frame(t(c(id = x$term$id,
                       label = x$term$label,
                       fold_enrichment = x$input_list$fold_enrichment,
                       pvalue = x$input_list$pValue,
                       level = x$term$level)))
      })
    }
  }) %>%
    drop_na() %>%
    mutate(fold_enrichment = as.double(fold_enrichment), 
           pvalue = as.double(pvalue), 
           level = as.integer(level))
}

# Plot pathways function ------
plot_pathways_rank = function(pathway_data, 
                              rank_include, 
                              x_axis,
                              y_axis,
                              bar_fill,
                              pathway_name_replace = NULL,
                              plot_x_text = T,
                              plot_legend = T,
                              ylab_text = NULL,
                              legend_text = NULL,
                              label_offset = 1) {
  
  if(max(rank_include) > nrow(pathway_data)) stop("Some ranks not found in filtered dataset.")
  pathway_data = pathway_data %>%
    arrange(desc({{ x_axis }})) %>%
    mutate(rank_of = paste0(pathway_rank, "/", nrow(.))) %>%
    filter(pathway_rank %in% rank_include) 
  
  if(is.null(pathway_name_replace)) {
    pathway_data = pathway_data %>% 
      mutate({{ y_axis }} := stringr::str_replace_all({{ y_axis }}, "_", " ")) %>%
      mutate({{ y_axis }} := tools::toTitleCase(tolower({{ y_axis }}))) %>%
      mutate({{ y_axis }} := factor({{ y_axis }}, levels = rev({{ y_axis }})))
  } else  {
    pathways_replace <- read.delim(file = pathway_name_replace, sep = "", header = T)
    replacements <- c(pathways_replace$replacement)
    names(replacements) <- c(pathways_replace$original)
    pathway_data = pathway_data %>% 
      mutate({{ y_axis }} := stringr::str_replace_all({{ y_axis }}, "_", " ")) %>%
      mutate({{ y_axis }} := tools::toTitleCase(tolower({{ y_axis }}))) %>%
      mutate({{ y_axis }} := str_replace_all({{ y_axis }}, pattern = replacements)) %>%
      mutate({{ y_axis }} := factor({{ y_axis }}, levels = rev({{ y_axis }})))
  }
  
  p = pathway_data %>%
    ggplot(aes(x = {{ y_axis }}, y = {{ x_axis }})) +
    geom_bar(stat = "identity", aes(fill = {{ bar_fill }}), linewidth = 1) + 
    gg_theme() +
    theme(axis.line = element_line(colour = "black", linewidth=0.33), 
          plot.title.position = "plot",  
          panel.border = element_blank()) + 
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    geom_text(aes(label = rank_of), y=(round(
      max(pathway_data[[deparse(substitute(x_axis))]]))*label_offset), 
              size = 6/ggplot2:::.pt, color ="#878787") +
    coord_flip() + 
    scale_fill_viridis() + 
    xlab("") 
  
  if(!is.null(ylab_text)) { p = p + ylab(ylab_text) }
  if(!is.null(legend_text)) { p = p + labs(fill=legend_text)}
  if(plot_legend == F) { p = p + theme(legend.position = "none") }
  
  if(plot_x_text == F) {
    cat(as.character(pathway_data[[deparse(substitute(y_axis))]]), sep = "\n")
    p = p +
      theme(axis.text.y = element_blank())
  }
  p
}



# get_gsea_files_from_dir ------
get_gsea_files_from_dir = function(dirpath, pattern) {
  file_df = data.frame(full_path = dir(dirpath, 
                                       pattern=paste0(pattern,".*tsv"), 
                                       full.names = T, 
                                       recursive = T)) %>%
    separate(full_path, into = c("path", "file"), sep = paste0("/", pattern), remove = F) %>%
    mutate(file = paste0(pattern, file))
  return(file_df)
}

# rank_how ------
rank_how = function(descending) {
  if(descending == T) {
    return(dplyr::desc)
  } else  {
    return(identity)
  }
}

# read_gsea ------
read_gsea = function(filename, rank_by = nes, descending = T) {
  orientation = rank_how(descending)
  
  read.table(filename, header = TRUE, sep = "\t") %>%
    dplyr::select(-X) %>%
    setNames(c("name", "link", "details", "size", "es", "nes", "nom_pval", 
               "fdr_qval", "fwer_pval", "rank_at_max", "leading_edge")) %>%
    mutate(file = filename) %>%
    arrange(orientation(abs({{ rank_by }}))) %>%
    mutate(pathway_rank = row_number()) %>%
    mutate(nom_pval = nom_pval + 0.00001) %>%
    mutate(fdr_qval = fdr_qval + 0.00001)
}

# filter_pathways ------
filter_pathways = function(pathway_data, score_column, pvalue_column, rank_by,
                           score_threshold = 0, pvalue_threshold = 0.05,  
                           descending = T) {
  
  orientation = rank_how(descending)
  
  pathway_data %>%
    filter(abs({{ score_column }}) > score_threshold) %>%
    filter({{ pvalue_column }} < pvalue_threshold ) %>%
    arrange(orientation(abs({{ rank_by }}))) %>%
    mutate(pathway_rank = row_number())
}

# batch_read_filter_gsea ------
batch_read_filter_gsea = function(dir = ".", 
                                  pattern = "gsea_report_for",
                                  score_threshold = 0, 
                                  pvalue_threshold = 0.05) {
  
  files_df = get_gsea_files_from_dir(dir, pattern)
  
  map_dfr(unique(files_df$path), function(x) {
    filtered_df = files_df %>%
      filter(path == x)
    map_dfr(filtered_df$file, function(y) {
      read_gsea(paste0(x, "/", y)) 
    }) %>%
      filter_pathways(score_column = nes,
                      pvalue_column = fdr_qval,
                      rank_by = nes,
                      score_threshold = score_threshold,
                      pvalue_threshold = pvalue_threshold)
  })
}

# plot_pathways_rank_old ------
plot_pathways_rank_old = function(pathway_data, 
                              rank_include, 
                              x_axis,
                              y_axis,
                              bar_fill,
                              pathway_name_replace = NULL,
                              plot_x_text = T,
                              plot_legend = T,
                              ylab_text = NULL,
                              legend_text = NULL,
                              label_offset = 0.6) {
  
  if(max(rank_include) > nrow(pathway_data)) stop("Some ranks not found in filtered dataset.")
  pathway_data = pathway_data %>%
    #mutate(pathway_rank = row_number()) %>%
    arrange(desc({{ x_axis }})) %>%
    mutate(rank_of = paste0(pathway_rank, "/", nrow(.))) %>%
    filter(pathway_rank %in% rank_include) 
  
  if(is.null(pathway_name_replace)) {
    pathway_data = pathway_data %>% 
      mutate({{ y_axis }} := stringr::str_replace_all({{ y_axis }}, "_", " ")) %>%
      mutate({{ y_axis }} := tools::toTitleCase(tolower({{ y_axis }}))) %>%
      mutate({{ y_axis }} := factor({{ y_axis }}, levels = rev({{ y_axis }})))
  } else  {
    pathways_replace <- read.delim(file = pathway_name_replace, sep = "", header = T)
    replacements <- c(pathways_replace$replacement)
    names(replacements) <- c(pathways_replace$original)
    pathway_data = pathway_data %>% 
      mutate({{ y_axis }} := stringr::str_replace_all({{ y_axis }}, "_", " ")) %>%
      mutate({{ y_axis }} := tools::toTitleCase(tolower({{ y_axis }}))) %>%
      mutate({{ y_axis }} := str_replace_all({{ y_axis }}, pattern = replacements)) %>%
      mutate({{ y_axis }} := factor({{ y_axis }}, levels = rev({{ y_axis }})))
  }
  
  p = pathway_data %>%
    ggplot(aes(x = {{ y_axis }}, y = {{ x_axis }})) +
    #geom_bar(stat = "identity", aes(fill = -log10({{ bar_fill }})), size = 1) +
    geom_bar(stat = "identity", aes(fill = {{ bar_fill }}), size = 1) + 
    theme_classic(base_size = 10, base_family = "Helvetica") +
    theme(text = element_text(family="Helvetica", color="black", size = 5),
          rect = element_rect(fill = "transparent"),
          legend.position = "none",
          plot.title = ggtext::element_markdown(size = 7, hjust = 0.5),
          axis.text = element_text(size=6, colour = "black"),
          axis.ticks = element_line(size = 0.33, colour = "black"),
          axis.line = element_line(size = 0.33, colour = "black"),
          axis.title = element_text(size = 6),
          panel.background = element_rect(fill="transparent"),
          #panel.border = element_rect(fill = NA), 
          panel.grid.major = element_line(color = "grey93"), 
          panel.grid.minor = element_line(color = NA)) + 
    #geom_text(aes(label = rank_of, y=label_offset), size = 5*0.36) +
    geom_text(aes(label = rank_of), nudge_y = ((-1)*sign(pathway_data[[deparse(substitute(x_axis))]])*label_offset),size = 5*0.36, color = "#878787") +
    coord_flip() + 
    scale_fill_viridis() + 
    xlab("") 
  
  if(!is.null(ylab_text)) { p = p + ylab(ylab_text) }
  if(!is.null(legend_text)) { p = p + labs(fill=legend_text)}
  if(plot_legend == F) { p = p + theme(legend.position = "none") }
  
  if(plot_x_text == F) {
    cat(as.character(pathway_data[[deparse(substitute(y_axis))]]), sep = "\n")
    p = p +
      theme(axis.text.y = element_blank())
  }
  p
}


