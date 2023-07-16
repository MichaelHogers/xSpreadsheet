#' @title x-spreadsheet htmlwidget
#'
#' @description Initialises the x-spreadsheet htmlwidget, allows to
#' create one or more sheets and pass options.
#'
#' @param data The data to render inside the spreadsheet, the following
#' options are valid:
#' - NULL, this will result in an empty spreadsheet with a single sheet
#' named "Sheet1"
#' - A single data.frame object, this will result in a single sheet
#' spreadsheet where the name of the first sheet is "Sheet1"
#' - A named list where each list entry contains a data.frame object,
#' a named sheet is generated in correspondence with the named list
#' @param options A list containing table options/settings, set at
#' table initialisation.
#' The list should match the JSON structure below, e.g.: list(
#' "mode" = "edit", showToolbar = TRUE, ...), JSON:
#' {
#'   mode: 'edit', // edit | read
#'   showToolbar: true,
#'   showGrid: true,
#'   showContextmenu: true,
#'   view: {
#'     height: () => document.documentElement.clientHeight,
#'     width: () => document.documentElement.clientWidth,
#'   },
#'   row: {
#'     len: 100,
#'     height: 25,
#'   },
#'   col: {
#'     len: 26,
#'     width: 100,
#'     indexWidth: 60,
#'     minWidth: 60,
#'   },
#'   style: {
#'     bgcolor: '#ffffff',
#'     align: 'left',
#'     valign: 'middle',
#'     textwrap: false,
#'     strike: false,
#'     underline: false,
#'     color: '#0a0a0a',
#'     font: {
#'       name: 'Helvetica',
#'       size: 10,
#'       bold: false,
#'       italic: false,
#'     },
#'   },
#' }
#' @param elementId htmlwidget elementid
#' @import shiny
#' @export
spreadsheet <- function(data, options = NULL, elementId = NULL) {
  data <- processInputData(data)

  message <- list(
    data = data,
    options = options
  )

  # create widget
  htmlwidgets::createWidget(
    name = "xspreadsheet",
    message,
    package = "xSpreadsheet",
    elementId = elementId
  )
}

