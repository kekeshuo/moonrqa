///|
test "threshold scan is monotone by value and preserves input order" {
  let t = embed([0.0, 1.0, 3.0], 1, 1).unwrap()
  let scan = threshold_scan(t, [3.0, 0.0, 1.0, 1.0], Euclidean, 0, 2, 2, 36).unwrap()
  assert_eq(scan.map(fn(x) { x.summary.recurrent }), [6, 0, 2, 2])
  assert_true(threshold_scan(t, [0.0, -1.0], Euclidean, 0, 2, 2, 18) is Err(_))
}
