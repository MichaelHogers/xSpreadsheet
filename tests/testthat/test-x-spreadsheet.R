test_that("spreadSheet works with different data options", {
    test <- spreadsheet(data = data.frame(a = 1, b = 1))
    expect_s3_class(test, "xspreadsheet")

    list1Entry <- list("Sheet" = data.frame(
        a = 1, b = 2
    ))
    test <- spreadsheet(data = data.frame(a = 1, b = 1))
    expect_s3_class(test, "xspreadsheet")

    list2Entries <- list(
        "Sheet 1" = data.frame(a = 1, b = 1),
        "Sheet 2" = data.frame(c = 3, d = 4)
    )
    test <- spreadsheet(data = list2Entries)
    expect_s3_class(test, "xspreadsheet")

})

test_that("processInputData works", {
    data <- data.frame(a = 1, b = 1)
    expect_no_error(processInputData(data))

    data <- list("Sheet" = data.frame(
        a = 1, b = 2
    ))
    expect_no_error(processInputData(data))

    data <- list(
        "Sheet 1" = data.frame(a = 1, b = 1),
        "Sheet 2" = data.frame(c = 3, d = 4)
    )
    expect_no_error(processInputData(data))

    errorEntry <- "invalid"
    expect_error(processInputData(errorEntry))
})

test_that("spreadsheetListToDf works", {
    # multiple sheets
    jsonList <- jsonlite::fromJSON(
        txt = system.file(
            "/testdata/multiple-sheets.json",
            package = "xSpreadsheet"
        ),
        simplifyVector = FALSE
    )

    result <- spreadsheetListToDf(jsonList)

    # expect multiple list entries with different names
    expect_true(length(result) > 1)
    expect_true(length(unique(names(result))) > 1)
    # expect data.frames
    expect_true(all(sapply(result, is.data.frame)))

    # single sheet
    jsonList <- jsonlite::fromJSON(
        txt = system.file(
            "/testdata/single-sheet.json",
            package = "spreadSheet"
        ),
        simplifyVector = FALSE
    )
    result <- spreadsheetListToDf(jsonList)

    # expect single list entry
    expect_true(length(result) == 1)
    expect_true(length(unique(names(result))) == 1)
    # expect a data.frame
    expect_true(all(sapply(result, is.data.frame)))

})
