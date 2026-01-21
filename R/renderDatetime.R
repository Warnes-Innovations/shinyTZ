#' Render datetime with timezone awareness
#'
#' Creates a reactive output that renders POSIXct/POSIXlt datetime objects
#' in the user's browser timezone. Automatically detects timezone via JavaScript
#' and falls back to server timezone if unavailable.
#'
#' @param expr Expression returning POSIXct or POSIXlt datetime object
#' @param format Format string using strftime syntax (default: "%Y-%m-%d %H:%M:%S")
#' @param formatter Optional custom formatter function(datetime, tz) for advanced logic.
#'   If provided, takes precedence over format parameter.
#' @param tz Override timezone (IANA name). Defaults to browser timezone if NULL.
#' @param locale BCP 47 locale code for formatting (e.g., "en-US", "de-DE")
#' @param show_tz Whether to append timezone abbreviation (e.g., "EST") to output (default: FALSE)
#' @param env Evaluation environment (default: parent.frame())
#' @param quoted Is expr quoted? (default: FALSE)
#'
#' @return Reactive output suitable for assignment to output object
#'
#' @examples
#' \donttest{
#' # Basic usage
#' output$timestamp <- renderDatetime({
#'   Sys.time()
#' })
#' }
#'
#' @export
renderDatetime <- function(expr, format = "%Y-%m-%d %H:%M:%S", 
                           formatter = NULL, tz = NULL, locale = NULL,
                           show_tz = FALSE, env = parent.frame(), quoted = FALSE) {
  
  # Convert expr to function
  func <- shiny::installExprFunction(expr, "func", env, quoted, label = "renderDatetime")
  
  # Return render function using Shiny's standard pattern
  shiny::createRenderFunction(
    func,
    function(value, session, name, ...) {
      # Validation using Shiny's validate()/need() pattern
      shiny::validate(
        shiny::need(!is.null(value), ""),  # Silent validation
        shiny::need(inherits(value, c("POSIXct", "POSIXlt")), 
                    "renderDatetime requires POSIXct or POSIXlt datetime object")
      )
      
      # Determine target timezone
      target_tz <- tz %||% get_browser_tz(session, fallback = Sys.timezone())
      
      # Validate timezone (warn but continue)
      if (!target_tz %in% OlsonNames()) {
        message(sprintf("Warning: Invalid timezone '%s', using server timezone", target_tz))
        target_tz <- Sys.timezone()
      }
      
      # Use custom formatter if provided, otherwise use format string
      result <- if (!is.null(formatter)) {
        formatter(value, target_tz)
      } else {
        format_in_tz(value, format = format, tz = target_tz, locale = locale)
      }
      
      # Append timezone abbreviation if requested
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
