#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(
    "shinytz",
    system.file("www", package = "shinyTZ")
  )
}
