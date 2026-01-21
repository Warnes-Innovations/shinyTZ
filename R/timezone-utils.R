#' Get browser timezone from session
#'
#' Retrieves the timezone detected from the user's browser via JavaScript.
#' Falls back to server timezone if JavaScript unavailable or invalid.
#'
#' @param session Shiny session object (default: current reactive domain)
#' @param fallback Fallback timezone if detection unavailable (default: Sys.timezone())
#'
#' @return Character string with IANA timezone name (e.g., "America/New_York")
#'
#' @export
#'
#' @examples
#' \dontrun{
#' server <- function(input, output, session) {
#'   user_tz <- reactive({
#'     get_browser_tz(session)
#'   })
#'   
#'   output$debug_info <- renderText({
#'     paste("Your timezone:", user_tz())
#'   })
#' }
#' }
get_browser_tz <- function(session = shiny::getDefaultReactiveDomain(), 
                           fallback = Sys.timezone()) {
  
  if (is.null(session)) {
    warning("No active Shiny session, using fallback timezone")
    return(fallback)
  }
  
  # Get reactive input from JavaScript
  browser_tz <- session$input$shinytz_browser_tz
  
  if (is.null(browser_tz) || browser_tz == "") {
    return(fallback)
  }
  
  # Validate timezone
  if (!browser_tz %in% OlsonNames()) {
    warning(sprintf("Invalid timezone '%s', using fallback", browser_tz))
    return(fallback)
  }
  
  browser_tz
}


#' Format datetime in specific timezone
#'
#' Formats POSIXct/POSIXlt objects in a specific timezone using strftime syntax.
#' Helper function for timezone conversion and formatting.
#'
#' @param datetime POSIXct or POSIXlt object
#' @param format Format string using strftime syntax (default: "\%Y-\%m-\%d \%H:\%M:\%S")
#' @param tz Target timezone (IANA name). Defaults to Sys.timezone() if NULL.
#' @param locale BCP 47 locale code (reserved for future use)
#'
#' @return Formatted character string
#'
#' @export
#'
#' @examples
#' # Format server timestamp in specific timezone
#' ts <- Sys.time()
#' format_in_tz(ts, format = "\%Y-\%m-\%d \%H:\%M:\%S \%Z", tz = "America/New_York")
#' format_in_tz(ts, format = "\%Y-\%m-\%d \%H:\%M:\%S \%Z", tz = "Asia/Tokyo")
format_in_tz <- function(datetime, format = "%Y-%m-%d %H:%M:%S", 
                         tz = NULL, locale = NULL) {
  
  if (is.null(datetime) || all(is.na(datetime))) {
    return("")
  }
  
  if (is.null(tz)) tz <- Sys.timezone()
  
  # Convert to target timezone
  datetime_tz <- lubridate::with_tz(datetime, tz)
  
  # Format
  formatted <- format(datetime_tz, format = format)
  
  formatted
}
