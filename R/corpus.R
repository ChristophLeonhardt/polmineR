#' @include partition.R bundle.R S4classes.R
NULL

#' Get corpus/corpora available or used.
#' 
#' Calling \code{corpus()} will return a \code{data.frame} listing the corpora
#' described in the active registry directory, and some basic information on the
#' corpora. If \code{object} is an object inheriting from the \code{textstat},
#' or the \code{bundle} class, the corpus used to generate the object is
#' returned.
#' @param object An object inheriting from the \code{textstat} or \code{bundle} superclasses.
#' @exportMethod corpus
#' @rdname corpus-method
#' @examples
#' use("polmineR")
#' corpus()
#' 
#' p <- partition("REUTERS", places = "kuwait")
#' corpus(p)
#' 
#' pb <- partition_bundle("REUTERS", s_attribute = "id")
#' corpus(pb)
setGeneric("corpus", function(object) standardGeneric("corpus"))


#' @rdname corpus-method
setMethod("corpus", "textstat", function(object) object@corpus)

#' @rdname corpus-method
setMethod("corpus", "kwic", function(object) object@corpus)

#' @rdname corpus-method
setMethod("corpus", "character", function(object){
  new(
    "corpus",
    corpus = object,
    encoding = registry_get_encoding(object),
    key = character()
    )
})

#' @rdname corpus-method
setMethod("corpus", "bundle", function(object){
  unique(sapply(object@objects, function(x) x@corpus))
})

#' @rdname corpus-method
setMethod("corpus", "missing", function(){
  if (nchar(Sys.getenv("CORPUS_REGISTRY")) > 1){
    corpora <- CQI$list_corpora()
    y <- data.frame(
      corpus = corpora,
      size = unname(sapply(corpora,function(x) CQI$attribute_size(x, CQI$attributes(x, "p")[1], type = "p"))),
      template = unname(sapply(corpora, function(x) x %in% names(getOption("polmineR.templates")))),
      stringsAsFactors = FALSE
    )
  } else {
    y <- data.frame(corpus = character(), size = integer())
  }
  return(y)
})

setOldClass("Corpus")


