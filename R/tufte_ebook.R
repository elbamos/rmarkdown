
#' Tufte e-Book format (PDF)
#'
#' Template for creating an e-book based on the style of
#' Edward R. Tufte and Richard Feynman.
#'
#' @inheritParams pdf_document
#'
#' @param latex_engine LaTeX engine for producing PDF output. Options are
#'   "pdflatex", "lualatex", and "xelatex".  Note that lualatex may have
#'   problems with text spacing, and that pdflatex may have memory issues
#'   when using tikzDevice.
#'   
#' @export
tufte_ebook <- function(  toc = TRUE,
                          toc_depth = 3,
                          number_sections = TRUE,
                          fig_width = 4,
                          fig_height = 2.5,
                          fig_crop = TRUE,
                          highlight = "default",
                          keep_tex = FALSE,
                          latex_engine = "xelatex",
                          includes = NULL,
                          pandoc_args = NULL,
                          ...
                          ) {

  # resolve default highlight
  if (identical(highlight, "default"))
    highlight <- "pygments"

  # get the tufte handout template
  template <-  system.file(
    "rmarkdown/templates/tufte_ebook/resources/tufte-ebook.tex",
    package = "rmarkdown"
  )

  # call the base pdf_document format with the appropriate options
  format <- pdf_document(fig_width = fig_width,
                                    fig_height = fig_height,
                                    fig_crop = fig_crop,
                                    highlight = highlight,
                                    keep_tex = keep_tex,
                                    latex_engine = latex_engine,
                                    includes = includes,
                                    pandoc_args = pandoc_args,
                                    toc = toc,
                                    toc_depth = toc_depth,
                                    template = template,
                                    number_sections = number_sections,
                                    ...
                                    )


  # create knitr options (ensure opts and hooks are non-null)
  knitr_options <- knitr_options_pdf(fig_width, fig_height, fig_crop)
  if (is.null(knitr_options$opts_knit))
    knitr_options$opts_knit <- list()
  if (is.null(knitr_options$knit_hooks))
    knitr_options$knit_hooks <- list()

  # set options
  knitr_options$opts_chunk$tidy <- TRUE
  knitr_options$opts_knit$width <- 45

  # set hooks for special plot output
  knitr_options$knit_hooks$plot <- function(x, options) {

    # determine caption (if any)
    caption <- ifelse(is.null(options$fig.cap),
                      "",
                      paste("\\caption{", options$fig.cap, "}\n", sep = ""))

    # determine figure type
    if (isTRUE(options$fig.margin))
      figtype <- "marginfigure"
    else if (isTRUE(options$fig.fullwidth))
      figtype <- "figure*"
    else
      figtype <- "figure"

    # return the latex
    paste(sprintf('\\begin{%s}\n \\includegraphics{%s}\n%s\\end{%s}\n',
                  figtype, x, caption, figtype))
  }

  # override the knitr settings of the base format and return the format
  format$knitr <- knitr_options
  format
}
