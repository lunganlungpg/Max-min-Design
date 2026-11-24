# Regression tests against the values reported in Singh & Davidov (2026)
# and the output of the original maxmin_designs.R script.

test_that("largest-remainder rounding keeps the total", {
  n <- round_largest_remainder(480, c(3, 1, 2, 1, 1) / 8)
  expect_equal(sum(n), 480L)
  expect_type(n, "integer")
  expect_equal(round_largest_remainder(10, rep(1/3, 3)), c(4L, 3L, 3L))
})

test_that("max-min allocation is proportional to vertex degrees", {
  expect_equal(maxmin_allocation(c(4, 1, 1, 1, 1)), c(4, 1, 1, 1, 1) / 8)
})

test_that("seedling case study reproduces Table 4 powers", {
  theta <- c(0.413, 0.510, 0.617, 0.561, 0.604)
  pow_ac <- calc_power(calc_ncp(c(92, 100, 94, 98, 96), theta), df = 4)
  pow_bl <- calc_power(calc_ncp(round_largest_remainder(480, rep(0.2, 5)), theta), df = 4)
  # Paper reports 0.747 and 0.761; the exact computation gives 0.747 / 0.760,
  # so compare within a small tolerance.
  expect_equal(pow_ac, 0.747, tolerance = 0.002)
  expect_equal(pow_bl, 0.761, tolerance = 0.002)
  # Design (b): 90% power reached at N = 479 (see README results table)
  expect_equal(find_sample_size(c(3, 1, 2, 1, 1) / 8, theta), 479)
})

test_that("demo functions return tables", {
  res <- suppressWarnings(capture.output(tab <- run_seedling_case_study()))
  expect_equal(nrow(tab), 4)
  expect_true(all(tab$pi_MM > 0 & tab$pi_MM < 1))
})
