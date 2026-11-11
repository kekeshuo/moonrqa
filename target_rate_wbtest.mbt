///|
test "rate targeting includes ties and handles endpoint requests" {
  let t = embed([0.0, 0.0, 2.0], 1, 1).unwrap()
  let a = recurrence_at_rate(t, 0.1, Chebyshev, 0, 9).unwrap()
  assert_eq(a.threshold, 0.0)
  assert_eq(a.achieved_rate, 1.0 / 3.0)
  assert_eq(
    recurrence_at_rate(t, 1.0, Chebyshev, 0, 9).unwrap().achieved_rate,
    1.0,
  )
  assert_true(recurrence_at_rate(t, 0.5, Chebyshev, 3, 9) is Err(_))
}
