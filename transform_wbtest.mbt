///|
test "coordinate projection decimation and detrending" {
  let t = trajectory([[1.0, 4.0], [3.0, 3.0], [5.0, 2.0], [7.0, 1.0]]).unwrap()
  assert_eq(t.select_dimensions([1, 0]).unwrap().point(0).unwrap(), [4.0, 1.0])
  assert_eq(t.decimate(2, 1).unwrap().rows(), [[3.0, 3.0], [7.0, 1.0]])
  assert_eq(t.detrend().unwrap().rows(), [
    [0.0, 0.0],
    [0.0, 0.0],
    [0.0, 0.0],
    [0.0, 0.0],
  ])
  assert_true(t.select_dimensions([2]) is Err(_))
  assert_true(t.decimate(0, 0) is Err(_))
}
