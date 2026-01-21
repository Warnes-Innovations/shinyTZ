#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  # Add resource path for JavaScript files
  # Only add if directory exists (handles devtools::load_all())
  www_dir <- system.file("www", package = "shinyTZ")
  
  if (nzchar(www_dir) && dir.exists(www_dir)) {
    shiny::addResourcePath(
      "shinytz",
      www_dir
    )
  }
  
  invisible()
}
