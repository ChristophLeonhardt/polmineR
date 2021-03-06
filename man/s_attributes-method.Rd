% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/s_attributes.R
\docType{methods}
\name{s_attributes}
\alias{s_attributes}
\alias{s_attributes,character-method}
\alias{s_attributes,partition-method}
\title{Get s-attributes.}
\usage{
s_attributes(.Object, ...)

\S4method{s_attributes}{character}(.Object, s_attribute = NULL,
  unique = TRUE, regex = NULL, ...)

\S4method{s_attributes}{partition}(.Object, s_attribute = NULL,
  unique = TRUE, ...)
}
\arguments{
\item{.Object}{either a \code{partition} object or a character vector specifying a CWB corpus}

\item{...}{to maintain backward compatibility, of argument \code{sAttribute} is used}

\item{s_attribute}{name of a specific s-attribute}

\item{unique}{logical, whether to return unique values only}

\item{regex}{filter return value by applying a regex}
}
\value{
a character vector
}
\description{
Structural annotations (s-attributes) of a corpus provide metainformation for
regions of tokens. Gain access to the s-attributes available for a corpus or partition,
or the values of s-attributes in a corpus/partition with the \code{s_attributes}-method.
}
\details{
Importing XML into the Corpus Workbench (CWB) turns elements and element
attributes into so-called s-attributes. There are two uses of the s_attributes-method: If the 
\code{s_attribute} parameter is NULL (default), the return value is a character vector
with all s-attributes present in a corpus.

If s_attribute is the name of a specific s-attribute (a length 1 character vector), the
values of the s-attributes available in the corpus/partition are returned.

If a character vector of s-attributes is provided, the method will return a \code{data.table}.
}
\examples{
use("polmineR")
  
s_attributes("GERMAPARLMINI")
s_attributes("GERMAPARLMINI", "date") # dates of plenary meetings
  
P <- partition("GERMAPARLMINI", date = "2009-11-10")
s_attributes(P)
s_attributes(P, "speaker") # get names of speakers
}
