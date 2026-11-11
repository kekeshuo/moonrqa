///|
test "partial density blocks preserve exclusion denominators" {
  let r = recurrence_from_rows([[-1, 1, 0], [1, 1, 0], [0, 0, -1]]).unwrap()
  let b = r.block_densities(2, 2).unwrap()
  assert_eq(b.length(), 4)
  assert_eq(b[0].rate, Some(1.0))
  assert_eq(b[3].rate, None)
  assert_eq(b[3].row_stop, 3)
  assert_eq(r.crop(1, 1, 2, 2).unwrap().rows(), [[1, 0], [0, -1]])
  assert_true(r.crop(2, 2, 2, 2) is Err(_))
}
