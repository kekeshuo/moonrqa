///|
/// Typed, deterministic failures. No partial results are returned.
#derive(Debug, Eq)
pub(all) enum RqaError {
  Invalid(String)
  Limit(String)
  Numeric(String)
}

///|
/// Distance between finite state vectors.
#derive(Debug, Eq)
pub(all) enum Metric {
  Chebyshev
  Manhattan
  Euclidean
}

///|
/// Hard implementation ceilings; caller budgets can only tighten them.
fn finite(x : Double) -> Bool {
  !x.is_nan() && !x.is_inf()
}

///|
fn valid_number(x : Double) -> Bool {
  finite(x) && x.abs() <= 1.0e100
}

///|
/// Owns a row-major snapshot; mutation of inputs cannot change analysis.
#derive(Debug, Eq)
pub struct Trajectory {
  samples : Int32
  dimensions : Int32
  values : Array[Double]
}

///|
pub fn trajectory(rows : Array[Array[Double]]) -> Result[Trajectory, RqaError] {
  if rows.length() == 0 || rows.length() > 4096 {
    return Err(Limit("trajectory samples must be 1..4096"))
  }
  let d = rows[0].length()
  if d == 0 || d > 64 {
    return Err(Limit("dimensions must be 1..64"))
  }
  let values : Array[Double] = []
  for row in rows {
    if row.length() != d {
      return Err(Invalid("ragged trajectory"))
    }
    for x in row {
      if !valid_number(x) {
        return Err(Numeric("coordinate must be finite and abs <= 1e100"))
      }
      values.push(x)
    }
  }
  Ok({ samples: rows.length(), dimensions: d, values, })
}

///|
pub fn Trajectory::len(self : Trajectory) -> Int32 {
  self.samples
}

///|
pub fn Trajectory::dimension(self : Trajectory) -> Int32 {
  self.dimensions
}

///|
pub fn Trajectory::rows(self : Trajectory) -> Array[Array[Double]] {
  Array::makei(self.samples, fn(i) {
    Array::makei(self.dimensions, fn(k) { self.values[i * self.dimensions + k] })
  })
}

///|
pub fn Trajectory::point(
  self : Trajectory,
  i : Int32,
) -> Result[Array[Double], RqaError] {
  if i < 0 || i >= self.samples {
    return Err(Invalid("sample index"))
  }
  Ok(
    Array::makei(self.dimensions, fn(k) { self.values[i * self.dimensions + k] }),
  )
}

///|
pub extend RqaError with @debug.Debug::{to_repr}

///|
pub extend RqaError with Eq::{equal, not_equal}

///|
pub extend Metric with @debug.Debug::{to_repr}

///|
pub extend Metric with Eq::{equal, not_equal}

///|
pub extend Trajectory with @debug.Debug::{to_repr}

///|
pub extend Trajectory with Eq::{equal, not_equal}
