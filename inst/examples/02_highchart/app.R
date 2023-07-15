library(shiny)
library(xSpreadsheet)
library(highcharter)

ui <- shiny::fluidPage(
    shiny::fluidRow(
        shiny::column(
            6,
            xSpreadsheet::spreadsheetOutput(
                outputId = ("spreadsheet"),
                height = "800px"
            )
        ),
        shiny::column(
            6,
            highcharter::highchartOutput(
                outputId = ("chart"),
                # otherwise chart does not fit
                height = "800px"
            )
        )
    )
)

server <- function(input, output, session) {
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
        hcFill <- highcharter::highchart() |>
            # add dependency
            highcharter::hc_add_dependency("modules/pattern-fill.js") |>
            highcharter::hc_chart(type = "area") |>
            highcharter::hc_title(text = "Pattern fill plugin demo") |>
            highcharter::hc_xAxis(categories = c("Jan", "Feb", "Mar",
            "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct",
            "Nov", "Dec")) |>
            highcharter::hc_plotOptions(
                area = list(
                    fillColor = list(
                        pattern = list(
                            path = list(
                                d = "M 0 0 L 10 10 M 9 -1 L 11 1 M -1 9 L 1 11",
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
        hcFill |>
            highcharter::hc_add_series(
                data = sheet1,
                color = "#88e",
                fillColor = list(
                    pattern = list(
                        color = "#11d"
                    )
                )
            ) |>
            highcharter::hc_add_series(
                data = sheet2,
                color = "#e88",
                fillColor = list(
                    pattern = list(
                        color = "#d11"
                    )
                )
            )
    })

    # render the spreadsheet
    output$spreadsheet <- xSpreadsheet::renderSpreadsheet({

        # load only on initialisation
        shiny::isolate({
            xSpreadsheet::spreadSheet(
                data = lapply(chartData(), function(x) {
                    as.data.frame(x)
                }),
                options = list(
                    mode = "edit",
                    row = list(
                        height = 25,
                        len = 1000
                    )
                )
            )
        })
    })

    proxy <- xSpreadsheet::spreadsheetProxy("spreadsheet")

    shiny::observeEvent(input$spreadsheet_change, {
        # get data from the client
        xSpreadsheet::getData(proxy)
    })

    shiny::observe({
        # get data from the client
        shiny::req(shiny::isTruthy(input$spreadsheet_data))

        data <- jsonlite::fromJSON(
            input$spreadsheet_data,
            simplifyVector = FALSE
        )

        test <- spreadsheetListToDf(data, headerRow = TRUE)

        chartData(
            test
        )
    })
}

shiny::shinyApp(ui, server)
