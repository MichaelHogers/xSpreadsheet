#' Run xSpreadsheet Example Applications
#'
#' Launch xSpreadsheet example applications,
#' and optionally, your system's web browser.
#'
#' @param example The name of the example to run, or `NA` (the default) to
#'   list the available examples.
#' @examples
#' ## Only run this example in interactive R sessions
#' if (interactive()) {
#'   # List all available examples
#'   runExamples()
#'
#'   # Run one of the examples
#'   runExamples("01_spreadSheet")
#'
#'   # Print the directory containing the code for all examples
#'   system.file("examples", package="xSpreadsheet")
#' }
#' @export
runExamples <- function(example = NA, port = 3000) {
  examplesDir <- system.file("examples", package = "xSpreadsheet")
  dir <- resolve(examplesDir, example)
  if (is.null(dir)) {
    if (is.na(example)) {
      errFun <- message
      errMsg <- ""
    } else {
      errFun <- stop
      errMsg <- paste("Example", example, "does not exist. ")
    }

    errFun(errMsg,
           'Valid examples are "',
           paste(list.files(examplesDir), collapse = '", "'),
           '"')
  } else {
    runApp(dir, port = port)
  }
}

# Attempt to join a path and relative path, and turn the result into a
# (normalized) absolute path. The result will only be returned if it is an
# existing file/directory and is a descendant of dir.
resolve <- function(dir, relpath) {
  absPath <- file.path(dir, relpath)
  if (!file.exists(absPath))
    return(NULL)
  absPath <- normalizePath(absPath, winslash = "/", mustWork = TRUE)
  dir <- normalizePath(dir, winslash = "/", mustWork = TRUE)
  # trim the possible trailing slash under Windows (#306)
  if (isWindows()) dir <- sub("/$", "", dir)
  if (nchar(absPath) <= nchar(dir) + 1)
    return(NULL)
  if (substr(absPath, 1, nchar(dir)) != dir ||
      substr(absPath, nchar(dir) + 1, nchar(dir) + 1) != "/") {
    return(NULL)
  }
  return(absPath)
}


isWindows <- function() .Platform$OS.type == "windows"
