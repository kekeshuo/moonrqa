///|
test "agreement and union share an intersection eligibility domain" {
  let a = recurrence_from_rows([[1, 1, 0, -1, 0]]).unwrap()
  let b = recurrence_from_rows([[1, 0, 1, 1, 0]]).unwrap()
  let c = recurrence_agreement(a, b).unwrap()
  assert_eq(c.both, 1)
  assert_eq(c.common_eligible, 4)
  assert_eq(c.jaccard, Some(1.0 / 3.0))
  assert_eq(c.first_given_second, Some(0.5))
  assert_eq(union_recurrence([a, b]).unwrap().rows(), [[1, 1, 1, -1, 0]])
  let z = recurrence_from_rows([[0]]).unwrap()
  assert_eq(recurrence_agreement(z, z).unwrap().jaccard, None)
  assert_true(recurrence_agreement(a, z) is Err(_))
}
