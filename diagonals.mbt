///|
/// Histogram index equals run length; index zero is always zero.
pub fn Recurrence::diagonal_histogram(self : Recurrence) -> Array[Int32] {
  let histogram = Array::make(self.height.min(self.width) + 1, 0)
  for i in 0..<self.height {
    for j in 0..<self.width {
      let p = i * self.width + j
      if !self.bits[p] || !self.mask[p] {
        continue
      }
      if i > 0 && j > 0 {
        let previous = (i - 1) * self.width + j - 1
        if self.bits[previous] && self.mask[previous] {
          continue
        }
      }
      let mut length = 0
      let mut row = i
      let mut col = j
      while row < self.height && col < self.width {
        let q = row * self.width + col
        if !self.mask[q] || !self.bits[q] {
          break
        }
        length += 1
        row += 1
        col += 1
      }
      histogram[length] += 1
    }
  }
  histogram
}
