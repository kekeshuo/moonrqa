///|
/// Select coordinates in caller order, including repeated coordinates.
pub fn Trajectory::select_dimensions(
  self : Trajectory,
  indices : Array[Int32],
) -> Result[Trajectory, RqaError] {
  if indices.length() < 1 || indices.length() > 64 {
    return Err(Limit("selected dimensions"))
  }
  for k in indices {
    if k < 0 || k >= self.dimensions {
      return Err(Invalid("selected coordinate index"))
    }
  }
  let dimensions = indices.length()
  Ok({
    samples: self.samples,
    dimensions,
    values: Array::makei(self.samples * dimensions, fn(p) {
      self.values[p / dimensions * self.dimensions + indices[p % dimensions]]
    }),
  })
}

///|
/// Sample positions offset, offset+stride, ... without interpolating observations.
pub fn Trajectory::decimate(
  self : Trajectory,
  stride : Int32,
  offset : Int32,
) -> Result[Trajectory, RqaError] {
  if stride < 1 || stride > 4096 || offset < 0 || offset >= self.samples {
    return Err(Invalid("decimation stride/offset"))
  }
  let samples = (self.samples - 1 - offset) / stride + 1
  Ok({
    samples,
    dimensions: self.dimensions,
    values: Array::makei(samples * self.dimensions, fn(p) {
      self.values[(offset + p / self.dimensions * stride) * self.dimensions +
      p % self.dimensions]
    }),
  })
}

///|
/// Remove a least-squares line against integer sample index, independently per coordinate.
/// This is preprocessing, not a forecast. The returned trajectory owns its buffer.
pub fn Trajectory::detrend(self : Trajectory) -> Result[Trajectory, RqaError] {
  let output = self.values.copy()
  let center = (self.samples - 1).to_double() / 2.0
  let mut xx = 0.0
  for i in 0..<self.samples {
    let x = i.to_double() - center
    xx += x * x
  }
  for k in 0..<self.dimensions {
    let anchor = self.values[k]
    let mut magnitude = 0.0
    for i in 0..<self.samples {
      magnitude = magnitude.max(
        (self.values[i * self.dimensions + k] - anchor).abs(),
      )
    }
    if magnitude == 0.0 {
      for i in 0..<self.samples {
        output[i * self.dimensions + k] = 0.0
      }
      continue
    }
    let mut mean = 0.0
    for i in 0..<self.samples {
      mean += self.values[i * self.dimensions + k] / self.samples.to_double()
    }
    let mut xy = 0.0
    for i in 0..<self.samples {
      xy += (i.to_double() - center) *
        (self.values[i * self.dimensions + k] - mean)
    }
    let slope = if xx == 0.0 { 0.0 } else { xy / xx }
    for i in 0..<self.samples {
      let value = self.values[i * self.dimensions + k] -
        mean -
        slope * (i.to_double() - center)
      if !valid_number(value) {
        return Err(Numeric("detrending exceeds coordinate range"))
      }
      output[i * self.dimensions + k] = value
    }
  }
  Ok({ samples: self.samples, dimensions: self.dimensions, values: output, })
}
