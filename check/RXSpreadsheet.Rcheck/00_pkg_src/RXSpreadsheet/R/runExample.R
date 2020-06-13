#' Run examples of using RXSpreadsheet in a Shiny app
#'
#'
#' @export
runExample <- function() {
  appDir <- system.file("example", package = "RXSpreadsheet")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `RXSpreadsheet`.",
         call. = FALSE)
  }
  shiny::runApp(appDir, display.mode = "normal")
}
