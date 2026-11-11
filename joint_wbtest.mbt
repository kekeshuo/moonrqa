///|
test "joint preserves masks and import has ternary roundtrip" {
  let a = recurrence_from_rows([[1, 0], [-1, 1]]).unwrap()
  let b = recurrence_from_rows([[1, 1], [1, 0]]).unwrap()
  assert_eq(joint_recurrence([a, b]).unwrap().rows(), [[1, 0], [-1, 0]])
  assert_eq(recurrence_from_rows(a.rows()).unwrap(), a)
  assert_true(joint_recurrence([]) is Err(_))
  assert_true(recurrence_from_rows([[2]]) is Err(_))
}
