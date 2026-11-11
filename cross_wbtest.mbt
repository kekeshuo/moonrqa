///|
test "rectangular cross recurrence transposes exactly" {
  let a = embed([0.0, 1.0], 1, 1).unwrap()
  let b = embed([1.0, 0.0, 1.0], 1, 1).unwrap()
  let r = cross_recurrence(a, b, 0.0, Chebyshev, 6).unwrap()
  assert_eq(r.shape(), (2, 3))
  assert_eq(r.counts(), (3, 6))
  assert_eq(r.transpose().transpose(), r)
  assert_eq(r.transpose(), cross_recurrence(b, a, 0.0, Chebyshev, 6).unwrap())
  assert_eq(r.exclude_band(3).unwrap().counts(), (0, 0))
}
