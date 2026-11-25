///|
#derive(Debug, Eq)
pub(all) struct WindowSummary {
  start : Int32
  stop : Int32
  summary : RqaSummary
}

///|
pub extend WindowSummary with @debug.Debug::{to_repr}

///|
pub extend WindowSummary with Eq::{equal, not_equal}

///|
/// Complete windows only; work budget counts all visited square cells.
pub fn window_rqa(
  t : Trajectory,
  size : Int32,
  step : Int32,
  threshold : Double,
  metric : Metric,
  theiler : Int32,
  minimum_diagonal : Int32,
  minimum_vertical : Int32,
  work_budget : Int32,
) -> Result[Array[WindowSummary], RqaError] {
  if size < 1 || size > t.samples || step < 1 || step > 4096 {
    return Err(Invalid("window size/step"))
  }
  if work_budget < 1 || work_budget > 16777216 {
    return Err(Limit("window work budget"))
  }
  let count = (t.samples - size) / step + 1
  if size > 1048576 / size || count > work_budget / (size * size) {
    return Err(Limit("total window cells"))
  }
  // Validate even parameters that a degenerate window might otherwise hide.
  let out : Array[WindowSummary] = []
  for k in 0..<count {
    let start = k * step
    let part = t.slice(start, size).unwrap()
    match recurrence(part, threshold, metric, theiler, size * size) {
      Err(e) => return Err(e)
      Ok(matrix) =>
        match matrix.quantify(minimum_diagonal, minimum_vertical) {
          Err(e) => return Err(e)
          Ok(summary) => out.push({ start, stop: start + size, summary, })
        }
    }
  }
  Ok(out)
}
