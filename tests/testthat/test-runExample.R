test_that("Shiny example app starts", {
  app <- ShinyDriver$new("./inst/example")

  RXSpreadsheetElement <- app$findElement('.RXSpreadsheet')

  expect_true(typeof(RXSpreadsheetElement) == 'environment')
})
