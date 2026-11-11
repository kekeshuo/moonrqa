///|
test "validate exported public records and hard matrix shape ceilings" {
  let q = recurrence_from_rows([[1, 0], [0, 1]])
    .unwrap()
    .quantify(1, 1)
    .unwrap()
  assert_eq(q.validate(), Ok(()))
  let bad = { ..q, recurrence_rate: Some(2.0), }
  assert_true(bad.validate() is Err(_))
  assert_true(windows_csv([{ start: 0, stop: 2, summary: bad, }]) is Err(_))
  assert_true(recurrence_from_rows([Array::make(4097, 0)]) is Err(_))
  assert_eq(
    best_lag([{ lag: -2147483648, recurrent: 1, eligible: 1, rate: Some(1.0), }]),
    None,
  )
  assert_eq(
    best_lag([{ lag: 0, recurrent: 1, eligible: 2, rate: Some(1.0), }]),
    None,
  )
}

///|
test "malformed and numeric resource boundaries" {
  assert_true(trajectory([[1.0e101]]) is Err(_))
  assert_true(trajectory([[], []]) is Err(_))
  assert_true(embed([], 1, 1) is Err(_))
  assert_true(embed([1.0, 2.0], 2, 2) is Err(_))
  let t = embed([0.0, 1.0], 1, 1).unwrap()
  assert_true(recurrence(t, -1.0, Euclidean, 0, 4) is Err(_))
  assert_true(recurrence(t, 0.0, Euclidean, -1, 4) is Err(_))
  assert_true(recurrence(t, 0.0, Euclidean, 0, 3) is Err(_))
  assert_true(distances(t, t, Manhattan, 3) is Err(_))
  assert_true(t.slice(1, 2) is Err(_))
  let r = recurrence(t, 0.0, Euclidean, 0, 4).unwrap()
  assert_true(r.cell(-1, 0) is Err(_))
  assert_true(r.quantify(0, 1) is Err(_))
  assert_true(r.quantify(1, 4097) is Err(_))
  assert_eq(r.quantify(4096, 4096).unwrap().validate(), Ok(()))
}

///|
test "line endpoints minimum filters and lag tie rules" {
  let r = recurrence_from_rows([[1, 1], [1, 1], [1, 1]]).unwrap()
  assert_eq(r.vertical_histogram(), [0, 0, 0, 2])
  assert_eq(r.diagonal_histogram(), [0, 2, 2])
  assert_eq(r.quantify(2, 3).unwrap().laminarity, 1.0)
  assert_eq(r.quantify(3, 4).unwrap().mean_diagonal, None)
  let p = [
    { lag: 1, recurrent: 1, eligible: 2, rate: Some(0.5), },
    { lag: -1, recurrent: 1, eligible: 2, rate: Some(0.5), },
  ]
  assert_eq(best_lag(p), Some(-1))
  assert_eq(
    best_lag([{ lag: 0, recurrent: 2, eligible: 4, rate: Some(0.5), }, ..p]),
    Some(0),
  )
}
