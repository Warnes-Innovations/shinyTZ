test_that("useShinyTZ returns a shiny.tag object", {
  result <- useShinyTZ()
  expect_s3_class(result, "shiny.tag")
})

test_that("useShinyTZ returns head tag with singleton wrapper", {
  result <- useShinyTZ()
  # Should be wrapped in singleton(tags$head(...))
  # Check that the tag tree contains a script tag pointing to the JS file
  html_str <- as.character(htmltools::renderTags(result)$html)
  expect_true(grepl("shinytz/shinytz\\.js", html_str))
})

test_that("useShinyTZ script src points to correct file", {
  result <- useShinyTZ()
  html_str <- as.character(htmltools::renderTags(result)$html)
  expect_true(grepl('src=.*shinytz/shinytz\\.js', html_str))
})
