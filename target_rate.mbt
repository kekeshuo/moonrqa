///|
pub(all) struct RateSelection {
  threshold : Double
  achieved_rate : Double
  requested_rate : Double
  matrix : Recurrence
} derive(Debug, Eq)

///|
pub extend RateSelection with @debug.Debug::{to_repr}

///|
pub extend RateSelection with Eq::{equal, not_equal}

///|
/// Smallest observed distance whose inclusive threshold reaches the target.
/// Ties are never split; zero selects the smallest observed distance, not an empty mask.
pub fn recurrence_at_rate(
  t : Trajectory,
  target : Double,
  metric : Metric,
  theiler : Int32,
  max_cells : Int32,
) -> Result[RateSelection, RqaError] {
  if !finite(target) || target < 0.0 || target > 1.0 {
    return Err(Invalid("target rate"))
  }
  if theiler < 0 || theiler > 4096 {
    return Err(Invalid("Theiler width"))
  }
  if !cell_budget(t.samples, t.samples, max_cells) || max_cells > 262144 {
    return Err(Limit("rate selection budget <=262144"))
  }
  let observed : Array[Double] = []
  for i in 0..<t.samples {
    for j in 0..<t.samples {
      if (i - j).abs() > theiler {
        observed.push(point_distance(t, i, t, j, metric))
      }
    }
  }
  if observed.length() == 0 {
    return Err(Invalid("no eligible rate-selection pair"))
  }
  observed.sort()
  let mut rank = 0
  while rank + 1 < observed.length() &&
        (rank + 1).to_double() / observed.length().to_double() < target {
    rank += 1
  }
  let threshold = observed[rank]
  let matrix = recurrence(t, threshold, metric, theiler, max_cells).unwrap()
  Ok({
    threshold,
    achieved_rate: matrix.rate().unwrap(),
    requested_rate: target,
    matrix,
  })
}
