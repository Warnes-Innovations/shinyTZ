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
