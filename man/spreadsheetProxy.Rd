% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shiny.R
\name{spreadsheetProxy}
\alias{spreadsheetProxy}
\title{Create a x-spreadsheet proxy object}
\usage{
spreadsheetProxy(
  outputId,
  session = shiny::getDefaultReactiveDomain(),
  deferUntilFlush = TRUE
)
}
\arguments{
\item{outputId}{the id of the table to be manipulated
(the same id as the one you used in
\code{\link{spreadsheetOutput}()})}

\item{session}{the shiny session}

\item{deferUntilFlush}{whether an action
should be carried out right away,
or should be held until after the next
time all of the outputs are updated}
}
\description{
Create a x-spreadsheet proxy object
}
