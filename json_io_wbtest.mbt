///|
test "JSON roundtrip null undefined values and report schema" {
  let t = trajectory_json("[[0,1],[2,3]]").unwrap()
  assert_eq(trajectory_json(t.to_json().stringify()).unwrap(), t)
  let report = analysis_json(t, 1.0, Euclidean, 0, 2, 2, 4).unwrap().stringify()
  assert_true(report.contains("moonrqa/1"))
  assert_true(report.contains("mean_diagonal"))
  let empty = recurrence_from_rows([[-1]])
    .unwrap()
    .quantify(2, 2)
    .unwrap()
    .to_json()
    .stringify()
  assert_true(empty.contains("null"))
  for s in ["{}", "[[null]]", "[[1],[2,3]]", "[[1e200]]", "[[[1]]]"] {
    assert_true(trajectory_json(s) is Err(_))
  }
}
