#' Format datetime in specific timezone
#'
#' Formats POSIXct/POSIXlt objects in a specific timezone using strftime syntax.
#' Helper function for timezone conversion and formatting.
#'
#' @param datetime POSIXct or POSIXlt object
#' @param format Format string using strftime syntax (default: "%Y-%m-%d %H:%M:%S")
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
#' format_in_tz(ts, format = "%Y-%m-%d %H:%M:%S %Z", tz = "America/New_York")
#' format_in_tz(ts, format = "%Y-%m-%d %H:%M:%S %Z", tz = "Asia/Tokyo")
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
