///|
test "three norms and preallocation budget" {
  let t = trajectory([[0.0, 0.0], [3.0, 4.0]]).unwrap()
  assert_eq(distance(t, 0, t, 1, Euclidean).unwrap(), 5.0)
  assert_eq(distance(t, 0, t, 1, Manhattan).unwrap(), 7.0)
  assert_eq(distance(t, 0, t, 1, Chebyshev).unwrap(), 4.0)
  assert_true(distances(t, t, Euclidean, 3) is Err(_))
  assert_eq(distances(t, t, Euclidean, 4).unwrap()[1][0], 5.0)
}
