library(xSpreadsheet)
library(shiny)

ui <- shiny::fluidPage(
    shiny::fluidRow(
        shiny::column(12,
            tags$h3("This is a read-only x-spreadsheet, you can
                set options$mode = 'read' in xSpreadsheet().
            "),
            xSpreadsheet::spreadsheetOutput(
                            outputId = ("example"),
                            height = "50vh"
            ),
            shiny::verbatimTextOutput(
                outputId = "exampleBindings"
            )
        ),
        shiny::column(12,
            tags$h3("You can also turn off the toolbar
                and context menu with options$showToolbar = FALSE
                and options$showContextmenu = FALSE."),
            xSpreadsheet::spreadsheetOutput(
                            outputId = ("example2"),
                            height = "50vh"
            ),
            shiny::verbatimTextOutput(
                outputId = "exampleBindings2"
            )
        ),
        # padding bottom of page
        tags$div(
            style = "height: 100px"
        )
    )
)

server <- function(input, output, session) {

    # First spreadsheet
    output$example <- xSpreadsheet::renderSpreadsheet({
        xSpreadsheet::xSpreadsheet(
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
                ),
                # (default) options from readme.md
                options = list(
                    mode = "read",
                    showToolbar = TRUE,
                    showGrid = TRUE,
                    showContextmenu = TRUE,
                    row = list(
                        height = 25,
                        len = 1000
                    ),
                    col = list(
                        len = 26,
                        width = 100,
                        indexWidth = 60,
                        minWidth = 60
                    )
                )
            )
    })

    output$exampleBindings <- shiny::renderPrint({
        list(
            "input$example_cell_selected" = input$example_cell_selected,
            "input$example_cells_selected" = input$example_cells_selected
        )
    })

    # Second spreadsheet
    output$example2 <- xSpreadsheet::renderSpreadsheet({
        xSpreadsheet::xSpreadsheet(
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
                ),
                # (default) options from readme.md
                options = list(
                    mode = "read",
                    showToolbar = FALSE,
                    showGrid = TRUE,
                    showContextmenu = FALSE,
                    row = list(
                        height = 25,
                        len = 1000
                    ),
                    col = list(
                        len = 26,
                        width = 100,
                        indexWidth = 60,
                        minWidth = 60
                    )
                )
            )
    })

    output$exampleBindings2 <- shiny::renderPrint({
        list(
            "input$example2_cell_selected" = input$example2_cell_selected,
            "input$example2_cells_selected" = input$example2_cells_selected
        )
    })
}

shiny::shinyApp(ui, server)
