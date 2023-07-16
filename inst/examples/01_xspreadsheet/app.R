library(xSpreadsheet)
library(shiny)

ui <- shiny::fluidPage(
    shiny::tags$div(
        class = "container-fluid",
        shiny::tags$div(
            class = "row",
            shiny::column(
                width = 4,
                shiny::tags$h3("R Shiny -> x-spreadsheet"),
                # remove a sheet
                shiny::column(
                    12,
                    shiny::tags$p(
                        class = "text-muted",
                        "After creating a proxy object with
                xSpreadsheet::spreadsheetProxy you can
                use the proxy with the functions below
                to interact with an existing x-spreadsheet.
                "
                    ),
                ),
                shiny::column(
                    12,
                    shiny::tags$h5("Interacting with sheets")
                ),
                shiny::column(
                    12,
                    shiny::tags$div(class = "text-muted",
                    "xSpreadsheet::deleteSheet"),
                    shiny::actionButton(("delete"),
                    label = "Delete active sheet")
                ),
                # add a sheet
                shiny::tags$div(
                    class = "col",
                    shiny::tags$div(
                        class = "text-muted mt-1",
                        "xSpreadsheet::addSheet"
                    ),
                    shiny::actionButton(("add"),
                        label = "Add a sheet"
                    )
                ),
                # load new data
                shiny::column(12,
                    class = "mt-3",
                    shiny::tags$h5("Load new data into the spreadsheet")
                ),
                shiny::tags$div(
                    class = "col",
                    shiny::tags$div(
                        class = "text-muted",
                        "xSpreadsheet::loadData (loads 2 sheets)"
                    ),
                    shiny::actionButton(
                        ("loadData"),
                        "(Re)load spreadsheet data"
                    ),
                ),
                # get the data object
                shiny::column(12,
                    class = "mt-3",
                    shiny::tags$h5("Saving and reloading the spreadsheet state")
                ),
                shiny::tags$div(
                    class = "col",
                    shiny::tags$div(
                        class = "text-muted",
                        "call xSpreadsheet::getData() and observe
                input$[[<name_of_spreadsheet-output>_data]]"
                    ),
                    shiny::actionButton(
                        ("getData"),
                        "Get the spreadsheet state (getData())"
                    ),
                    shiny::tags$p(class = "text-muted", "Technically,
                R Shiny -> x-spreadsheet -> R Shiny")
                ),
                shiny::tags$div(
                    class = "col",
                    shiny::verbatimTextOutput(
                        outputId = ("example_server_side")
                    )
                ),
                shiny::tags$div(
                    class = "col",
                    shiny::actionButton(
                        ("saveData"),
                        "Save the spreadsheet state"
                    )
                ),
                # Load previously saved data
                shiny::tags$div(
                    class = "col",
                    shiny::actionButton(
                        ("loadSavedData"),
                        "Load previously saved state",
                        class = "mt-1"
                    )
                ),
                # Set cell text
                shiny::column(12,
                    class = "mt-3",
                    shiny::tags$h5("Changing cell text"),
                    shiny::tags$p(
                        class = "text-muted",
                        "Use xSpreadsheet::cellText()"
                    ),
                    shiny::textInput(
                        inputId = ("cellText"),
                        label = "Cell text",
                        value = "ABCD"
                    ),
                    shiny::numericInput(
                        inputId = ("cellRow"),
                        label = "Row",
                        value = 1
                    ),
                    shiny::numericInput(
                        inputId = ("cellCol"),
                        label = "Column",
                        value = 1
                    ),
                    shiny::numericInput(
                        inputId = ("sheetIndex"),
                        label = "Sheet index",
                        value = 1
                    ),
                    shiny::actionButton(
                        ("setCellText"),
                        "Update cell text"
                    )
                ),
                shiny::column(
                    12,
                    shiny::tags$hr(class = "w-100")
                ),
                shiny::column(
                    12,
                    shiny::tags$h3("x-spreadsheet -> R Shiny"),
                    shiny::tags$p(
                        class = "text-muted",
                        "The following inputs are available
                when interacting
                with the spreadsheet."
                    ),
                    shiny::tags$h5("input$[[<output_name>_change]]"),
                    shiny::verbatimTextOutput(
                        outputId = ("example_change")
                    ),
                    shiny::tags$h5("input$[[<output_name>_cell_edited]]"),
                    shiny::verbatimTextOutput(
                        outputId = ("example_cell_edited")
                    ),
                    shiny::tags$h5(
                        "input$[[<output_name>_cell_selected]]"
                    ),
                    shiny::verbatimTextOutput(
                        outputId = ("example_cell_selected")
                    ),
                    shiny::tags$h5("input$[[<output_name>_cells_selected]]"),
                    shiny::verbatimTextOutput(
                        outputId = ("example_cells_selected")
                    )
                )
            ),
            shiny::column(
                width = 8,
                xSpreadsheet::spreadsheetOutput(
                    outputId = ("example"),
                    height = "90vh",
                    width = "100%"
                )
            )
        )
    )
)

server <- function(input, output) {
    output$example <- xSpreadsheet::renderSpreadsheet({
        input$triggerrenderSpreadsheet

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
            # (default) options from readme.md
            options = list(
                mode = "edit", # "edit" or "read"
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
                ),
                style = list(
                    bgcolor = "#FFFFFF",
                    align = "left",
                    valign = "middle",
                    textwrap = FALSE,
                    strike = FALSE,
                    underline = FALSE,
                    color = "#0a0a0a",
                    font = list(
                        name = "Helvetica",
                        size = 10,
                        bold = FALSE,
                        italic = FALSE
                    )
                )
            )
        )
    })

    # create proxy object
    proxy <- xSpreadsheet::spreadsheetProxy("example")

    # add a sheet
    shiny::observeEvent(input$add,
        {
            xSpreadsheet::addSheet(proxy,
                name = "new_sheet", active = TRUE
            )
        },
        ignoreInit = TRUE
    )

    # delete a sheet
    shiny::observeEvent(input$delete, {
        xSpreadsheet::deleteSheet(proxy)
    })

    # load random data
    shiny::observeEvent(input$loadData, {
        xSpreadsheet::loadData(
            proxy,
            data = list(
                "random_1" =
                    data.frame(matrix(rnorm(2500),
                        nrow = 50, ncol = 50
                    )),
                "random_2" =
                    data.frame(matrix(rnorm(2500),
                        nrow = 50, ncol = 50
                    ))
            )
        )
    })

    # get data and save it
    shiny::observeEvent(input$getData, {
        # get data from the client
        xSpreadsheet::getData(proxy)
        # this will trigger the data sending to
        # input$example_data (hence the observe below)
    })


    tmp <- tempfile(
        fileext = ".json"
    )

    shiny::observeEvent(input$saveData, {
        if (!shiny::isTruthy(input$example_data)) {
            shiny::showNotification(
                ui = "Please first get the data from the spreadsheet by
                    clicking on the button above",
                type = "warning"
            )
            return()
        }

        xSpreadsheet::storeState(
            input$example_data,
            path = tmp
        )
        shiny::showNotification(
            ui = "Saved the spreadsheet state to a temp file",
            type = "message"
        )
    })

    output$example_server_side <- shiny::renderText({
        shiny::req(input$example_data)
        return(summary(
            xSpreadsheet::spreadsheetListToDf(
                jsonlite::fromJSON(
                    input$example_data,
                    simplifyVector = FALSE
                )
            )
        ))
    })

    # reload the app from a previously saved file
    shiny::observeEvent(input$loadSavedData,
        {
            if (!file.exists(tmp)) {
                shiny::showNotification(
                    ui = "Please first save the data to a temp file by
                        clicking on the button above",
                    type = "warning"
                )
                return()
            }
            # load the data from the file
            data <- jsonlite::read_json(
                path = tmp
            )
            # load the data into the spreadsheet
            xSpreadsheet::loadData(proxy, data, process = FALSE)

            shiny::showNotification(
                ui = "Loaded the spreadsheet state from the temp file",
                type = "message"
            )
        },
        ignoreInit = TRUE
    )

    shiny::observeEvent(input$setCellText, {
        sheetIndex <- input$sheetIndex
        cellCol <- input$cellCol
        cellRow <- input$cellRow
        cellText <- input$cellText
        shiny::req(
            shiny::isTruthy(sheetIndex),
            shiny::isTruthy(cellCol),
            shiny::isTruthy(cellRow),
            shiny::isTruthy(cellText)
        )
        xSpreadsheet::cellText(
            proxy = proxy,
            row = cellRow,
            col = cellCol,
            text = cellText,
            sheetIndex = sheetIndex
        )
    })


    output$example_change <- shiny::renderPrint({
        list(
            "input$example_change" = input$example_change
        )
    })

    output$example_cell_selected <- shiny::renderPrint({
        list(
            "input$example_cell_selected" = input$example_cell_selected
        )
    })

    output$example_cells_selected <- shiny::renderPrint({
        list(
            "input$example_cells_selected" = input$example_cells_selected
        )
    })

    output$example_cell_edited <- shiny::renderPrint({
        list(
            "input$example_cell_edited" = input$example_cell_edited
        )
    })
}

# Create Shiny app ----
shiny::shinyApp(ui = ui, server = server)
