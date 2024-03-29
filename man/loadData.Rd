% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shiny.R
\name{loadData}
\alias{loadData}
\title{Reload all data}
\usage{
loadData(proxy, data, processing = TRUE, triggerChange = TRUE)
}
\arguments{
\item{proxy}{The x-spreadsheet proxy object}

\item{data}{The new data, must be a data.frame or a
named list with data.frame entries}

\item{processing}{Whether to process the data,
defaults to TRUE. If the data is being loaded based on
previously stored JSON data, set this to FALSE.
If a data.frame or a list of data.frames is provided,
set this to TRUE.}

\item{triggerChange}{Whether to trigger a change event,
defaults to TRUE, will trigger an update to the _change
input value}
}
\description{
Reload all data
}
