///|
/// Forward delay coordinates: row i contains x[i + k*delay].
pub fn embed(
  series : Array[Double],
  dimension : Int32,
  delay : Int32,
) -> Result[Trajectory, RqaError] {
  if dimension < 1 || dimension > 64 || delay < 1 || delay > 4096 {
    return Err(Invalid("embedding dimension/delay"))
  }
  if series.length() > 262144 {
    return Err(Limit("embedding input"))
  }
  for x in series {
    if !valid_number(x) {
      return Err(Numeric("embedding observation"))
    }
  }
  let span = (dimension - 1) * delay
  if span >= series.length() {
    return Err(Invalid("insufficient embedding observations"))
  }
  let n = series.length() - span
  if n > 4096 {
    return Err(Limit("embedded samples"))
  }
  let values = Array::makei(n * dimension, fn(p) {
    series[p / dimension + p % dimension * delay]
  })
  Ok({ samples: n, dimensions: dimension, values, })
}

///|
pub fn Trajectory::slice(
  self : Trajectory,
  start : Int32,
  length : Int32,
) -> Result[Trajectory, RqaError] {
  if start < 0 ||
    length < 1 ||
    start > self.samples ||
    length > self.samples - start {
    return Err(Invalid("trajectory slice"))
  }
  Ok({
    samples: length,
    dimensions: self.dimensions,
    values: Array::makei(length * self.dimensions, fn(k) {
      self.values[start * self.dimensions + k]
    }),
  })
}

///|
/// Population z-scaling; constant coordinates map to zero.
pub fn Trajectory::standardize(
  self : Trajectory,
) -> Result[Trajectory, RqaError] {
  let output = self.values.copy()
  for k in 0..<self.dimensions {
    // Center first, then scale deltas to preserve subnormals and close large
    // coordinates without overflowing or erasing their variation.
    let anchor = self.values[k]
    let mut scale = 0.0
    for i in 0..<self.samples {
      scale = scale.max((self.values[i * self.dimensions + k] - anchor).abs())
    }
    let mut mean = 0.0
    if scale > 0.0 {
      for i in 0..<self.samples {
        mean += (self.values[i * self.dimensions + k] - anchor) /
          scale /
          self.samples.to_double()
      }
    }
    let mut variance = 0.0
    if scale > 0.0 {
      for i in 0..<self.samples {
        let x = (self.values[i * self.dimensions + k] - anchor) / scale - mean
        variance += x * x / self.samples.to_double()
      }
    }
    let sd = variance.sqrt()
    for i in 0..<self.samples {
      output[i * self.dimensions + k] = if scale == 0.0 {
        0.0
      } else {
        ((self.values[i * self.dimensions + k] - anchor) / scale - mean) / sd
      }
    }
  }
  Ok({ samples: self.samples, dimensions: self.dimensions, values: output, })
}
