///|
test "trajectory validates shape and snapshots ownership" {
  let rows = [[1.0, 2.0], [3.0, 4.0]]
  let t = trajectory(rows).unwrap()
  rows[0][0] = 99.0
  assert_eq(t.point(0).unwrap(), [1.0, 2.0])
  let copy = t.rows()
  copy[1][0] = 99.0
  assert_eq(t.point(1).unwrap(), [3.0, 4.0])
  assert_eq(t.dimension(), 2)
  assert_true(trajectory([]) is Err(_))
  assert_true(trajectory([[1.0], []]) is Err(_))
  assert_true(t.point(-1) is Err(_))
}
