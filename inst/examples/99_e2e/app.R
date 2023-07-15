library(xSpreadsheet)
library(shiny)

ui <- shiny::fluidPage(
    shiny::fluidRow(
        shiny::column(12,
            xSpreadsheet::spreadsheetOutput(
                            outputId = ("example"),
                            height = "100vh",
                            width = "100vw"
            )
        ),
        # for testing reactivity via playwright
        shiny::column(12,

            # cell selected
            shiny::uiOutput(
                outputId = "cell_selected"
            ),

            # cell edited
            shiny::uiOutput(
                outputId = "cell_edited"
            ),
            shiny::uiOutput(
                outputId = "cell_edited_value"
            ),

            # change ts
            shiny::uiOutput(
                outputId = "change_ts"
            )
        )
    )
)

server <- function(input, output, session) {
    output$example <- xSpreadsheet::renderSpreadsheet({
        xSpreadsheet::spreadsheet(
                data = list(
                    "Sheet 1" = data.frame(
                        "Id" = c(1, 2, 3, 4, 5),
                        "Label" = c("A", "B", "C", "D", "E"),
                        "Timestamp" = rep(Sys.time(), 5)
                    ),
                    "Sheet 2" =
                        data.frame(matrix(rnorm(2500),
                            nrow = 50, ncol = 50
                        )),
                    "Sheet 3" =
                        data.frame(matrix(rnorm(2500),
                            nrow = 50, ncol = 50
                        ))
                )
            )
    })

    # cell selected
    output$cell_selected <- shiny::renderUI({
        input$example_cell_selected
    })

    # cell edited
    output$cell_edited <- shiny::renderUI({
        input$example_cell_edited
    })

    output$cell_edited_value <- shiny::renderUI({
        input$example_cell_edited$value
    })

    # change ts
    output$change_ts <- shiny::renderUI({
        input$example_change
    })



}

shiny::shinyApp(ui, server)
