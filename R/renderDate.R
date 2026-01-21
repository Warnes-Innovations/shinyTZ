#' Render date with timezone awareness
#'
#' Creates a reactive output that renders POSIXct/POSIXlt date objects
#' in the user's browser timezone. Date-only (no time component).
#'
#' @param expr Expression returning POSIXct or POSIXlt datetime object
#' @param format Format string (default: "%Y-%m-%d")
#' @param tz Override timezone (defaults to browser timezone)
#' @param locale BCP 47 locale code
#' @param show_tz Whether to append timezone abbreviation (default: FALSE, rarely used for dates)
#' @param env Evaluation environment
#' @param quoted Is expr quoted?
#'
#' @return Reactive output suitable for assignment to output object
#'
#' @export
#'
#' @examples
#' \donttest{
#' output$processing_date <- renderDate({
#'   task_data$completion_date
#' }, format = "%B %d, %Y")
#' }
renderDate <- function(expr, format = "%Y-%m-%d", 
                       tz = NULL, locale = NULL, show_tz = FALSE,
                       env = parent.frame(), quoted = FALSE) {
  
  func <- shiny::installExprFunction(expr, "func", env, quoted, label = "renderDate")
  
  shiny::createRenderFunction(
    func,
    function(value, session, name, ...) {
      shiny::validate(
        shiny::need(!is.null(value), ""),
        shiny::need(inherits(value, c("POSIXct", "POSIXlt")), 
                    "renderDate requires POSIXct or POSIXlt datetime object")
      )
      
      target_tz <- tz %||% get_browser_tz(session, fallback = Sys.timezone())
      
      if (!target_tz %in% OlsonNames()) {
        message(sprintf("Warning: Invalid timezone '%s', using server timezone", target_tz))
        target_tz <- Sys.timezone()
      }
      
      result <- format_in_tz(value, format = format, tz = target_tz, locale = locale)
      
      if (show_tz) {
        dt_tz <- lubridate::with_tz(value, target_tz)
        tz_abbrev <- format(dt_tz, "%Z")
        result <- paste(result, tz_abbrev)
      }
      
      result
    },
    shiny::textOutput,
    list()
  )
}
