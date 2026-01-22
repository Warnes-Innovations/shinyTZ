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

test_that("datetimeOutput handles inline parameter", {
  # inline = TRUE should use span
  ui_inline <- datetimeOutput("test", inline = TRUE)
  expect_equal(ui_inline$name, "span")
  expect_true("shiny-text-output" %in% strsplit(ui_inline$attribs$class, " ")[[1]])
  
  # inline = FALSE should use div (default)
  ui_block <- datetimeOutput("test", inline = FALSE)
  expect_equal(ui_block$name, "div")
  
  # Default should be div
  ui_default <- datetimeOutput("test")
  expect_equal(ui_default$name, "div")
})

test_that("dateOutput handles inline parameter", {
  # inline = TRUE should use span
  ui_inline <- dateOutput("test", inline = TRUE)
  expect_equal(ui_inline$name, "span")
  
  # inline = FALSE should use div
  ui_block <- dateOutput("test", inline = FALSE)
  expect_equal(ui_block$name, "div")
  
  # Default should be div
  ui_default <- dateOutput("test")
  expect_equal(ui_default$name, "div")
})

test_that("timeOutput handles inline parameter", {
  # inline = TRUE should use span
  ui_inline <- timeOutput("test", inline = TRUE)
  expect_equal(ui_inline$name, "span")
  
  # inline = FALSE should use div
  ui_block <- timeOutput("test", inline = FALSE)
  expect_equal(ui_block$name, "div")
  
  # Default should be div
  ui_default <- timeOutput("test")
  expect_equal(ui_default$name, "div")
})

test_that("output functions handle custom container", {
  # Custom container function for datetimeOutput
  ui_custom <- datetimeOutput("test", container = htmltools::tags$article)
  expect_equal(ui_custom$name, "article")
  expect_equal(ui_custom$attribs$id, "test")
  
  # Custom container for dateOutput
  ui_date <- dateOutput("test", container = htmltools::tags$section)
  expect_equal(ui_date$name, "section")
  
  # Custom container for timeOutput  
  ui_time <- timeOutput("test", container = htmltools::tags$span)
  expect_equal(ui_time$name, "span")
})

test_that("container parameter overrides inline default", {
  # When both inline and container specified, container should win
  ui_inline_div <- datetimeOutput("test", inline = TRUE, container = htmltools::tags$div)
  expect_equal(ui_inline_div$name, "div", info = "container=div should override inline=TRUE default")
  
  ui_block_span <- datetimeOutput("test", inline = FALSE, container = htmltools::tags$span)
  expect_equal(ui_block_span$name, "span", info = "container=span should override inline=FALSE default")
  
  # inline only affects the default when container not specified
  ui_inline_default <- datetimeOutput("test", inline = TRUE)
  expect_equal(ui_inline_default$name, "span", info = "inline=TRUE uses span when container not specified")
  
  ui_block_default <- datetimeOutput("test", inline = FALSE)
  expect_equal(ui_block_default$name, "div", info = "inline=FALSE uses div when container not specified")
})
