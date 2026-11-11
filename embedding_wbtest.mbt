///|
test "embedding delay slicing and population scaling" {
  let t = embed([0.0, 1.0, 2.0, 3.0, 4.0], 2, 2).unwrap()
  assert_eq(t.rows(), [[0.0, 2.0], [1.0, 3.0], [2.0, 4.0]])
  assert_eq(t.slice(1, 1).unwrap().rows(), [[1.0, 3.0]])
  assert_true(t.slice(2, 2) is Err(_))
  assert_true(embed([1.0], 2, 1) is Err(_))
  let s = trajectory([[2.0], [2.0]]).unwrap().standardize().unwrap()
  assert_eq(s.rows(), [[0.0], [0.0]])
  assert_eq(t.standardize().unwrap().point(1).unwrap(), [0.0, 0.0])
}
