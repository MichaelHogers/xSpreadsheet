library(RXSpreadsheet)
library(shiny)
library(htmltools)

# example UI
ui <- fluidPage(

      # RXSpreadsheet Output
      RXSpreadsheetOutput(outputId = 'example')

)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$example <- RXSpreadsheet::renderRXSpreadsheet({
      # RXSpreadsheet requires a special type of list - to ensure it fits the
      # json structure expected by the front-end library
      if (file.exists('example.Rdata')){
        load('example.Rdata')
      }
      if (is.null(savedData[[1]])) {
        savedData <- dataFrameListToList(list(
          'sheet1_example' = data.frame(matrix(rnorm(25), nrow=5, ncol = 5)),
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

}

# Run the application
shinyApp(ui = ui, server = server)
