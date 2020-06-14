
context('dataFrameListToList checks')

test_that("function converts dataframe to list", {

  testDF <- data.frame('testcol1' = 1,
                       'testcol2' = 2)

  testDFList <- list('Sheet1' = testDF)

  testList <- dataFrameListToList(testDFList)

  expect_true(is.list(testList))

})
