///|
test "diagonals count each maximal run once including boundaries" {
  let r = recurrence_from_rows([[1, 0, 1], [0, 1, 0], [1, 0, 1]]).unwrap()
  assert_eq(r.diagonal_histogram(), [0, 2, 0, 1])
  assert_eq(r.counts().0, 5)
  let split = recurrence_from_rows([[1, 0, 0], [0, -1, 0], [0, 0, 1]]).unwrap()
  assert_eq(split.diagonal_histogram(), [0, 2, 0, 0])
}
