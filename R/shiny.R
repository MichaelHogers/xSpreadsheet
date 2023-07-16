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
#' @description This function is most likely not needed
#' as the rerendering logic is handled already by the
#' internal spreadsheet functions.
#' @param proxy The x-spreadsheet proxy object
#' @export
reRender <- function(proxy) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "reRender"
    )
}

#' @title Delete a sheet
#' @description Deletes a sheet from the spreadsheet,
#' defaults to deleting the active sheet. Only
#' deletes sheets if at least two sheets are present.
#' @param proxy The x-spreadsheet proxy object
#' @param sheetIndex The index of the sheet to delete,
#' uses R 1-based indexing. If left NULL, the active sheet
#' is deleted.
#' @export
deleteSheet <- function(proxy, sheetIndex = NULL) {
    if (!is.null(sheetIndex) && sheetIndex <= 0) {
        warning(
            "xSpreadsheet: sheetIndex is smaller than or equal to 0,
            setting it to 1 as 1-based indexing is expected."
        )
        sheetIndex <- 1
    }

    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "deleteSheet",
        args = list(
            sheetIndex = if (is.null(sheetIndex)) {
                NULL
            } else {
                sheetIndex - 1
            }
        )
    )
}

#' @title Reload all data
#' @param data The new data, must be a data.frame or a
#' named list with data.frame entries
#' @param processing Whether to process the data,
#' defaults to TRUE. If the data is being loaded based on
#' previously stored JSON data, set this to FALSE.
#' If a data.frame or a list of data.frames is provided,
#' set this to TRUE.
#' @inheritParams cellText
#' @export
loadData <- function(proxy, data, processing = TRUE,
    triggerChange = TRUE) {
    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "loadData",
        args = list(data = if (processing) {
                processInputData(data)
            } else {
                data
            },
            triggerChange = triggerChange
        )
    )
}

#' @title Get the data object
#' @description Retrieves the data object by
#' sending a call to the client, which then
#' sends the data to
#' an input with name paste0(proxy, "_data")
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
#' @param text The text to set the cell to
#' @param sheetIndex The index of the sheet to set the cell in,
#' uses R 1-based indexing.
#' @param triggerChange Whether to trigger a change event,
#' defaults to TRUE, will trigger an update to the _change
#' input value
#' @export
cellText <- function(proxy, row, col, text, sheetIndex,
    triggerChange = TRUE) {

    if (sheetIndex == 0) {
        warning(
            "xSpreadsheet: sheetIndex is 0,
            setting it to 1 as 1-based indexing is expected."
        )
        sheetIndex <- 1
    }

    invokeRemote(
        proxy = proxy,
        # API method x-spreadsheet
        method = "cellText",
        args = list(
            rowIndex = row - 1,
            colIndex = col - 1,
            text = text,
            sheetIndex = sheetIndex - 1,
            triggerChange = triggerChange
        )
    )
}

#' @title Store the data object
#' @description Stores the data object by
#' parsing the data (a stringified JSON)
#' and storing it as a JSON object
#' @param data The data object to store,
#' must be a stringified JSON generated via
#' getData and received as proxy id and "_data"
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
#' @param args additional arguments to pass to the method
invokeRemote <- function(proxy, method = c(
    "addSheet", "reRender", "deleteSheet", "loadData", "getData",
    "cellText"
), args = list()) {
  if (!inherits(proxy, "rspreadSheetProxy"))
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
#' @param outputId the id of the table to be manipulated
#' (the same id as the one you used in
#' \code{\link{spreadsheetOutput}()})
#' @param session the shiny session
#' @param deferUntilFlush whether an action
#' should be carried out right away,
#' or should be held until after the next
#' time all of the outputs are updated
#' @export
spreadsheetProxy <- function(
    outputId, session = shiny::getDefaultReactiveDomain(),
    deferUntilFlush = TRUE
) {
    if (is.null(session)) {
        stop("spreadsheetProxy() must be
            called from within a Shiny app.")
    }

    structure(list(
        id = session$ns(outputId),
        rawId = outputId,
        session = session,
        deferUntilFlush = deferUntilFlush
    ), class = "rspreadSheetProxy")
}
