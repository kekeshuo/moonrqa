///|
test "CSV numeric dialect roundtrip CRLF headers and malformed input" {
  let t = trajectory_csv("a,b\r\n1,2\r\n3,4\r\n", true).unwrap()
  assert_eq(t.rows(), [[1.0, 2.0], [3.0, 4.0]])
  assert_eq(trajectory_csv(t.to_csv(), false).unwrap(), t)
  for text in ["1,,2", "1,2\n3", "1\n\n2", "NaN", "1,\"2\""] {
    assert_true(trajectory_csv(text, false) is Err(_))
  }
  assert_true(trajectory_csv("a,b\n1", true) is Err(_))
}