#' Shiny bindings for xSpreadsheet
#'
#' Output and render functions for using xSpreadsheet within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a xSpreadsheet
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name xSpreadsheet-shiny
#'
#' @export
spreadsheetOutput <- function(outputId, width = "100%", height = "100%") {
  try({
    shiny::removeInputHandler("rspreadsheetlist")
  })
  shiny::registerInputHandler("rspreadsheetlist", function(data, ...) {
    list(data)
  }, force = TRUE)

  # The JavaScript is necessary because in a multi-page
  # layout a page that is not visible will have a width and height of 0
  # which causes the spreadsheet to resize to such dimensions
  # and then fail to render correctly
  # unless the user resizes.
  # The JavaScript below takes care of that edge case.
  script <- tags$script(shiny::HTML(paste0("
    // Get the target div element
    var divElement = document.getElementById('", outputId, "');

    // Create a new ResizeObserver instance
    var resizeObserver = new ResizeObserver(function(entries) {
      // Iterate over the entries
      for (var entry of entries) {
        // if the width and height are 0 and 0,
        // look for the parent element
        // and use its width and height
        if (entry.contentRect.width == 0 && entry.contentRect.height == 0) {
          // Create a new resize event
          var event = new Event('resize');
          // Dispatch the event on the window object
          window.dispatchEvent(event);
        }
      }
    });

    // Start observing the div element
    resizeObserver.observe(divElement);
  ")))


  shiny::tagList(
    htmlwidgets::shinyWidgetOutput(outputId, "xspreadsheet",
      width, height,
      package = "xSpreadsheet"
    ),
    script
  )
}

#' @rdname xSpreadsheet-shiny
#' @export
renderSpreadsheet <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, spreadsheetOutput,
    env,
    quoted = TRUE
  )
}

#' @title Process data for xSpreadsheet
#'
#' @description This function processes R data.frames into
#' the x-spreadsheet required list format. Note that the
#' list data is sent as JSON to the client.
#'
#' @param data The data to render inside the spreadsheet, the following
#' options are valid:
#' - NULL, this will result in an empty spreadsheet with a single sheet
#' named "Sheet1"
#' - A single data.frame object, this will result in a single sheet
#' spreadsheet where the name of the first sheet is "Sheet1"
#' - A named list where each list entry contains a data.frame object,
#' a named sheet is generated in correspondence with the named list
#' @inheritParams spreadsheet
#' @return A list containing the processed data
processInputData <- function(data) {
  # check if data is a data.frame,
  # or a named list with one or more data.frame entries
  if (is.null(data)) {
    return(list("Sheet1" = data.frame()))
  } else if (is.data.frame(data)) {
    # single data.frame
    data <- list("Sheet1" = data)
  } else if (is.list(data)) {
    # check if list contains data.frame entries
    if (!all(sapply(data, is.data.frame))) {
      # named list with other entries
      stop("Data must be a data.frame or a named list with data.frame entries")
    }
  } else {
    # other data types
    stop("Data must be a data.frame or a named list with data.frame entries")
  }

  # convert data to x-spreadsheet format
  data <- listToSpreadsheet(data)

  return(data)
}

listToSpreadsheet <- function(list) {
  sheets <- lapply(names(list), function(name) {
    df <- list[[name]]
    list(name = name, rows = dfToSpreadsheet(df))
  })
  return(sheets)
}

#' @title Convert a data.frame to x-spreadsheet format
#' @description Convert a data.frame to x-spreadsheet format,
#' while also adding data types in JSON format for later
#' conversion back to R.
#' @param df data.frame
#' @param headerRow logical, whether to include a header row
dfToSpreadsheet <- function(df, headerRow = TRUE) {
  # store in a list
  if (headerRow) {
    headerDf <- as.data.frame(t(names(df)))
    dfList <- list(headerDf, df)
  } else {
    dfList <- list(df)
  }

  rowsList <- lapply(dfList, function(l) {
    rowSeq <- seq_len(nrow(l))
    colSeq <- seq_len(ncol(l))

    rows <- vector("list", nrow(l))

    for (i in rowSeq) {
      cells <- vector("list", ncol(l))
      cells <- mapply(function(text, type, header) {
        list(
          text = text,
          type = type,
          header = header
        )
      }, l[i, colSeq], typeof(l[i, colSeq]),
         seq_along(colSeq) == 1, SIMPLIFY = FALSE)
      rows[[i]] <- list(cells = setNames(cells, seq_along(cells) - 1))
    }
    rows
  })

  # unlist top level
  rows <- unlist(rowsList, recursive = FALSE)

  setNames(rows, seq_along(rows))

  rows
}

#' @title Convert x-spreadsheet data to a list of data.frames
#' @description Convert x-spreadsheet data to a list of data.frames,
#' this function turns the data structure generated by the JS library
#' (and parsed with jsonlite::fromJSON(simpifyVector = FALSE)))
#' into a list of data.frames, one per sheet. It is the inverse of
#' listToSpreadsheet.
#' @param data The data to convert, a list with the following structure
#' - name
#' - rows, which contains "cells", which contains entries with "text"
#' other fields are ignored for now
#' (customise this function and json it carries the following metadata:
#' - field type for conversion
#' - column names Y/N
#' )
#' originating from a JSON object returned by x-spreadsheet,
#' containing one entry per sheet, with the following structure:
#' {
#'  name: "Sheet1",
#'  rows: {
#'  0: {
#'    cells: {
#'      {text: "A1"},
#'    }
#'  }
#' }
#' }
#' @param headerRow Whether the first row contains column names,
#' TO DO: automatically detect this by carrying extra metadata with
#' each sheet
#' @export
spreadsheetListToDf <- function(data, headerRow = TRUE) {

  dfs <- setNames(lapply(data, function(sheet) {
    sheetRows <- sheet$rows
    sheetName <- sheet$name

    cols <- NULL
    if ("header" %in% names(sheetRows[[1]]$cells[[1]])) {
        cols <- sapply(sheetRows[[1]]$cells, function(x) {
          cellTypeConversion(x)
        })
    }

    lapplyIter <- seq_along(sheetRows)
    if (!is.null(cols)) {
      lapplyIter <- lapplyIter[-1]
    }
    sheetDf <- lapply(lapplyIter, function(i) {
      if (!"cells" %in% names(sheetRows[[i]])) {
        return(NULL)
      } else {
        sapply(sheetRows[[i]]$cells, function(x) {
          cellTypeConversion(x)
        })
      }
    })

    # Convert to data.frame
    df <- do.call(rbind.data.frame, sheetDf)
    names(df) <- cols

    # return df directly
    df

  }), sapply(data, function(sheet) sheet$name)) # set names

  # return the list of data.frames
  dfs
}

#' @title Helper function to convert a cell to the correct type
# helper function, x$type is set via base::typeof
#' @param x A list with the following structure:
#' - text: the text to convert
#' - type: the type to convert to
#' originating from a JSON object returned by x-spreadsheet
cellTypeConversion <- function(x) {
      text <- ""
      if ("type" %in% names(x)) {
        # convert x to the correct type
        text <- switch(x$type,
               "character" = x$text,
               "double" = as.numeric(x$text),
               "integer" = as.integer(x$text),
               "logical" = as.logical(x$text),
               "complex" = as.complex(x$text),
               "raw" = as.raw(x$text),
               x$test)
      } else {
        text <- x$text
      }

      text
}
