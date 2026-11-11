///|
/// Joint recurrence intersects masks as well as recurrence indicators.
pub fn joint_recurrence(
  matrices : Array[Recurrence],
) -> Result[Recurrence, RqaError] {
  if matrices.length() == 0 || matrices.length() > 64 {
    return Err(Invalid("joint matrix count"))
  }
  let first = matrices[0]
  let bits = first.bits.copy()
  let mask = first.mask.copy()
  for r in matrices {
    if r.shape() != first.shape() {
      return Err(Invalid("joint shape mismatch"))
    }
    for p in 0..<bits.length() {
      mask[p] = mask[p] && r.mask[p]
      bits[p] = mask[p] && bits[p] && r.bits[p]
    }
  }
  Ok({ height: first.height, width: first.width, bits, mask, })
}

///|
/// Import a ternary matrix: -1 excluded, 0 nonrecurrent, 1 recurrent.
pub fn recurrence_from_rows(
  rows : Array[Array[Int32]],
) -> Result[Recurrence, RqaError] {
  if rows.length() == 0 {
    return Err(Invalid("empty recurrence rows"))
  }
  let n = rows.length()
  let m = rows[0].length()
  if !cell_budget(n, m, 1048576) {
    return Err(Limit("import matrix cell budget"))
  }
  let bits : Array[Bool] = []
  let mask : Array[Bool] = []
  for row in rows {
    if row.length() != m {
      return Err(Invalid("ragged recurrence matrix"))
    }
    for x in row {
      if x < -1 || x > 1 {
        return Err(Invalid("ternary cell"))
      }
      bits.push(x == 1)
      mask.push(x != -1)
    }
  }
  Ok({ height: n, width: m, bits, mask, })
}

///|
pub fn Recurrence::rows(self : Recurrence) -> Array[Array[Int32]] {
  Array::makei(self.height, fn(i) {
    Array::makei(self.width, fn(j) {
      let p = i * self.width + j
      if !self.mask[p] {
        -1
      } else if self.bits[p] {
        1
      } else {
        0
      }
    })
  })
}
