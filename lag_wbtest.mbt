///|
test "cross lag sign and unsupported lags" {
  let a = embed([0.0, 1.0, 2.0], 1, 1).unwrap()
  let b = embed([9.0, 0.0, 1.0, 2.0], 1, 1).unwrap()
  let r = cross_recurrence(a, b, 0.0, Chebyshev, 12).unwrap()
  let p = r.lag_profile(-4, 4).unwrap()
  assert_eq(best_lag(p), Some(1))
  assert_eq(p[8].rate, None)
  assert_eq(best_lag([]), None)
}