#' Corpus class.
#' 
#' The R6 \code{Corpus} class offers a set of methods to retrieve and manage CWB
#' indexed corpora.
#' 
#' @field corpus character vector (length 1), a CWB corpus
#' @field encoding encoding of the corpus (typically 'UTF-8' or 'latin1'), assigned
#' automatically upon initialization of the corpus
#' @field cpos a two-column \code{matrix} with regions of a corpus underlying the
#' s-attributes of the \code{data.table} in field \code{s_attributes}
#' @field s_attributes a \code{data.table} with the values of a set of s-attributes
#' @field stat a \code{data.table} with counts
#' 
#' @section Arguments:
#' \describe{
#'   \item{corpus}{a corpus}
#'   \item{registryDir}{the directory where the registry file resides}
#'   \item{dataDir}{the data directory of the corpus}
#'   \item{p_attribute}{p-attribute, to perform count}
#'   \item{s_attributes}{s-attributes}
#'   \item{decode}{logical, whether to turn token ids into strings upon counting}
#'   \item{as.html}{logical}
#' }
#' 
#' @section Methods:
#' \describe{
#'   \item{\code{initialize(corpus, p_attribute = NULL, s_attributes = NULL)}}{Initialize a new object of class \code{Corpus}.}
#'   \item{\code{count(p_attribute = getOption("polmineR.p_attribute"), decode = TRUE)}}{Perform counts.}
#'   \item{\code{as.partition()}}{turn \code{Corpus} into a partition}
#'   \item{\code{getInfo(as.html = FALSE)}}{}
#'   \item{\code{showInfo()}}{}
#' }
#' 
#' @rdname Corpus-class
#' @export Corpus
#' @examples
#' use("polmineR")
#' REUTERS <- Corpus$new("REUTERS")
#' infofile <- REUTERS$getInfo()
#' if (interactive()) REUTERS$showInfo()
#' 
#' # use Corpus class to manage counts
#' REUTERS <- Corpus$new("REUTERS", p_attribute = "word")
#' REUTERS$stat
#' 
#' # use Corpus class for creating partitions
#' REUTERS <- Corpus$new("REUTERS", s_attributes = c("id", "places"))
#' usa <- partition(REUTERS, places = "usa")
#' sa <- partition(REUTERS, places = "saudi-arabia", regex = TRUE)
#' 
#' reut <- REUTERS$as.partition()
Corpus <- R6Class(
  
  "Corpus",
  
  public = list(
    
    corpus = NULL,
    registryDir = NULL,
    dataDir = NULL,
    encoding = NULL,
    cpos = NULL,
    p_attribute = NULL,
    s_attributes = NULL,
    size = NULL,
    stat = data.table(),
    
    initialize = function(corpus, p_attribute = NULL, s_attributes = NULL){
      
      stopifnot(is.character(corpus), length(corpus) == 1)
      if (!corpus %in% polmineR::corpus()[["corpus"]]) warning("corpus may not be available")
      self$corpus <- corpus
      
      self$registryDir <- Sys.getenv("CORPUS_REGISTRY")
      self$dataDir <- registry_get_home(corpus)
      self$encoding <- registry_get_encoding(corpus)
      self$size <- size(corpus)
      
      if (!is.null(p_attribute)){
        stopifnot(p_attribute %in% p_attributes(corpus))
        self$count(p_attribute)
      }
      
      if (!is.null(s_attributes)){
        dt <- decode(corpus, s_attribute = s_attributes)
        self$cpos <- as.matrix(dt[, 1:2])
        self$s_attributes <- dt[, 3:ncol(dt)]
        self$s_attributes[["struc"]] <- 0:(nrow(self$s_attributes) - 1)
        setcolorder(self$s_attributes, neworder = c(ncol(self$s_attributes), 1:(ncol(self$s_attributes) - 1)))
      }
      
      invisible(self)
    },
    
    getRegions = function(s_attribute){
      rngFile <- file.path(self$dataDir, paste(s_attribute, "avx", sep = "."))
      rngFileSize <- file.info(rngFile)$size
      rngFileCon <- file(description = rngFile, open = "rb")
      rng <- readBin(con = rngFileCon, what = integer(), size = 4L, n = rngFileSize, endian = "big")
      close(rngFileCon)
      dt <- data.table(matrix(rng, ncol = 2, byrow = TRUE))
      colnames(dt) <- c("cpos", "offset")
      y <- dt[,{list(cpos_left = .SD[["cpos"]][1], cpos_right = .SD[["cpos"]][nrow(.SD)])}, by = offset]
      y[, offset := NULL][, struc := seq.int(from = 0, to = nrow(y) - 1)]
      y
    },
    
    getStructuralAttributes = function(s_attribute){
      avsFile <- file.path(self$dataDir, paste(s_attribute, "avs", sep = "."))
      avxFile <- file.path(self$dataDir, paste(s_attribute, "avx", sep = "."))
      avs <- readBin(con = avsFile, what = character(), n = file.info(avsFile)$size) # n needs to be estimated
      avx <- readBin(con = avxFile, what = integer(), size = 4L, n = file.info(avxFile)$size, endian = "big")
      offset <- avx[seq.int(from = 2, to = length(avx), by = 2)]
      levels <- sort(unique.default(offset))
      rank <- match(offset, levels)
      avs[rank]
    },
    
    count2 = function(p_attribute){
      
      cntFile <- file.path(self$dataDir, paste(p_attribute, "corpus.cnt", sep = "."))
      cntFileSize <- file.info(cntFile)$size
      cntFileCon <- file(description = cntFile, open = "rb")
      dt <- data.table(
        count = readBin(con = cntFileCon, what = integer(), size = 4L, n = cntFileSize, endian = "big")
      )
      close(cntFileCon)
      
      lexiconFile <- file.path(self$dataDir, paste(p_attribute, "lexicon", sep = "."))
      lexiconFileSize <- file.info(lexiconFile)$size
      lexiconFileCon <- file(description = lexiconFile, open = "rb")
      dt[[p_attribute]] <- readBin(con = cntFileCon, what = character(), n = cntFileSize)
      close(lexiconFileCon)
      
      dt
      
      # the idx file: offset positions
      # idxFile <- file.path(self$dataDir, "word.lexicon.idx")
      # idxFileSize <- file.info(idxFile)$size
      # idxFileCon <- file(description = idxFile, open = "rb")
      # idx <- readBin(con = idxFileCon, what = integer(), size = 4L, n = idxFileSize, endian = "big")
      # close(idxFileCon)
    },
    
    # summary = function(s_attributes = c(period = "text_lp", date = "text_date", dummy = "text_id")){
    #   # generate bundle, each of which will be evaluated in consecutive steps
    #   lpCluster <- partition_bundle(
    #     self$corpus,
    #     def = setNames(list(".*"), s_attributes["dummy"]),
    #     var = setNames(list(NULL), s_attributes["period"]),
    #     regex = TRUE, mc = FALSE
    #   )
    #   # extract data
    #   corpusData <- lapply(
    #     lpCluster@objects,
    #     function(x) {
    #       dates <- as.Date(s_attributes(x, s_attributes["date"]))
    #       c(
    #         first = as.character(min(dates, na.rm = TRUE)),
    #         last = as.character(max(dates, na.rm = TRUE)),
    #         no_token = size(x)
    #       )
    #     })
    #   
    #   # assemling data.frame
    #   tab <- data.frame(do.call(rbind, corpusData))
    #   tab[,"no_token"] <- as.integer(as.vector(tab[,"no_token"]))
    #   tab <- cbind(tab, avg_no_token = round(tab[,"no_token"]/tab[,"no"], digits = 0))
    #   
    #   tab_all <- data.frame(
    #     first = tab[1, "first"],
    #     last = tab[nrow(tab), "last"],
    #     no_token = sum(tab[, "no_token"]),
    #     avg_no_token = round(sum(tab[,"no_token"])/sum(tab[, "no"]), digits = 0),
    #     row.names = "ALL"
    #   )
    #   tab <- rbind(tab, tab_all)
    #   tab
    # },
    
    count = function(p_attribute = getOption("polmineR.p_attribute"), decode = TRUE){
      self$p_attribute <- p_attribute
      self$stat <- count(self$corpus, p_attribute = p_attribute, decode = decode)@stat
    },
    
    # copy = function(registryDir, dataDir = NULL){
    #   indexedCorpusDirPkg
    #   lapply(
    #     list.files(indexedCorpusDirPkg, full.names = TRUE),
    #     function(x) file.copy(from=x, to=file.path(indexedCorporaDir, registryFile))
    #   )
    #   
    # },
    
    as.partition = function(){
      new(
        "partition",
        corpus = self$corpus,
        encoding = self$encoding,
        cpos = matrix(c(0, (size(self$corpus) - 1)), nrow = 1),
        stat = self$stat,
        size = self$size,
        p_attribute = if (is.null(self$p_attribute)) character() else self$p_attribute
      )
    },
    
    getInfo = function(as.html = FALSE){
      registry_get_info(self$corpus)
    },
    
    showInfo = function(){
      infoFile <- self$getInfo()
      if (file.exists(infoFile)){
        content <- readLines(infoFile)
        if (grepl(".md$", infoFile)){
          content <- markdown::markdownToHTML(text = content)
          content <-  htmltools::HTML(gsub("^.*<body>(.*?)</body>.*?$", "\\1", as.character(content)))
        } else {
          content <- htmltools::HTML(content)
        }
      } else {
        content <- htmltools::HTML("</br><i>corpus info file does not exist</i>")
      }
      if (interactive()) htmltools::html_print(content)
      invisible(content)
    }
  )
)



