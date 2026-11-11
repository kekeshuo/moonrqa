///|
test "vertical runs and censored return gaps" {
  let r = recurrence_from_rows([[0], [1], [0], [0], [1], [1], [0]]).unwrap()
  assert_eq(r.vertical_histogram(), [0, 1, 1, 0, 0, 0, 0, 0])
  assert_eq(r.return_histogram(), [0, 0, 1, 0, 0, 0, 0, 0])
  let excluded = recurrence_from_rows([[1], [0], [-1], [0], [1]]).unwrap()
  assert_eq(excluded.return_histogram(), [0, 0, 0, 0, 0, 0])
  assert_eq(r.horizontal_histogram()[1], 3)
}
