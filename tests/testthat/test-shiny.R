test_that("spreadsheetProxy works", {
    demoServer <- function(input, output, session) {
        spreadsheetProxy("test", session)
    }

    # expect no error
    shiny::testServer(
        demoServer,
        {
            expect_true(TRUE)
        }
    )

    # expect error
    testthat::expect_error({
      spreadsheetProxy("test")
    })

    # expect no error
    testthat::expect_no_error({
        spreadsheetProxy("test", session = shiny::MockShinySession$new())
    })
})

test_that("invokeRemote works as expected on the R side", {
    fmls <- rlang::fn_fmls(invokeRemote)
    methods <- eval(fmls$method)

    session <- shiny::MockShinySession$new()

    # loop over methods
    for (method in methods) {
        # expect no error
        testthat::expect_no_error({
            invokeRemote(
                proxy = spreadsheetProxy("test", session),
                method = method
            )
        })
    }

    # expect an error when the proxy is an invalid object
    testthat::expect_error({
        invokeRemote(
                    proxy = "test",
                    method = method
        )
    })

})

test_that("deleteSheet works", {
    proxy <- spreadsheetProxy("test", shiny::MockShinySession$new())
    result <- deleteSheet(
        proxy = proxy
    )
    expect_s3_class(result, "rspreadSheetProxy")

    result <- deleteSheet(
        proxy = proxy,
        sheetIndex = 1
    )
    expect_s3_class(result, "rspreadSheetProxy")


    testthat::expect_warning({
        result <- deleteSheet(
            proxy = proxy,
            sheetIndex = 0
        )
    })

    testthat::expect_warning({
        result <- deleteSheet(
            proxy = proxy,
            sheetIndex = -1
        )
    })
})
