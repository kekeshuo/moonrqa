///|
fn histogram_points(histogram : Array[Int32], minimum : Int32) -> Int32 {
  let mut points = 0
  for length in minimum..<histogram.length() {
    points += length * histogram[length]
  }
  points
}

///|
fn histogram_lines(histogram : Array[Int32], minimum : Int32) -> Int32 {
  let mut lines = 0
  for length in minimum..<histogram.length() {
    lines += histogram[length]
  }
  lines
}

///|
fn histogram_longest(histogram : Array[Int32], minimum : Int32) -> Int32 {
  let mut longest = 0
  for length in minimum..<histogram.length() {
    if histogram[length] > 0 {
      longest = length
    }
  }
  longest
}

///|
pub(all) struct RqaSummary {
  recurrent : Int32
  eligible : Int32
  recurrence_rate : Double?
  determinism : Double
  laminarity : Double
  mean_diagonal : Double?
  longest_diagonal : Int32
  divergence : Double?
  diagonal_entropy : Double
  trapping_time : Double?
  longest_vertical : Int32
  vertical_entropy : Double
  mean_return_gap : Double?
} derive(Debug, Eq)

///|
pub extend RqaSummary with @debug.Debug::{to_repr}

///|
pub extend RqaSummary with Eq::{equal, not_equal}

///|
fn histogram_mean(h : Array[Int32], minimum : Int32) -> Double? {
  let lines = histogram_lines(h, minimum)
  if lines == 0 {
    None
  } else {
    Some(histogram_points(h, minimum).to_double() / lines.to_double())
  }
}

///|
fn histogram_entropy(h : Array[Int32], minimum : Int32) -> Double {
  let count = histogram_lines(h, minimum)
  if count == 0 {
    return 0.0
  }
  let mut entropy = 0.0
  for i in minimum..<h.length() {
    if h[i] > 0 {
      let probability = h[i].to_double() / count.to_double()
      entropy -= probability * @math.ln(probability)
    }
  }
  entropy
}

///|
/// DET/LAM use all eligible black points as denominator; an empty set gives zero.
/// Means/divergence use None when no qualifying line exists.
pub fn Recurrence::quantify(
  self : Recurrence,
  minimum_diagonal : Int32,
  minimum_vertical : Int32,
) -> Result[RqaSummary, RqaError] {
  if minimum_diagonal < 1 ||
    minimum_diagonal > 4096 ||
    minimum_vertical < 1 ||
    minimum_vertical > 4096 {
    return Err(Invalid("minimum line length"))
  }
  let diagonal = self.diagonal_histogram()
  let vertical = self.vertical_histogram()
  let white = self.return_histogram()
  let (recurrent, eligible) = self.counts()
  let det = if recurrent == 0 {
    0.0
  } else {
    histogram_points(diagonal, minimum_diagonal).to_double() /
    recurrent.to_double()
  }
  let lam = if recurrent == 0 {
    0.0
  } else {
    histogram_points(vertical, minimum_vertical).to_double() /
    recurrent.to_double()
  }
  let longest = histogram_longest(diagonal, minimum_diagonal)
  Ok({
    recurrent,
    eligible,
    recurrence_rate: self.rate(),
    determinism: det,
    laminarity: lam,
    mean_diagonal: histogram_mean(diagonal, minimum_diagonal),
    longest_diagonal: longest,
    divergence: if longest == 0 {
      None
    } else {
      Some(1.0 / longest.to_double())
    },
    diagonal_entropy: histogram_entropy(diagonal, minimum_diagonal),
    trapping_time: histogram_mean(vertical, minimum_vertical),
    longest_vertical: histogram_longest(vertical, minimum_vertical),
    vertical_entropy: histogram_entropy(vertical, minimum_vertical),
    mean_return_gap: histogram_mean(white, 1),
  })
}
