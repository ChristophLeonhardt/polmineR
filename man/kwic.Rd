% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kwic.R
\docType{methods}
\name{kwic}
\alias{kwic}
\alias{kwic,context-method}
\alias{kwic,partition-method}
\alias{kwic,character-method}
\title{KWIC/concordance output.}
\usage{
kwic(.Object, ...)

\S4method{kwic}{context}(.Object,
  s_attributes = getOption("polmineR.meta"), cpos = TRUE,
  verbose = FALSE, ...)

\S4method{kwic}{partition}(.Object, query, cqp = is.cqp,
  left = getOption("polmineR.left"),
  right = getOption("polmineR.right"),
  s_attributes = getOption("polmineR.meta"), p_attribute = "word",
  boundary = NULL, cpos = TRUE, stoplist = NULL,
  positivelist = NULL, regex = FALSE, verbose = TRUE, ...)

\S4method{kwic}{character}(.Object, query, cqp = is.cqp, check = TRUE,
  left = as.integer(getOption("polmineR.left")),
  right = as.integer(getOption("polmineR.right")),
  s_attributes = getOption("polmineR.meta"), p_attribute = "word",
  boundary = NULL, cpos = TRUE, stoplist = NULL,
  positivelist = NULL, regex = FALSE, verbose = TRUE,
  progress = TRUE, ...)
}
\arguments{
\item{.Object}{A (length-one) \code{character} vector with the name of a CWB
corpus, a \code{partition} or \code{context} object.}

\item{...}{Further arguments, used to ensure backwards compatibility.}

\item{s_attributes}{Structural attributes (s-attributes) to include into
output table as metainformation.}

\item{cpos}{Logical, if \code{TRUE}, the corpus positions ("cpos") if the hits will
be included in the \code{kwic}-object that is returned.}

\item{verbose}{Logical, whether to output progress messages}

\item{query}{A query, CQP-syntax can be used.}

\item{cqp}{Either a logical value (\code{TRUE} if \code{query} is a CQP
query), or a function to check whether query is a CQP query or not
(defaults to auxiliary function \code{is.query}).}

\item{left}{Number of tokens to the left of query match.}

\item{right}{Number of tokens to the right of query match.}

\item{p_attribute}{The p-attribute, defaults to 'word'.}

\item{boundary}{If provided, a length-one character vector stating an
s-attribute that will be used to check the boundaries of the text.}

\item{stoplist}{Terms or ids to prevent a concordance from occurring in
results.}

\item{positivelist}{Terms or ids required for a concordance to occurr in
results}

\item{regex}{Logical, whether stoplist/positivelist is interpreted as regular
expression}

\item{check}{A \code{logical} value, whether to check validity of CQP query
using \code{check_cqp_query}.}

\item{progress}{Logical, whether to show progress bars.}
}
\description{
Prepare and show concordances / keyword-in-context (kwic).
}
\details{
The method works with a whole CWB corpus defined by a  character vector, and
can be applied on a \code{partition}- or a \code{context} object.

If a \code{positivelist} ist supplied, only concordances will be kept if at
least one of the terms from the \code{positivelist} occurrs in the context of
the query match. Use argument \code{regex} if the positivelist should be
interpreted as regular expressions. Tokens from the positivelist will be
highlighted in the output table.
}
\examples{
use("polmineR")
K <- kwic("GERMAPARLMINI", "Integration")
K <- kwic(
  "GERMAPARLMINI",
  "Integration", left = 20, right = 20,
  s_attributes = c("date", "speaker", "party")
)
K <- kwic(
  "GERMAPARLMINI",
  '"Integration" [] "(Menschen|Migrant.*|Personen)"', cqp = TRUE,
  left = 20, right = 20,
  s_attributes = c("date", "speaker", "party")
)

K <- kwic(
  "GERMAPARLMINI",
  '"Sehr" "geehrte"', cqp = TRUE,
  boundary = "date"
)

P <- partition("GERMAPARLMINI", date = "2009-11-10")
K <- kwic(P, query = "Integration")
K <- kwic(P, query = '"Sehr" "geehrte"', cqp = TRUE, boundary = "date")
}
\references{
Baker, Paul (2006): \emph{Using Corpora in Discourse Analysis}. London: continuum, pp. 71-93 (ch. 4).

Jockers, Matthew L. (2014): \emph{Text Analysis with R for Students of Literature}.
Cham et al: Springer, pp. 73-87 (chs. 8 & 9).
}
\seealso{
The return value is a \code{\link{kwic-class}} object; the
  documentation for the class explains the methods applicable to
  \code{\link{kwic-class}} objects. To read the whole text, see the
  \code{\link{read}}-method.
}
