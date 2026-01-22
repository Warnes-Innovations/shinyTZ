#' Datetime output UI element
#'
#' Creates a UI element for displaying timezone-aware datetime values.
#' Use with \code{\link{renderDatetime}} in server code.
#'
#' @param outputId Output variable name
#' @param container A function to generate an HTML element to contain the text
#' @param placeholder Placeholder text shown before reactive value available
#' @param tz_display Show timezone abbreviation (default: TRUE)
#' @param inline Use an inline (\code{span()}) or block container (\code{div()})
#'
#' @return Shiny UI output element
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # UI
#' datetimeOutput("last_update")
#' datetimeOutput("inline_time", inline = TRUE)
#'
#' # Server
#' output$last_update <- renderDatetime({
#'   Sys.time()
#' })
#' }
datetimeOutput <- function(outputId, container = if (inline) shiny::span else shiny::div, 
                           placeholder = "Loading...", tz_display = TRUE, inline = FALSE) {
  
  container(
    id = outputId,
    class = "shiny-text-output shinytz-datetime",
    `data-tz-display` = tolower(as.character(tz_display)),
    placeholder
  )
}


#' Date output UI element
#'
#' Creates a UI element for displaying timezone-aware date values (date-only).
#' Use with \code{\link{renderDate}} in server code.
#'
#' @param outputId Output variable name
#' @param container A function to generate an HTML element to contain the text
#' @param placeholder Placeholder text
#' @param inline Use an inline (\code{span()}) or block container (\code{div()})
#'
#' @return Shiny UI output element
#'
#' @export
#'
#' @examples
#' \dontrun{
#' dateOutput("processing_date")
#' dateOutput("inline_date", inline = TRUE)
#' }
dateOutput <- function(outputId, container = if (inline) shiny::span else shiny::div,
                       placeholder = "Loading...", inline = FALSE) {
  
  container(
    id = outputId,
    class = "shiny-text-output shinytz-date",
    placeholder
  )
}


#' Time output UI element
#'
#' Creates a UI element for displaying timezone-aware time values (time-only).
#' Use with \code{\link{renderTime}} in server code.
#'
#' @param outputId Output variable name
#' @param container A function to generate an HTML element to contain the text
#' @param placeholder Placeholder text
#' @param tz_display Show timezone abbreviation (default: TRUE)
#' @param inline Use an inline (\code{span()}) or block container (\code{div()})
#'
#' @return Shiny UI output element
#'
#' @export
#'
#' @examples
#' \dontrun{
#' timeOutput("current_time", tz_display = TRUE)
#' timeOutput("inline_time", inline = TRUE)
#' }
timeOutput <- function(outputId, container = if (inline) shiny::span else shiny::div,
                       placeholder = "--:--:--", tz_display = TRUE, inline = FALSE) {
  
  container(
    id = outputId,
    class = "shiny-text-output shinytz-time",
    `data-tz-display` = tolower(as.character(tz_display)),
    placeholder
  )
}
