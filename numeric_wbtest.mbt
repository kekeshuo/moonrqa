///|
test "Euclidean and scaling preserve tiny finite differences" {
  let a = trajectory([[0.0, 0.0], [3.0e-200, 4.0e-200]]).unwrap()
  let d = distance(a, 0, a, 1, Euclidean).unwrap()
  assert_true((d / 5.0e-200 - 1.0).abs() < 1.0e-12)
  let t = trajectory([[-1.0e-200], [1.0e-200]]).unwrap().standardize().unwrap()
  assert_eq(t.rows(), [[-1.0], [1.0]])
  let large = trajectory([[-1.0e100], [1.0e100]])
    .unwrap()
    .standardize()
    .unwrap()
  assert_eq(large.rows(), [[-1.0], [1.0]])
}