#' @details The `$`-method will assign the argument \code{name} to the slot
#'   \code{key} and return the modified object.
#' @examples
#' corp <- corpus("GERMAPARLMINI")
#' corp2 <- corp$speaker
#' corp2@@key
#' @rdname corpus_class
#' @exportMethod $
setMethod("$", "corpus", function(x, name){
  x@key <- name
  x
})


#' @examples
#' x <- corpus("GERMAPARLMINI")
#' x$date == "2009-10-28"
#' @rdname corpus_class
#' @exportMethod ==
setMethod("==", "corpus", function(e1, e2){
  partition(e1@corpus, def = setNames(object = list(e2), nm = e1@key))
})



#' @examples
#' x <- corpus("GERMAPARLMINI")
#' x$party != "NA"
#' @rdname corpus_class
#' @exportMethod !=
setMethod("!=", "corpus", function(e1, e2){
  available <- s_attributes(e1@corpus, e1@key)
  keep <- available[!available %in% e2]
  partition(e1@corpus, def = setNames(object = list(keep), nm = e1@key))
})



#' @examples
#' x <- corpus("GERMAPARLMINI")
#' x$date %in% c("2009-10-27", "2009-10-28")
#' @rdname corpus_class
#' @exportMethod %in%
setMethod("%in%", "corpus", function(x, table){
  partition(x@corpus, def = setNames(object = list(table), nm = x@key))
})



#' @examples
#' x <- corpus("GERMAPARLMINI")
#' y <- zoom(x, date == "2009-10-28")
#' 
#' x <- partition("GERMAPARLMINI", interjection = "speech")
#' m <- zoom(x, date == "2009-10-28" & speaker == "Angela Dorothea Merkel")
#' 
#' not_unknown <- zoom(x, party != c("NA", "FDP"))
#' s_attributes(not_unknown, "party")
#' @rdname corpus_class
#' @exportMethod subset
setMethod("zoom", "corpus", function(x, ...){
  cmds <- strsplit(deparse(substitute(...)), split = "\\s*&\\s*")[[1]]
  x_s_attributes <- s_attributes(x@corpus)
  for (cmd in cmds){
    for (s_attr in x_s_attributes) cmd <- gsub(sprintf("(%s)", s_attr), "x$\\1", cmd)
    x <- eval(parse(text = cmd))
  }
  x
})


