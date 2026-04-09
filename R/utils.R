# Internal utility functions for shinyTZ

# NULL-coalescing operator: return lhs if not NULL, else rhs
# Defined here for R < 4.4.0 compatibility; base exports it from R 4.4.0+
`%||%` <- function(lhs, rhs) if (!is.null(lhs)) lhs else rhs
