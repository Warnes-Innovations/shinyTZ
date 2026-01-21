#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  # Add resource path for JavaScript files
  shiny::addResourcePath(
    "shinytz",
    system.file("www", package = "shinytz")
  )
  
  invisible()
}
