#' @export
#' @import shiny
demoApp <- function(
  port = 4000,
  host = "0.0.0.0"
) {


  shiny::shinyApp(
    ui = bslib::page_navbar(
      bslib::nav_panel(
          "Default functionality",
          generalUI(id = "example")
      ),
      bslib::nav_panel(
          "Highchart example",
          chartUI(id = "chart")
      )
    ),
    server = function(input, output, session) {
      generalServer(id = "example")
      chartServer(id = "chart")
    },
    options = list(
      port = port,
      host = host)
  )
}


#### General uses example
#' @import shiny
generalUI <- function(id) {
    ns <- shiny::NS(id)

    shiny::tags$div(class = "container-fluid",
    shiny::tags$div(class = "row",
        shiny::column(
            width = 4,
            shiny::tags$h3("R Shiny -> x-spreadsheet"),
            # remove a sheet
            shiny::column(12,
              tags$p(
                class = "text-muted",
                "After creating a proxy object with
                RXSpreadsheet::xSpreadsheetProxy you can
                use the proxy with the functions below
                to interact with an existing x-spreadsheet.
                "),
            ),
            shiny::column(12,
              tags$h5("Interacting with sheets")
            ),
            # This is broken in x-spreadsheet it seems
            # shiny::column(
            #     12,
            #     tags$div(class = "text-muted",
            #     "RXSpreadsheet::deleteSheet"),
            #     shiny::actionButton(ns("delete"),
            #     label = "Delete active sheet")
            # ),
            # add a sheet
            tags$div(class = "col",
                tags$div(class = "text-muted mt-1",
                "RXSpreadsheet::addSheet"),
                shiny::actionButton(ns("add"),
                label = "Add a sheet")
            ),
            # load new data
            shiny::column(12,
              class = "mt-3",
              tags$h5("Load new data into the spreadsheet")
            ),
            tags$div(class = "col",
                tags$div(class = "text-muted",
                "RXSpreadsheet::loadData (loads 2 sheets)"),
                shiny::actionButton(
                    ns("loadData"),
                    "(Re)load spreadsheet data"
                ),
            ),
            # get the data object
            shiny::column(12,
              class = "mt-3",
              tags$h5("Saving and reloading the spreadsheet state")
            ),
            tags$div(class = "col",
                tags$div(class = "text-muted",
                "call RXSpreadsheet::getData() and observe
                input$[[<name_of_spreadsheet-output>_data]]"),
                shiny::actionButton(
                    ns("getData"),
                    "Get the spreadsheet state (getData())"
                ),
                tags$p(class = "text-muted", "Technically,
                R Shiny -> x-spreadsheet -> R Shiny")
            ),
            tags$div(class = "col",
              shiny::verbatimTextOutput(outputId = ns("example_server_side"))
            ),
            tags$div(class = "col",
              shiny::actionButton(
                ns("saveData"),
                "Save the spreadsheet state"
              )
            ),
            # Load previously saved data
            tags$div(class = "col",
                shiny::actionButton(
                    ns("loadSavedData"),
                    "Load previously saved state",
                    class = "mt-1"
                )
            ),
            # Set cell text
            shiny::column(12,
              class = "mt-3",
              tags$h5("Changing cell text"),
              tags$p(
                class = "text-muted",
                "Use RXSpreadsheet::cellText()"
              ),
              shiny::textInput(inputId = ns("cellText"),
                label = "Cell text",
                value = "ABCD"
              ),
              shiny::numericInput(
                inputId = ns("cellRow"),
                label = "Row",
                value = 1
              ),
              shiny::numericInput(
                inputId = ns("cellCol"),
                label = "Column",
                value = 1
              ),
              shiny::numericInput(
                inputId = ns("sheetIndex"),
                label = "Sheet index",
                value = 1
              ),
              shiny::actionButton(
                ns("setCellText"),
                "Update cell text"
              )
            ),

            shiny::column(12,
              tags$hr(class = "w-100")
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
                outputId = ns("example_change")
              ),
              shiny::tags$h5("input$[[<output_name>_cell_edited]]"),
              shiny::verbatimTextOutput(
                outputId = ns("example_cell_edited")
              ),
              shiny::tags$h5(
                "input$[[<output_name>_cell_selected]]"
              ),
              shiny::verbatimTextOutput(
                outputId = ns("example_cell_selected")
              ),
              shiny::tags$h5("input$[[<output_name>_cells_selected]]"),
              shiny::verbatimTextOutput(
                outputId = ns("example_cells_selected")
              )
            )
        ),
        shiny::column(
            width = 8,
            RXSpreadsheet::RXSpreadsheetOutput(
                outputId = ns("example"),
                height = "90vh",
                width = "100%"
            )
        )
    )
    )
}

generalServer <- function(id) {
    shiny::moduleServer(
        id,
        function(input, output, session) {

            output$example <- RXSpreadsheet::renderRXSpreadsheet({
                input$triggerRenderRXSpreadsheet

                RXSpreadsheet::xSpreadsheet(
                    data = list(
                        "Sheet 1" = data.frame(
                            "Id" = c(1, 2, 3, 4, 5),
                            "Label" = c("A", "B", "C", "D", "E"),
                            "Timestamp" = rep(Sys.time(), 5)
                        ),
                        "Sheet 2" =
                            data.frame(matrix(rnorm(2500),
                            nrow = 50, ncol = 50)),
                        "Sheet 3" =
                            data.frame(matrix(rnorm(2500),
                            nrow = 50, ncol = 50))
                    ),
                    # (default) options from readme.md
                    options = list(
                        mode = "edit", # "edit" or "read"
                        showToolbar = TRUE,
                        showGrid = TRUE,
                        showContextmenu = TRUE,
                        view = list(
                            height = DT::JS(
                              "() => $('#example-example').height()"
                            ),
                            width = DT::JS(
                              "() => $('#example-example').width()"
                            )
                        ),
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
            proxy <- RXSpreadsheet::xSpreadsheetProxy("example")

            # add a sheet
            shiny::observeEvent(input$add,
                {
                    RXSpreadsheet::addSheet(proxy,
                    name = "new_sheet", active = TRUE)
                },
                ignoreInit = TRUE
            )

            # delete a sheet
            shiny::observeEvent(input$delete, {
                RXSpreadsheet::deleteSheet(proxy)
            })

            # load random data
            shiny::observeEvent(input$loadData, {
                RXSpreadsheet::loadData(
                    proxy,
                    data = list(
                        "random_1" =
                            data.frame(matrix(rnorm(2500),
                            nrow = 50, ncol = 50)),
                        "random_2" =
                            data.frame(matrix(rnorm(2500),
                            nrow = 50, ncol = 50))
                    )
                )
            })

            # get data and save it
            shiny::observeEvent(input$getData, {
                # get data from the client
                RXSpreadsheet::getData(proxy)
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

                RXSpreadsheet::storeState(
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
                  RXSpreadsheet::xSpreadsheetListToDf(
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
                    RXSpreadsheet::loadData(proxy, data, process = FALSE)

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
                RXSpreadsheet::cellText(
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
    )
}
#### End of general uses example

#### Chart interaction example
# demonstration module that show cases the use of RXSpreadsheet
# together with a charting library
# ui module function
chartUI <- function(id) {
    ns <- shiny::NS(id)

    shiny::fluidRow(
        shiny::column(
            6,
            RXSpreadsheet::RXSpreadsheetOutput(
                outputId = ns("spreadsheet"),
                height = "800px"
            )
        ),
        shiny::column(
            6,
            highcharter::highchartOutput(
                outputId = ns("chart"),
                # otherwise chart does not fit
                height = "800px"
            )
        )
    )
}

# server module function
chartServer <- function(id, data) {
    shiny::moduleServer(
        id,
        function(input, output, session) {

            chartData <- reactiveVal(
                value = list(
                  sheet1 = data.frame(
                    x = c(29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6)
                  ),
                  sheet2 = data.frame(
                    x = c(NA, 129.9, 171.5, 106.4, 129.2, 144.0, 176.0, 135.6)
                  )
                )
            )
            # render the chart
            output$chart <- highcharter::renderHighchart({

              sheet1 <- as.numeric(chartData()$sheet1$x)
              sheet2 <- as.numeric(chartData()$sheet2$x)

              # base chart without series
              hc_fill <- highcharter::highchart() |>
                # add dependency
                highcharter::hc_add_dependency("modules/pattern-fill.js") |>
                highcharter::hc_chart(type = 'area') |>
                highcharter::hc_title(text = 'Pattern fill plugin demo') |>
                highcharter::hc_xAxis(categories = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')) |>
                highcharter::hc_plotOptions(
                  area = list(
                    fillColor = list(
                      pattern = list(
                        path = list(
                          d = 'M 0 0 L 10 10 M 9 -1 L 11 1 M -1 9 L 1 11',
                          strokeWidth = 3
                          ),
                        width = 10,
                        height = 10,
                        opacity = 0.4
                        )
                      )
                    )
                  )

              # test with 2 series
              hc_fill |>
                highcharter::hc_add_series(
                  data = sheet1,
                  color= '#88e',
                  fillColor = list(
                    pattern = list(
                      color = '#11d'
                    )
                  )
                  ) |>
                highcharter::hc_add_series(
                  data = sheet2,
                  color = '#e88',
                  fillColor = list(
                    pattern = list(
                      color= '#d11'
                    )
                  )
                )

            })

            # render the spreadsheet
            output$spreadsheet <- RXSpreadsheet::renderRXSpreadsheet({
                # load only on initialisation
                shiny::isolate({

                  RXSpreadsheet::xSpreadsheet(
                      data = lapply(chartData(), function(x) {
                        as.data.frame(x)
                      }),
                      options = list(
                        mode = "edit",
                        view = list(
                            height = DT::JS("() => $('#chart-spreadsheet').height()"),
                            width = DT::JS("() => $('#chart-spreadsheet').width()")
                        ),
                        row = list(
                            height = 25,
                            len = 1000
                        )
                    )
                  )
                })
            })

            proxy <- RXSpreadsheet::xSpreadsheetProxy("spreadsheet")

            shiny::observeEvent(input$spreadsheet_change, {
                # get data from the client
                RXSpreadsheet::getData(proxy)
            })

            shiny::observe({

              # get data from the client
              shiny::req(shiny::isTruthy(input$spreadsheet_data))

              data <- jsonlite::fromJSON(
                input$spreadsheet_data,
                simplifyVector = FALSE
              )

              test <- xSpreadsheetListToDf(data, headerRow = TRUE)

              chartData(
                test
              )
            })



        }
    )
}
#### End chart interaction example