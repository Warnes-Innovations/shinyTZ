#' Render time with timezone awareness
#'
#' Creates a reactive output that renders POSIXct/POSIXlt time objects
#' in the user's browser timezone. Time-only (no date component).
#'
#' @param expr Expression returning POSIXct or POSIXlt datetime object
#' @param format Format string (default: "%H:%M:%S")
#' @param tz Override timezone (defaults to browser timezone)
#' @param show_tz Whether to append timezone abbreviation (default: FALSE)
#' @param env Evaluation environment
#' @param quoted Is expr quoted?
#'
#' @return Reactive output suitable for assignment to output object
#'
#' @export
#'
#' @examples
#' \donttest{
#' output$current_time <- renderTime({
#'   Sys.time()
#' }, format = "%I:%M:%S %p", show_tz = TRUE)
#' }
renderTime <- function(expr, format = "%H:%M:%S", tz = NULL, show_tz = FALSE,
                       env = parent.frame(), quoted = FALSE) {
  
  func <- shiny::installExprFunction(expr, "func", env, quoted, label = "renderTime")
  
  shiny::createRenderFunction(
    func,
    function(value, session, name, ...) {
      shiny::validate(
        shiny::need(!is.null(value), ""),
        shiny::need(inherits(value, c("POSIXct", "POSIXlt")), 
                    "renderTime requires POSIXct or POSIXlt datetime object")
      )
      
      target_tz <- tz %||% get_browser_tz(session, fallback = Sys.timezone())
      
      if (!target_tz %in% OlsonNames()) {
        message(sprintf("Warning: Invalid timezone '%s', using server timezone", target_tz))
        target_tz <- Sys.timezone()
      }
      
      result <- format_in_tz(value, format = format, tz = target_tz)
      
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
