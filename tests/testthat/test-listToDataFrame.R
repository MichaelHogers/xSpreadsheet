
context('listToDataFrame checks')

test_that("test data file exists", {
  load("example.Rdata")
  expect_true(exists('savedData'))
})

test_that("test data file contains proper structure", {
  load("example.Rdata")
  expect_true(savedData[[1]][[1]]$name != '')
})


test_that("function converts x-spreadsheet list to data.frame", {

  load("example.Rdata")
  convertedData <- listToDataFrame(savedData)

  expect_true(savedData[[1]][[1]]$name == names(convertedData)[1])

})
