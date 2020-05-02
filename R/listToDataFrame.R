#' @rdname listToDataFrame
#' @export
listToDataFrame <- function(listData){

  sheets <- list()
  for (i in 1:length(listData[[1]])){

    currentSheetSelected <- listData[[1]][[i]]

    numberOfRows <- currentSheetSelected$rows$len
    numberOfCols <- currentSheetSelected$cols$len

    sheetData <- data.frame(matrix(NA, ncol = numberOfCols, nrow = numberOfRows))

    rowsWithData <- as.numeric(names(currentSheetSelected$rows))
    rowsWithData <- rowsWithData[!is.na(rowsWithData)]

    for (rowIndex in rowsWithData){
      # keep in mind, JS starts indexing at 0

      cellIndices <- names(currentSheetSelected$rows[[as.character(rowIndex)]]$cells)

      # get cell per row
      for (cellElement in cellIndices){
          selectedData <- currentSheetSelected$rows[[as.character(rowIndex)]]$cells[[as.character(cellElement)]]$text

          R_RowIndex <- as.numeric(rowIndex) + 1
          R_ColIndex <- as.numeric(cellElement) + 1

          print(paste0(R_RowIndex, ", ", R_ColIndex))
          if (!is.null(selectedData)){
            sheetData[R_RowIndex, R_ColIndex] <- selectedData
          }
      }

    }

    sheets[[i]] <- sheetData
    names(sheets)[[i]] <- currentSheetSelected$name

  }

  return(sheets)

}
