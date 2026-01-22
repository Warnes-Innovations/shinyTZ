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
