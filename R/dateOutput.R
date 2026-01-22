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
