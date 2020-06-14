#' listToDataFrame
#' @name listToDataFrame
#' @rdname listToDataFrame
#' @param listData A list object saved via the input binding (input$<yourname>_RXSpreadsheetData) can be converted into a list of dataframes with this function. Note that only the table data is kept when doing this conversion, but no formatting or styling.
#' @export
listToDataFrame <- function(listData){

  sheets <- list()
  for (i in 1:length(listData[[1]])){

    currentSheetSelected <- listData[[1]][[i]]

    numberOfRows <- currentSheetSelected$rows$len
    numberOfCols <- currentSheetSelected$cols$len

    sheetData <- data.frame(matrix(NA, ncol = numberOfCols, nrow = numberOfRows))

    # suppress NA coercion warning
    suppressWarnings(
      rowsWithData <- as.numeric(names(currentSheetSelected$rows))
    )
    rowsWithData <- rowsWithData[!is.na(rowsWithData)]

    for (rowIndex in rowsWithData){
      # keep in mind, JS starts indexing at 0

      cellIndices <- names(currentSheetSelected$rows[[as.character(rowIndex)]]$cells)

      # get cell per row
      for (cellElement in cellIndices){
          selectedData <- currentSheetSelected$rows[[as.character(rowIndex)]]$cells[[as.character(cellElement)]]$text

          R_RowIndex <- as.numeric(rowIndex) + 1
          R_ColIndex <- as.numeric(cellElement) + 1

          if (!is.null(selectedData)){
            sheetData[R_RowIndex, R_ColIndex] <- as.character(selectedData)
          }
      }

    }

    sheets[[i]] <- sheetData
    names(sheets)[[i]] <- currentSheetSelected$name

  }

  return(sheets)

}
