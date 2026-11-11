///|
/// Cross recurrence does not assume synchronized clocks or exclude a diagonal.
pub fn cross_recurrence(
  a : Trajectory,
  b : Trajectory,
  threshold : Double,
  metric : Metric,
  max_cells : Int32,
) -> Result[Recurrence, RqaError] {
  if a.dimensions != b.dimensions {
    return Err(Invalid("cross coordinate dimensions"))
  }
  if !finite(threshold) || threshold < 0.0 {
    return Err(Invalid("cross threshold"))
  }
  if !cell_budget(a.samples, b.samples, max_cells) {
    return Err(Limit("cross recurrence cell budget"))
  }
  let size = a.samples * b.samples
  Ok({
    height: a.samples,
    width: b.samples,
    mask: Array::make(size, true),
    bits: Array::makei(size, fn(p) {
      point_distance(a, p / b.samples, b, p % b.samples, metric) <= threshold
    }),
  })
}

///|
/// Restrict aligned indices in any matrix. Excluded cells split line structures.
pub fn Recurrence::exclude_band(
  self : Recurrence,
  width : Int32,
) -> Result[Recurrence, RqaError] {
  if width < 0 || width > 4096 {
    return Err(Invalid("exclusion band"))
  }
  let mask = Array::makei(self.bits.length(), fn(p) {
    self.mask[p] && (p / self.width - p % self.width).abs() > width
  })
  let bits = Array::makei(self.bits.length(), fn(p) { mask[p] && self.bits[p] })
  Ok({ height: self.height, width: self.width, bits, mask, })
}

///|
pub fn Recurrence::transpose(self : Recurrence) -> Recurrence {
  let bits = Array::makei(self.bits.length(), fn(p) {
    self.bits[p % self.height * self.width + p / self.height]
  })
  let mask = Array::makei(self.mask.length(), fn(p) {
    self.mask[p % self.height * self.width + p / self.height]
  })
  { height: self.width, width: self.height, bits, mask, }
}
