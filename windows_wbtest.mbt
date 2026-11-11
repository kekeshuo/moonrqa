///|
test "complete windows budget and offset semantics" {
  let t = embed([0.0, 0.0, 0.0, 1.0, 2.0], 1, 1).unwrap()
  let w = window_rqa(t, 3, 2, 0.0, Chebyshev, 0, 2, 2, 18).unwrap()
  assert_eq(w.length(), 2)
  assert_eq(w[0].summary.recurrence_rate, Some(1.0))
  assert_eq(w[1].start, 2)
  assert_eq(w[1].stop, 5)
  assert_eq(w[1].summary.recurrence_rate, Some(0.0))
  assert_true(window_rqa(t, 3, 2, 0.0, Chebyshev, 0, 2, 2, 17) is Err(_))
}
