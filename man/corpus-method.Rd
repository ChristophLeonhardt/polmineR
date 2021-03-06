% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/corpus.R
\docType{methods}
\name{corpus}
\alias{corpus}
\alias{corpus,textstat-method}
\alias{corpus,kwic-method}
\alias{corpus,character-method}
\alias{corpus,bundle-method}
\alias{corpus,missing-method}
\title{Get corpus/corpora available or used.}
\usage{
corpus(object)

\S4method{corpus}{textstat}(object)

\S4method{corpus}{kwic}(object)

\S4method{corpus}{character}(object)

\S4method{corpus}{bundle}(object)

\S4method{corpus}{missing}()
}
\arguments{
\item{object}{An object inheriting from the \code{textstat} or \code{bundle} superclasses.}
}
\description{
Calling \code{corpus()} will return a \code{data.frame} listing the corpora
described in the active registry directory, and some basic information on the
corpora. If \code{object} is an object inheriting from the \code{textstat},
or the \code{bundle} class, the corpus used to generate the object is
returned.
}
\examples{
use("polmineR")
corpus()

p <- partition("REUTERS", places = "kuwait")
corpus(p)

pb <- partition_bundle("REUTERS", s_attribute = "id")
corpus(pb)
}
