///|
/// Maximal vertical runs. Excluded cells terminate both black and white lines.
pub fn Recurrence::vertical_histogram(self : Recurrence) -> Array[Int32] {
  let histogram = Array::make(self.height + 1, 0)
  for j in 0..<self.width {
    let mut run = 0
    for i in 0..<self.height {
      let p = i * self.width + j
      if self.mask[p] && self.bits[p] {
        run += 1
      } else if run > 0 {
        histogram[run] += 1
        run = 0
      }
    }
    if run > 0 {
      histogram[run] += 1
    }
  }
  histogram
}

///|
/// White lines are bounded return times: gaps between two black cells.
/// Leading/trailing gaps and gaps interrupted by excluded cells are censored.
pub fn Recurrence::return_histogram(self : Recurrence) -> Array[Int32] {
  let histogram = Array::make(self.height + 1, 0)
  for j in 0..<self.width {
    let mut anchored = false
    let mut gap = 0
    for i in 0..<self.height {
      let p = i * self.width + j
      if !self.mask[p] {
        anchored = false
        gap = 0
      } else if self.bits[p] {
        if anchored && gap > 0 {
          histogram[gap] += 1
        }
        anchored = true
        gap = 0
      } else if anchored {
        gap += 1
      }
    }
  }
  histogram
}

///|
pub fn Recurrence::horizontal_histogram(self : Recurrence) -> Array[Int32] {
  self.transpose().vertical_histogram()
}
