#' Render datetime with timezone awareness
#'
#' Creates a reactive output that renders POSIXct/POSIXlt datetime objects
#' in the user's browser timezone. Automatically detects timezone via JavaScript
#' and falls back to server timezone if unavailable.
#'
#' @param expr Expression returning POSIXct or POSIXlt datetime object
#' @param format Format string using strftime syntax (default: "\%Y-\%m-\%d \%H:\%M:\%S")
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
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic usage - renders in user's local timezone
#' output$timestamp <- renderDatetime({
#'   Sys.time()
#' })
#'
#' # Custom format
#' output$timestamp <- renderDatetime({
#'   Sys.time()
#' }, format = "\%B \%d, \%Y at \%I:\%M \%p")
#'
#' # Show timezone abbreviation
#' output$timestamp <- renderDatetime({
#'   Sys.time()
#' }, show_tz = TRUE)  # "2026-01-20 15:45:23 EST"
#'
#' # Custom formatter function
#' output$business_hours <- renderDatetime({
#'   task_data$start_time
#' }, formatter = function(dt, tz) {
#'   dt_tz <- lubridate::with_tz(dt, tz)
#'   hour <- lubridate::hour(dt_tz)
#'   
#'   base_format <- format(dt_tz, "\%Y-\%m-\%d \%I:\%M \%p")
#'   
#'   if (hour >= 9 && hour < 17) {
#'     paste(base_format, "(Business Hours)")
#'   } else {
#'     paste(base_format, "(After Hours)")
#'   }
#' })
#' }
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


#' Render date with timezone awareness
#'
#' Creates a reactive output that renders POSIXct/POSIXlt date objects
#' in the user's browser timezone. Date-only (no time component).
#'
#' @param expr Expression returning POSIXct or POSIXlt datetime object
#' @param format Format string (default: "\%Y-\%m-\%d")
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
#' \dontrun{
#' output$processing_date <- renderDate({
#'   task_data$completion_date
#' }, format = "\%B \%d, \%Y")
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


#' Render time with timezone awareness
#'
#' Creates a reactive output that renders POSIXct/POSIXlt time objects
#' in the user's browser timezone. Time-only (no date component).
#'
#' @param expr Expression returning POSIXct or POSIXlt datetime object
#' @param format Format string (default: "\%H:\%M:\%S")
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
#' \dontrun{
#' output$current_time <- renderTime({
#'   Sys.time()
#' }, format = "\%I:\%M:\%S \%p", show_tz = TRUE)
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
