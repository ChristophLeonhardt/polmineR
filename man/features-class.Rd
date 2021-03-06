% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/S4classes.R, R/features.R, R/format.R, R/view.R
\docType{class}
\name{features-class}
\alias{features-class}
\alias{features_cooccurrences-class}
\alias{features_ngrams-class}
\alias{features_bundle-class}
\alias{summary,features-method}
\alias{show,features-method}
\alias{summary,features_bundle-method}
\alias{format,features-method}
\alias{view,features-method}
\title{Feature selection by comparison.}
\usage{
\S4method{summary}{features}(object)

\S4method{show}{features}(object)

\S4method{summary}{features_bundle}(object)

\S4method{format}{features}(x, digits = 2L)

\S4method{view}{features}(.Object)
}
\arguments{
\item{object}{A \code{features} or \code{features_bundle} object.}

\item{x}{A \code{features} object.}

\item{digits}{Integer indicating the number of decimal places (round) or
significant digits (signif) to be used.}

\item{.Object}{a \code{features} object.}
}
\description{
The  \code{features}-method returns a \code{features}-object. Several
\code{features}-objects can be combined into a \code{features_bundle}-object.
}
\details{
A set of \code{features} objects can be combined into a \code{features_bundle}.
Typically, a \code{features_bundle} will result from applying the \code{features}-method
on a \code{partition_bundle}. See the documentation for \code{bundle} to learn about
the methods for \code{bundle} objects that are available for a \code{features_bundle}.
}
\section{Slots}{

\describe{
\item{\code{corpus}}{The CWB corpus the features are derived from, a \code{character} vector of length 1.}

\item{\code{p_attribute}}{Object of class \code{character}.}

\item{\code{encoding}}{Object of class \code{character}.}

\item{\code{corpus}}{Object of class \code{character}.}

\item{\code{stat}}{Object of class \code{data.frame}.}

\item{\code{size_coi}}{Object of class \code{integer}.}

\item{\code{size_ref}}{Object of class \code{integer}.}

\item{\code{included}}{Object of class \code{logical} whether corpus of interest is included in reference corpus}

\item{\code{method}}{Object of class \code{character} statisticalTest used}

\item{\code{call}}{Object of class \code{character} the call that generated the object}
}}

\author{
Andreas Blaette
}
