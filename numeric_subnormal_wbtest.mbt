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
