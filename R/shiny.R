#' @title Add a new sheet
#' @description Adds a new sheet to the spreadsheet,
#' requires a x-spreadsheet proxy to exist.
#' @param proxy The x-spreadsheet proxy object
#' @param name The name of the new sheet
#' @param active Whether the new sheet should be active,
#' defaults to TRUE
#' @export
addSheet <- function(proxy, name, active = TRUE) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "addSheet",
        args = list(name = name, active = active)
    )
}

#' @title Rerenders the spreadsheet
#' @param proxy The x-spreadsheet proxy object
#' @export
reRender <- function(proxy) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "reRender"
    )
}

#' @title Delete the current active sheet
#' @description Seems broken in x-spreadsheet,
#' not exporting until fixed.
#' @param proxy The x-spreadsheet proxy object
deleteSheet <- function(proxy) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "deleteSheet"
    )
}

#' @title Reload all data
#' @param proxy The x-spreadsheet proxy object
#' @param data The new data, must be a data.frame or a
#' named list with data.frame entries
#' @param processing Whether to process the data,
#' defaults to TRUE. If the data is being loaded based on
#' previously stored JSON data, set this to FALSE.
#' If a data.frame or a list of data.frames is provided,
#' set this to TRUE.
#' @export
loadData <- function(proxy, data, processing = TRUE) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "loadData",
        args = list(data = if (processing) {
            processInputData(data)
        } else {
            data
        })
    )
}

#' @title Get the data object
#' @description Retrieves the data object by
#' sending a call to the client, which then
#' sends the data to
#' input[[paste0(proxy, "_data")]]
#'
#' By retrieving the data object from the client,
#' you can get the current data in the spreadsheet, including
#' all formatting and other custom settings.
#'
#' TO DO: add logic to:
#' load the spreadsheet via the getData data object
#' add logic to parse the data object into a list containing data.frames
#' @param proxy The x-spreadsheet proxy object
#' @export
getData <- function(proxy) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "getData"
    )
}

#' @title Set the value in a cell
#' @description Sets the text of a cell, requires
#' a x-spreadsheet proxy to interact with and valid arguments.
#' Indices are expected to be 1-based (R).
#' @param proxy The x-spreadsheet proxy object
#' @param row The row index of the cell
#' @param col The column index of the cell
#' @export
cellText <- function(proxy, row, col, text, sheetIndex) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "cellText",
        args = list(
            row = row - 1,
            col = col - 1,
            text = text,
            sheetIndex = sheetIndex - 1
        )
    )
}

#' @title Store the data object
#' @description Stores the data object by
#' parsing the data (a stringified JSON)
#' and storing it as a JSON object
#' @param data The data object to store,
#' must be a stringified JSON generated via
#' getData and received as input$[["<proxy>_data"]]
#' @param path The path to store the data object at
#' @return TRUE if successfull
#' @export
storeState <- function(data, path) {
    jsonlite::write_json(
        jsonlite::fromJSON(data),
        path = path
    )

    TRUE
}


#' @title Allow to send calls to the client from a R Shiny session
#' @param proxy the x-spreadsheet proxy object
#' @param method the method to call,
#' should be a valid API public method from
#' https://hondrytravis.com/x-spreadsheet-doc/
#' for which the R -> client communication is sensible
#' (some API methods are not included as
#' these would send data from the client to R)
invokeRemote <- function(proxy, method = c(
    "addSheet", "reRender", "deleteSheet", "loadData", "getData",
    "cellText"
), args = list()) {
  if (!inherits(proxy, "rxspreadsheetProxy"))
    stop("Invalid proxy argument; x-spreadsheet proxy object was expected")

  method <- match.arg(method)

  msg <- list(id = proxy$id, call = list(method = method, args = args))

  sess <- proxy$session
  if (proxy$deferUntilFlush) {
    sess$onFlushed(function() {
      sess$sendCustomMessage("xspreadsheet-calls", msg)
    }, once = TRUE)
  } else {
    sess$sendCustomMessage("xspreadsheet-calls", msg)
  }

  proxy

}

#' @title Create a x-spreadsheet proxy object
#' @param outputId the output variable to read the x-spreadsheet
#' @param session the shiny session
#' @param deferUntilFlush whether to defer the creation of the proxy
#' until the next flush cycle
#' @export
xSpreadsheetProxy <- function(
    outputId, session = shiny::getDefaultReactiveDomain(),
    deferUntilFlush = TRUE
) {
    if (is.null(session)) {
        stop("xSpreadsheetProxy() must be
            called from within a Shiny app.")
    }

    structure(list(
        id = session$ns(outputId),
        rawId = outputId,
        session = session,
        deferUntilFlush = deferUntilFlush
    ), class = "rxspreadsheetProxy")
}