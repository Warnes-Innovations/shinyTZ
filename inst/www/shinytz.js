// shinyTZ: Browser timezone detection for Shiny applications
// Detects browser timezone and locale on initial connection

$(document).on('shiny:connected', function(event) {
  // Detect browser timezone using Intl API
  var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  
  // Validate timezone (log warnings only, R will handle final validation)
  if (!tz || tz === '') {
    console.warn('shinyTZ: Could not detect browser timezone, server will use fallback');
  }
  
  // Send to server as reactive input
  Shiny.setInputValue('shinytz_browser_tz', tz, {priority: 'event'});
  
  // Also detect locale
  var locale = navigator.language || navigator.userLanguage;
  Shiny.setInputValue('shinytz_browser_locale', locale, {priority: 'event'});
  
  // Detect UTC offset (for display purposes, in minutes)
  var offset = new Date().getTimezoneOffset();
  Shiny.setInputValue('shinytz_utc_offset', offset, {priority: 'event'});
  
  // Log successful detection for debugging
  console.log('shinyTZ: Detected timezone:', tz, '| Locale:', locale);
});
