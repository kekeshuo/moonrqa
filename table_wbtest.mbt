///|
test "numeric tables retain undefined cells and recompute lag fractions" {
  let t = embed([0.0, 1.0], 1, 1).unwrap()
  let w = window_rqa(t, 2, 1, 0.0, Chebyshev, 0, 2, 2, 4).unwrap()
  let text = windows_csv(w).unwrap()
  assert_true(text.has_prefix("start,stop,recurrent,eligible"))
  assert_true(text.contains("0,2,0,2,0"))
  let s = threshold_scan(t, [0.0, 1.0], Chebyshev, 0, 2, 2, 8).unwrap()
  assert_true(thresholds_csv(s).unwrap().has_prefix("threshold,"))
  assert_eq(
    lags_csv([{ lag: 0, recurrent: 1, eligible: 2, rate: Some(9.0), }]).unwrap(),
    "lag,recurrent,eligible,rate\n0,1,2,0.5\n",
  )
  assert_true(
    lags_csv([{ lag: 0, recurrent: 3, eligible: 2, rate: None, }]) is Err(_),
  )
}
