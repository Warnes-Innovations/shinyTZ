test_that("%||% returns lhs when not NULL", {
  expect_equal("value" %||% "fallback", "value")
  expect_equal(42L %||% 0L, 42L)
  expect_equal(FALSE %||% TRUE, FALSE)
  expect_equal(list(a = 1) %||% list(), list(a = 1))
})

test_that("%||% returns rhs when lhs is NULL", {
  expect_equal(NULL %||% "fallback", "fallback")
  expect_equal(NULL %||% 99L, 99L)
  expect_equal(NULL %||% NULL, NULL)
})

test_that("%||% does not treat NA as NULL", {
  expect_equal(NA %||% "fallback", NA)
  expect_equal(NA_character_ %||% "fallback", NA_character_)
})
