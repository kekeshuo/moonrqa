///|
fn nullable_number(value : Double?) -> Json {
  match value {
    None => Json::null()
    Some(x) => @json.to_json(x)
  }
}

///|
/// JSON trajectory interchange is a rectangular array of finite numeric arrays.
pub fn trajectory_json(text : String) -> Result[Trajectory, RqaError] {
  if text.length() > 2097152 {
    return Err(Limit("JSON text size"))
  }
  let json = @json.parse(text, max_nesting_depth=4, reject_duplicate_keys=true) catch {
    _ => return Err(Invalid("trajectory JSON syntax/depth"))
  }
  let rows : Array[Array[Double]] = @json.from_json(json) catch {
    _ => return Err(Invalid("trajectory JSON must be numeric rows"))
  }
  trajectory(rows)
}

///|
pub fn Trajectory::to_json(self : Trajectory) -> Json {
  @json.to_json(self.rows())
}

///|
pub fn Recurrence::to_json(self : Recurrence) -> Json {
  @json.to_json(self.rows())
}

///|
/// Stable named fields; undefined ratios/means become JSON null, never NaN.
pub fn RqaSummary::to_json(self : RqaSummary) -> Json {
  Json::object({
    "recurrent": @json.to_json(self.recurrent),
    "eligible": @json.to_json(self.eligible),
    "recurrence_rate": nullable_number(self.recurrence_rate),
    "determinism": @json.to_json(self.determinism),
    "laminarity": @json.to_json(self.laminarity),
    "mean_diagonal": nullable_number(self.mean_diagonal),
    "longest_diagonal": @json.to_json(self.longest_diagonal),
    "divergence": nullable_number(self.divergence),
    "diagonal_entropy": @json.to_json(self.diagonal_entropy),
    "trapping_time": nullable_number(self.trapping_time),
    "longest_vertical": @json.to_json(self.longest_vertical),
    "vertical_entropy": @json.to_json(self.vertical_entropy),
    "mean_return_gap": nullable_number(self.mean_return_gap),
  })
}

///|
/// A report is explicit about the exclusion and line-length parameters used.
pub fn analysis_json(
  t : Trajectory,
  threshold : Double,
  metric : Metric,
  theiler : Int32,
  minimum_diagonal : Int32,
  minimum_vertical : Int32,
  max_cells : Int32,
) -> Result[Json, RqaError] {
  let r = match recurrence(t, threshold, metric, theiler, max_cells) {
    Err(e) => return Err(e)
    Ok(r) => r
  }
  let q = match r.quantify(minimum_diagonal, minimum_vertical) {
    Err(e) => return Err(e)
    Ok(q) => q
  }
  let name = match metric {
    Chebyshev => "chebyshev"
    Manhattan => "manhattan"
    Euclidean => "euclidean"
  }
  Ok(
    Json::object({
      "schema": @json.to_json("moonrqa/1"),
      "samples": @json.to_json(t.samples),
      "dimensions": @json.to_json(t.dimensions),
      "threshold": @json.to_json(threshold),
      "metric": @json.to_json(name),
      "theiler": @json.to_json(theiler),
      "minimum_diagonal": @json.to_json(minimum_diagonal),
      "minimum_vertical": @json.to_json(minimum_vertical),
      "summary": q.to_json(),
    }),
  )
}
