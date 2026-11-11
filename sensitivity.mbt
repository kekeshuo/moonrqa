///|
pub(all) struct ThresholdSummary {
  threshold : Double
  summary : RqaSummary
} derive(Debug, Eq)

///|
pub extend ThresholdSummary with @debug.Debug::{to_repr}

///|
pub extend ThresholdSummary with Eq::{equal, not_equal}

///|
/// Preserves requested order and duplicates; validates the whole request before work.
pub fn threshold_scan(
  t : Trajectory,
  thresholds : Array[Double],
  metric : Metric,
  theiler : Int32,
  minimum_diagonal : Int32,
  minimum_vertical : Int32,
  work_budget : Int32,
) -> Result[Array[ThresholdSummary], RqaError] {
  if thresholds.length() < 1 || thresholds.length() > 256 {
    return Err(Limit("threshold count 1..256"))
  }
  if work_budget < 1 ||
    work_budget > 16777216 ||
    t.samples > 1048576 / t.samples ||
    thresholds.length() > work_budget / (t.samples * t.samples) {
    return Err(Limit("threshold work budget"))
  }
  for threshold in thresholds {
    if !finite(threshold) || threshold < 0.0 {
      return Err(Invalid("scan threshold"))
    }
  }
  let out : Array[ThresholdSummary] = []
  for threshold in thresholds {
    match recurrence(t, threshold, metric, theiler, t.samples * t.samples) {
      Err(e) => return Err(e)
      Ok(r) =>
        match r.quantify(minimum_diagonal, minimum_vertical) {
          Err(e) => return Err(e)
          Ok(summary) => out.push({ threshold, summary, })
        }
    }
  }
  Ok(out)
}
