///|
test "standardize minimum subnormal pair" {
  let t = trajectory([[5.0e-324], [1.0e-323]]).unwrap().standardize().unwrap()
  assert_eq(t.rows(), [[-1.0], [1.0]])
}

///|
test "standardize minimum subnormal constant" {
  let t = trajectory([[5.0e-324], [5.0e-324], [5.0e-324]])
    .unwrap()
    .standardize()
    .unwrap()
  assert_eq(t.rows(), [[0.0], [0.0], [0.0]])
}

///|
test "standardize minimum subnormal mixed with zero and negative values" {
  let t = trajectory([[-1.0e-323, 0.0], [0.0, 5.0e-324], [1.0e-323, 1.0e-323]]).unwrap()
  let s = t.standardize().unwrap().rows()
  assert_true((s[0][0] + 1.224744871391589).abs() < 1.0e-12)
  assert_eq(s[1][0], 0.0)
  assert_true((s[2][0] - 1.224744871391589).abs() < 1.0e-12)
  assert_true((s[0][1] + 1.224744871391589).abs() < 1.0e-12)
  assert_eq(s[1][1], 0.0)
  assert_true((s[2][1] - 1.224744871391589).abs() < 1.0e-12)
}

///|
test "standardize close large coordinates and single sample" {
  let t = trajectory([[1.0e99], [1.0e99 + 1.0e84]])
    .unwrap()
    .standardize()
    .unwrap()
  assert_eq(t.rows(), [[-1.0], [1.0]])
  let single = trajectory([[5.0e-324, -1.0e100]]).unwrap()
  assert_eq(single.standardize().unwrap().rows(), [[0.0, 0.0]])
}

///|
test "detrend minimum subnormal constant" {
  let t = trajectory([[5.0e-324], [5.0e-324], [5.0e-324]]).unwrap()
  assert_eq(t.detrend().unwrap().rows(), [[0.0], [0.0], [0.0]])
}

///|
test "detrend two subnormal observations fits the exact line" {
  for
    rows in [
      [[5.0e-324], [1.0e-323]],
      [[-4.0e-323], [-6.4e-323]],
      [[0.0], [5.0e-324]],
      [[1.0e99], [1.0e99 + 1.0e84]],
    ] {
    assert_eq(trajectory(rows).unwrap().detrend().unwrap().rows(), [
      [0.0],
      [0.0],
    ])
  }
}

///|
test "detrend preserves curved subnormal residual and scales safely" {
  // Exact rational least-squares residuals for [0, 6, 0] are [-2, 4, -2].
  let tiny = trajectory([[0.0], [3.0e-323], [0.0]]).unwrap()
  assert_eq(tiny.detrend().unwrap().rows(), [
    [-1.0e-323],
    [2.0e-323],
    [-1.0e-323],
  ])
  let large = trajectory([[1.0e99], [1.0e99 + 6.0e84], [1.0e99]]).unwrap()
  let delta = large.point(1).unwrap()[0] - large.point(0).unwrap()[0]
  let residuals = large.detrend().unwrap().rows()
  assert_true((residuals[0][0] / delta + 1.0 / 3.0).abs() < 1.0e-12)
  assert_true((residuals[1][0] / delta - 2.0 / 3.0).abs() < 1.0e-12)
  assert_true((residuals[2][0] / delta + 1.0 / 3.0).abs() < 1.0e-12)
}
