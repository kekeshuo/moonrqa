///|
test "RQA ratios and undefined means follow declared denominators" {
  let r = recurrence_from_rows([[1, 0, 1], [0, 1, 0], [1, 0, 1]]).unwrap()
  let q = r.quantify(2, 2).unwrap()
  assert_eq(q.recurrent, 5)
  assert_eq(q.eligible, 9)
  assert_eq(q.determinism, 0.6)
  assert_eq(q.laminarity, 0.0)
  assert_eq(q.mean_diagonal, Some(3.0))
  assert_eq(q.trapping_time, None)
  let e = recurrence_from_rows([[-1]]).unwrap().quantify(2, 2).unwrap()
  assert_eq(e.recurrence_rate, None)
  assert_eq(e.divergence, None)
  assert_eq(e.diagonal_entropy, 0.0)
}
