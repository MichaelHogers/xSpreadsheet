#' dataFrameListToList
#' @name dataFrameListToList
#' @rdname dataFrameListToList
#' @param inputData A list of dataframes where each list entry has a name. This list is converted into the right format for x-spreadsheet. Each list name is converted into a sheetname together with its relevant data.
#' @export
dataFrameListToList <- function(inputData){

  targetFormatList <- ''
  if (inherits(testDF, 'list') == FALSE){
    stop('required that inputData is of type list where list elements are of type data.frame')
  }

  # format expected:
  # list with datatables, where each name of the top level list is the sheet name
  for (listIter in 1:length(inputData)){

    # need nested lists in the following format to comply with structured required for front-end x-spreadsheet library
    if (targetFormatList == ''){
      targetFormatList <- list(list(''))
    } else {
      targetFormatList <- append(targetFormatList,
                                 list(list('')))
    }

    tableData <- inputData[[listIter]]

    targetListWithDataSubset <- list('name' = names(inputData)[listIter],
                               'freeze' = "A1",
                               'styles' = list(),
                               'merges' = list(),
                               'rows' = list(),
                               'cols' = list(),
                               'validations' = list(),
                               'autofilter' = list())

    # turn data frame into format required for x-spreadsheet
    # keep in mind JS indexing starts at 0
    nRowTable <- nrow(tableData)
    nColTable <- ncol(tableData)
    for (row in 1:nRowTable){
      for (col in 1:nColTable){
        # character conversion, otherwise 0 gets converted to an empty cell
        val <- as.character(tableData[row, col])
        targetListWithDataSubset$rows[[as.character(row - 1)]]$cells[[as.character(col - 1)]]$text <- val
      }
    }

    targetListWithDataSubset$rows$len <- max(nRowTable, 100)
    targetListWithDataSubset$cols$len <- max(nColTable, 26)

    targetFormatList[[1]][[listIter]] <- targetListWithDataSubset

  }

  return(targetFormatList)

}

