#' Load the x-spreadsheet javascript spreadsheet editor into Shiny
#'
#' This function creates an HTML widget to allow R Shiny to work with the
#' x-spreadsheet library (https://github.com/myliang/x-spreadsheet).
#'
#' The widget heavily relies on the conversion between lists and json.
#'
#' To maintain the state of the spreadsheet editor one can store input$<example>_RXSpreadsheetData and load it again, see runExample().
#'
#'
#' @import htmlwidgets
#'
#' @export
RXSpreadsheet <- function(data, options = NULL, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  message = list(
    data = data,
    options = options
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'RXSpreadsheet',
    message,
    width = width,
    height = height,
    package = 'RXSpreadsheet',
    elementId = elementId
  )
}

#' Shiny bindings for RXSpreadsheet
#'
#' Output and render functions for using RXSpreadsheet within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a RXSpreadsheet
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name RXSpreadsheet-shiny
#'
#' @export
RXSpreadsheetOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'RXSpreadsheet', width, height, package = 'RXSpreadsheet')
}

#' @rdname RXSpreadsheet-shiny
#' @export
renderRXSpreadsheet <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, RXSpreadsheetOutput, env, quoted = TRUE)
}
