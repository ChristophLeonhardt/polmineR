#' @include polmineR.R  S4classes.R
NULL


#' @importFrom graphics dotchart grid par plot points rect text
#' @importFrom stats formula ftable setNames xtabs
#' @importFrom utils View browseURL download.file setTxtProgressBar txtProgressBar untar write.csv
#' @importFrom tm TermDocumentMatrix DocumentTermMatrix
#' @importFrom tm as.TermDocumentMatrix as.DocumentTermMatrix
#' @importFrom data.table data.table setorderv dcast setnames setkeyv setcolorder as.data.table rbindlist setkey dcast.data.table
#' @importFrom Matrix rowSums colSums
NULL

# defined globaly to avoid R CMD check errors, as recommende by vignette in data.table package
`:=` <- function(...) NULL
.BY <- .GRP <- .SD <- .N <- NULL


setOldClass("htmlwidget")

#' @exportMethod zoom
#' @noRd
setGeneric("zoom", function(x, ...) standardGeneric("zoom"))


#' polmineR-package
#' 
#' A library for corpus analysis using the Corpus Workbench (CWB) as an
#' efficient back end for indexing and querying large corpora.
#' 
#' The package offers functionality to flexibly create partitions and to carry
#' out basic statistical operations (count, co-occurrences etc.). The original
#' full text of documents can be reconstructed and inspected at any time. Beyond
#' that, the package is intended to serve as an interface to packages
#' implementing advanced statistical procedures. Respective data structures
#' (document term matrices, term co- occurrence matrices etc.) can be created
#' based on the indexed corpora.
#' 
#' A session registry directory (see \code{registry()}) combines the registry
#' files for corpora that may reside in anywhere on the system. Upon loading
#' \code{polmineR}, the files in the registry directory defined by the
#' environment variable CORPUS_REGISTRY are copied to the session registry
#' directory. To see whether the environment variable CORPUS_REGISTRY is set,
#' use the `Sys.getenv()`-function. Corpora wrapped in R data packages can be
#' activated using the function \code{use()}.
#' 
#' The package includes a draft shiny app that can be called using
#' \code{polmineR()}.
#' 
#' @author Andreas Blaette (andreas.blaette@@uni-due.de)
#' @keywords package
#' @docType package
#' @aliases polmineR polmineR-package
#' @rdname polmineR-package
#' @name polmineR-package
#' @references Jockers, Matthew L. (2014): \emph{Text Analysis with R for Students of Literature}.
#' Cham et al: Springer.
#' @references Baker, Paul (2006): \emph{Using Corpora in Discourse Analysis}. London: continuum.
#' @export polmineR
#' @importFrom RcppCWB cqp_initialize cqp_is_initialized
#' @importFrom parallel detectCores
#' @examples
#' use("polmineR") # activate demo corpora included in the package
#' 
#' # Core methods applied to corpus
#' 
#' C <- count("REUTERS", query = "oil")
#' C <- count("REUTERS", query = c("oil", "barrel"))
#' C <- count("REUTERS", query = '"Saudi" "Arab.*"', breakdown = TRUE, cqp = TRUE)
#' D <- dispersion("REUTERS", query = "oil", s_attribute = "id")
#' K <- kwic("REUTERS", query = "oil")
#' CO <- cooccurrences("REUTERS", query = "oil")
#' 
#' 
#' # Core methods applied to partition
#' 
#' kuwait <- partition("REUTERS", places = "kuwait", regex = TRUE)
#' C <- count(kuwait, query = "oil")
#' D <- dispersion(kuwait, query = "oil", s_attribute = "id")
#' K <- kwic(kuwait, query = "oil", meta = "id")
#' CO <- cooccurrences(kuwait, query = "oil")
#'
#'
#' # Go back to full text
#' 
#' p <- partition("REUTERS", id = 127)
#' read(p)
#' h <- html(p)
#' h_highlighted <- highlight(h, highlight = list(yellow = "oil"))
#' h_highlighted
#'
#'
#' # Generate term document matrix
#' 
#' pb <- partition_bundle("REUTERS", s_attribute = "id")
#' cnt <- count(pb, p_attribute = "word")
#' tdm <- as.TermDocumentMatrix(cnt, col = "count")
polmineR <- function(){
  if (requireNamespace("shiny", quietly = TRUE)){
    shiny::runApp(system.file("shiny", package = "polmineR"))
  } else {
    stop("package 'shiny' required but not installed")
  }
}



# setOldClass("dfmSparse") # class defined in quanteda-package
setOldClass("igraph")
setOldClass("html")


#' @exportMethod name
#' @noRd
setGeneric("name", function(x) standardGeneric("name"))

#' @exportMethod name<-
#' @noRd
setGeneric("name<-", function(x, value) standardGeneric("name<-"))

