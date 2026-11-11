///|
test "inclusive threshold and strict Theiler exclusion" {
  let t = embed([0.0, 1.0, 0.0], 1, 1).unwrap()
  let r = recurrence(t, 0.0, Chebyshev, 0, 9).unwrap()
  assert_eq(r.counts(), (2, 6))
  assert_eq(r.cell(0, 0).unwrap(), None)
  assert_eq(r.cell(0, 2).unwrap(), Some(true))
  assert_eq(recurrence(t, 1.0, Euclidean, 0, 9).unwrap().counts(), (6, 6))
  assert_eq(recurrence(t, 1.0, Euclidean, 3, 9).unwrap().rate(), None)
  assert_true(recurrence(t, -1.0, Euclidean, 0, 9) is Err(_))
}
