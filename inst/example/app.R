library(RXSpreadsheet)
library(shiny)
library(htmltools)

# example UI
ui <- fluidPage(

      # RXSpreadsheet Output
      RXSpreadsheetOutput(outputId = 'example'),

      if ("xlsx" %in% rownames(installed.packages())){
      downloadButton('getXLSXData',
                   style = 'position: fixed; top: 0; right: 0; background: #006600; color: #fff;')
      }

)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$example <- RXSpreadsheet::renderRXSpreadsheet({
      # RXSpreadsheet requires a special type of list - to ensure it fits the
      # json structure expected by the front-end library

      if (file.exists('example.Rdata')){
        load('example.Rdata')
      } else {
        savedData <- DataFrameToList(list('sheet1_example' = data.frame(matrix(rnorm(25), nrow=5, ncol = 5)),
                                             'sheet2_example' =  data.frame(matrix(rnorm(25), nrow=5, ncol = 5))))
      }

      RXSpreadsheet(savedData)

    })

    # save change on every modification
    observe({
      req(!is.null(input$example_RXSpreadsheetData))
      savedData <- input$example_RXSpreadsheetData
      save(savedData, file = 'example.Rdata')
    })

    if ("xlsx" %in% rownames(installed.packages())){
      output$getXLSXData <- downloadHandler(
        filename = function(){
          'example.xlsx'
        },
        content = function(file){
          exampleConversion <- RXSpreadsheet::listToDataFrame(input$example_RXSpreadsheetData)
          numberOfSheets <- length(exampleConversion)
          exampleName <- 'example.xlsx'

          if (file.exists(exampleName)){
            file.remove(exampleName)
          }

          for (i in 1:numberOfSheets){

            if (i > 1){
              appendSheet <- TRUE
            } else {
              appendSheet <- FALSE
            }

            xlsx::write.xlsx(exampleConversion[i],
                       file = exampleName,
                       sheetName = names(exampleConversion)[i],
                       row.names = FALSE,
                       col.names = FALSE,
                       append = appendSheet,
                       showNA = FALSE)
          }

          file.copy(from = exampleName,
                    to = file)

        }
      )
    }

}

# Run the application
shinyApp(ui = ui, server = server)
