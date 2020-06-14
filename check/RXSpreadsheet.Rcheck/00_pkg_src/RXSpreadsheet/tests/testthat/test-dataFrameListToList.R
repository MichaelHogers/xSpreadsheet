
context('dataFrameListToList checks')

test_that("function converts dataframe to proper list", {

  testDF <- data.frame('testcol1' = 1,
                       'testcol2' = 2)

  testDFList <- list('Sheet1' = testDF)

  testList <- dataFrameListToList(inputData = testDFList)

  expect_true(is.list(testList))

})

test_that("function returns error if a data.frame is entered", {

  testDF <- data.frame('testcol1' = 1,
                       'testcol2' = 2)
  expect_error(
    dataFrameListToList(inputData = testDF)
  )

})

test_that("function returns expected columns", {

  testDF <- data.frame('testcol1' = 1,
                       'testcol2' = 2)

  testDFList <- list('Sheet1' = testDF)

  testList <- dataFrameListToList(inputData = testDFList)

  namesOfList <- names(testList[[1]][[1]])

  expect_true('name' %in% namesOfList)
  expect_true('freeze' %in% namesOfList)
  expect_true('styles' %in% namesOfList)
  expect_true('merges' %in% namesOfList)
  expect_true('rows' %in% namesOfList)
  expect_true('cols' %in% namesOfList)
  expect_true('validations' %in% namesOfList)
  expect_true('autofilter' %in% namesOfList)

})

test_that("function returns the proper amount of sheets", {

  testDF <- data.frame('testcol1' = 1,
                       'testcol2' = 2)

  testDFList <- list('Sheet1' = testDF,
                     'Sheet2' = testDF)

  testList <- dataFrameListToList(inputData = testDFList)

  expect_true(testList[[1]][[1]]$name == 'Sheet1')
  expect_true(testList[[1]][[2]]$name == 'Sheet2')

})


