library(xSpreadsheet)
library(shiny)

ui <- shiny::fluidPage(
    shiny::fluidRow(
        shiny::column(
            12,
            xSpreadsheet::spreadsheetOutput(
                outputId = ("example"),
                height = "100vh",
                width = "100vw"
            )
        ),
        # for testing reactivity via playwright
        shiny::column(
            12,

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
        ),

        # proxy interaction
        shiny::column(
            12,
            shiny::actionButton("addSheet",
                label = "Add a sheet"
            ),
            shiny::actionButton("setCellText",
                label = "Set cell text"
            ),
            shiny::actionButton("deleteSheet",
                label = "Delete a sheet"
            ),
            shiny::actionButton("deleteSheetIndex",
                label = "Delete a sheet using sheetIndex"
            ),
            shiny::actionButton("loadDataDf",
                label = "Load data (single data.frame)"
            ),
            shiny::actionButton("loadDataList",
                label = "Load data (list of data.frames)"
            ),
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
            ),
            options = list(
                row = list(
                    len = 500
                ),
                col = list(
                    len = 500
                )
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

    #### proxy interaction

    # create proxy object
    proxy <- xSpreadsheet::spreadsheetProxy("example")

    ## add a sheet
    shiny::observeEvent(input$addSheet,
        {
            # we test in e2e.spec.js that "new_sheet" is added
            xSpreadsheet::addSheet(proxy,
                name = "new_sheet", active = FALSE
            )
        },
        ignoreInit = TRUE
    )

    ## set a cellText
    shiny::observeEvent(input$setCellText,
        {
            # we test in e2e.spec.js that "cellText" triggers a change
            xSpreadsheet::cellText(proxy,
                row = 5,
                col = 5,
                text = "Testing",
                sheetIndex = 1
            )
        },
        ignoreInit = TRUE
    )

    ## delete a sheet
    shiny::observeEvent(input$deleteSheet,
        {
            # we test in e2e.spec.js that "new_sheet" is deleted
            xSpreadsheet::deleteSheet(proxy)
        },
        ignoreInit = TRUE
    )

    ## delete a sheet using sheetIndex
    shiny::observeEvent(input$deleteSheetIndex,
        {
            # we test in e2e.spec.js that "new_sheet" is deleted
            xSpreadsheet::deleteSheet(proxy, sheetIndex = 1)
        },
        ignoreInit = TRUE
    )

    ## load data, simple df
    shiny::observeEvent(input$loadDataDf,
        {
            xSpreadsheet::loadData(proxy,
                data.frame(
                    "Id" = c(1, 2, 3, 4, 5),
                    "Label" = c("A", "B", "C", "D", "E"),
                    "Timestamp" = rep(Sys.time(), 5)
                )
            )
        },
        ignoreInit = TRUE
    )

    ## load data, list of df
    shiny::observeEvent(input$loadDataList,
        {
            xSpreadsheet::loadData(proxy,
                list(
                    "Sheet 1" = data.frame(
                        "Id" = c(1, 2, 3, 4, 5),
                        "Label" = c("A", "B", "C", "D", "E"),
                        "Timestamp" = rep(Sys.time(), 5)
                    ),
                    "Sheet 2" =
                        data.frame(matrix(rnorm(2500),
                            nrow = 200, ncol = 100
                        )),
                    "Sheet 3" =
                        data.frame(matrix(rnorm(2500),
                            nrow = 50, ncol = 50
                        ))
                )
            )
        },
        ignoreInit = TRUE
    )

    #### end proxy interaction
}

shiny::shinyApp(ui, server)
