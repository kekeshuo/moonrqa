///|
/// Missing/excluded cells are distinct from nonrecurrent eligible cells.
pub struct Recurrence {
  height : Int32
  width : Int32
  bits : Array[Bool]
  mask : Array[Bool]
} derive(Debug, Eq)

///|
pub extend Recurrence with @debug.Debug::{to_repr}

///|
pub extend Recurrence with Eq::{equal, not_equal}

///|
fn cell_budget(rows : Int32, cols : Int32, max_cells : Int32) -> Bool {
  rows > 0 &&
  cols > 0 &&
  max_cells > 0 &&
  max_cells <= 1048576 &&
  rows <= max_cells / cols
}

///|
pub fn recurrence(
  a : Trajectory,
  threshold : Double,
  metric : Metric,
  theiler : Int32,
  max_cells : Int32,
) -> Result[Recurrence, RqaError] {
  if !finite(threshold) || threshold < 0.0 {
    return Err(Invalid("threshold"))
  }
  if theiler < 0 || theiler > 4096 {
    return Err(Invalid("Theiler width"))
  }
  if !cell_budget(a.samples, a.samples, max_cells) {
    return Err(Limit("recurrence cell budget"))
  }
  let n = a.samples
  let mask = Array::makei(n * n, fn(p) { (p / n - p % n).abs() > theiler })
  let bits = Array::makei(n * n, fn(p) {
    mask[p] && point_distance(a, p / n, a, p % n, metric) <= threshold
  })
  Ok({ height: n, width: n, bits, mask, })
}

///|
pub fn Recurrence::shape(self : Recurrence) -> (Int32, Int32) {
  (self.height, self.width)
}

///|
pub fn Recurrence::cell(
  self : Recurrence,
  i : Int32,
  j : Int32,
) -> Result[Bool?, RqaError] {
  if i < 0 || i >= self.height || j < 0 || j >= self.width {
    return Err(Invalid("matrix index"))
  }
  let p = i * self.width + j
  Ok(if self.mask[p] { Some(self.bits[p]) } else { None })
}

///|
pub fn Recurrence::counts(self : Recurrence) -> (Int32, Int32) {
  let mut yes = 0
  let mut eligible = 0
  for i in 0..<self.bits.length() {
    if self.mask[i] {
      eligible += 1
      if self.bits[i] {
        yes += 1
      }
    }
  }
  (yes, eligible)
}

///|
pub fn Recurrence::rate(self : Recurrence) -> Double? {
  let (yes, all) = self.counts()
  if all == 0 {
    None
  } else {
    Some(yes.to_double() / all.to_double())
  }
}
