///|
fn point_distance(
  a : Trajectory,
  i : Int32,
  b : Trajectory,
  j : Int32,
  metric : Metric,
) -> Double {
  let mut total = 0.0
  let mut scale = 0.0
  for k in 0..<a.dimensions {
    let delta = (a.values[i * a.dimensions + k] - b.values[j * b.dimensions + k]).abs()
    match metric {
      Chebyshev => total = total.max(delta)
      Manhattan => total += delta
      Euclidean =>
        if delta > 0.0 {
          if delta > scale {
            let ratio = scale / delta
            total = 1.0 + total * ratio * ratio
            scale = delta
          } else {
            let ratio = delta / scale
            total += ratio * ratio
          }
        }
    }
  }
  match metric {
    Euclidean => scale * total.sqrt()
    _ => total
  }
}

///|
pub fn distance(
  a : Trajectory,
  i : Int32,
  b : Trajectory,
  j : Int32,
  metric : Metric,
) -> Result[Double, RqaError] {
  if a.dimensions != b.dimensions {
    return Err(Invalid("coordinate dimension mismatch"))
  }
  if i < 0 || i >= a.samples || j < 0 || j >= b.samples {
    return Err(Invalid("distance sample index"))
  }
  Ok(point_distance(a, i, b, j, metric))
}

///|
/// Pairwise distance grid; the caller explicitly caps cell allocation.
pub fn distances(
  a : Trajectory,
  b : Trajectory,
  metric : Metric,
  max_cells : Int32,
) -> Result[Array[Array[Double]], RqaError] {
  if a.dimensions != b.dimensions {
    return Err(Invalid("coordinate dimension mismatch"))
  }
  if max_cells < 1 || max_cells > 1048576 || a.samples > max_cells / b.samples {
    return Err(Limit("distance cell budget"))
  }
  Ok(
    Array::makei(a.samples, fn(i) {
      Array::makei(b.samples, fn(j) { point_distance(a, i, b, j, metric) })
    }),
  )
}
