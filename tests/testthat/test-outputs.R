test_that("datetimeOutput creates proper UI element", {
  # Basic usage
  ui <- datetimeOutput("test_output")
  
  expect_s3_class(ui, "shiny.tag")
  expect_equal(ui$name, "div")
  expect_equal(ui$attribs$id, "test_output")
  expect_true("shiny-text-output" %in% strsplit(ui$attribs$class, " ")[[1]])
  expect_true("shinytz-datetime" %in% strsplit(ui$attribs$class, " ")[[1]])
})

test_that("datetimeOutput handles placeholder parameter", {
  # Custom placeholder
  ui_custom <- datetimeOutput("test", placeholder = "Custom placeholder")
  expect_equal(ui_custom$children[[1]], "Custom placeholder")
  
  # Default placeholder
  ui_default <- datetimeOutput("test")
  expect_equal(ui_default$children[[1]], "Loading...")
})

test_that("datetimeOutput handles tz_display parameter", {
  # With timezone display (default TRUE)
  ui_with_tz <- datetimeOutput("test", tz_display = TRUE)
  expect_equal(ui_with_tz$attribs$`data-tz-display`, "true")
  
  # Without timezone display
  ui_no_tz <- datetimeOutput("test", tz_display = FALSE)
  expect_equal(ui_no_tz$attribs$`data-tz-display`, "false")
  
  # Default behavior
  ui_default <- datetimeOutput("test")
  expect_equal(ui_default$attribs$`data-tz-display`, "true")
})

test_that("dateOutput creates proper UI element", {
  # Basic usage
  ui <- dateOutput("date_output")
  
  expect_s3_class(ui, "shiny.tag")
  expect_equal(ui$name, "div")
  expect_equal(ui$attribs$id, "date_output")
  expect_true("shiny-text-output" %in% strsplit(ui$attribs$class, " ")[[1]])
  expect_true("shinytz-date" %in% strsplit(ui$attribs$class, " ")[[1]])
})

test_that("dateOutput handles placeholder parameter", {
  # Custom placeholder
  ui_custom <- dateOutput("test", placeholder = "No date selected")
  expect_equal(ui_custom$children[[1]], "No date selected")
  
  # Default placeholder
  ui_default <- dateOutput("test")
  expect_equal(ui_default$children[[1]], "Loading...")
})

test_that("timeOutput creates proper UI element", {
  # Basic usage
  ui <- timeOutput("time_output")
  
  expect_s3_class(ui, "shiny.tag")
  expect_equal(ui$name, "div")
  expect_equal(ui$attribs$id, "time_output")
  expect_true("shiny-text-output" %in% strsplit(ui$attribs$class, " ")[[1]])
  expect_true("shinytz-time" %in% strsplit(ui$attribs$class, " ")[[1]])
})

test_that("timeOutput handles tz_display parameter", {
  # With timezone display (default TRUE)
  ui_with_tz <- timeOutput("test", tz_display = TRUE)
  expect_equal(ui_with_tz$attribs$`data-tz-display`, "true")
  
  # Without timezone display
  ui_no_tz <- timeOutput("test", tz_display = FALSE)
  expect_equal(ui_no_tz$attribs$`data-tz-display`, "false")
  
  # Default behavior (should be TRUE for time outputs)
  ui_default <- timeOutput("test")
  expect_equal(ui_default$attribs$`data-tz-display`, "true")
})

test_that("timeOutput handles placeholder parameter", {
  # Custom placeholder
  ui_custom <- timeOutput("test", placeholder = "No time available")
  expect_equal(ui_custom$children[[1]], "No time available")
  
  # Default placeholder for time output is "--:--:--"
  ui_default <- timeOutput("test")
  expect_equal(ui_default$children[[1]], "--:--:--")
})

test_that("output functions handle special characters in outputId", {
  # Test with special characters allowed in HTML IDs
  special_ids <- c("test-output", "test_output", "test.output", "output123")
  
  for (id in special_ids) {
    ui_datetime <- datetimeOutput(id)
    ui_date <- dateOutput(id)
    ui_time <- timeOutput(id)
    
    expect_equal(ui_datetime$attribs$id, id, info = paste("datetimeOutput with ID:", id))
    expect_equal(ui_date$attribs$id, id, info = paste("dateOutput with ID:", id))
    expect_equal(ui_time$attribs$id, id, info = paste("timeOutput with ID:", id))
  }
})

test_that("output functions create unique elements", {
  # Test that multiple outputs don't interfere
  ui1 <- datetimeOutput("output1")
  ui2 <- dateOutput("output2")  
  ui3 <- timeOutput("output3")
  
  expect_equal(ui1$attribs$id, "output1")
  expect_equal(ui2$attribs$id, "output2")
  expect_equal(ui3$attribs$id, "output3")
  
  expect_true("shinytz-datetime" %in% strsplit(ui1$attribs$class, " ")[[1]])
  expect_true("shinytz-date" %in% strsplit(ui2$attribs$class, " ")[[1]])
  expect_true("shinytz-time" %in% strsplit(ui3$attribs$class, " ")[[1]])
})
