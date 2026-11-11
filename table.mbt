///|
fn csv_option(value : Double?) -> String {
  match value {
    None => ""
    Some(x) => x.to_string()
  }
}

///|
fn summary_columns(q : RqaSummary) -> String {
  "\{q.recurrent},\{q.eligible},\{csv_option(q.recurrence_rate)},\{q.determinism},\{q.laminarity},\{csv_option(q.mean_diagonal)},\{q.longest_diagonal},\{csv_option(q.divergence)},\{q.diagonal_entropy},\{csv_option(q.trapping_time)},\{q.longest_vertical},\{q.vertical_entropy},\{csv_option(q.mean_return_gap)}"
}

///|
fn summary_header() -> String {
  "recurrent,eligible,recurrence_rate,determinism,laminarity,mean_diagonal,longest_diagonal,divergence,diagonal_entropy,trapping_time,longest_vertical,vertical_entropy,mean_return_gap"
}

///|
/// Numeric-only tables do not accept user-controlled formulas or field labels.
pub fn windows_csv(windows : Array[WindowSummary]) -> Result[String, RqaError] {
  if windows.length() > 4096 {
    return Err(Limit("window report rows"))
  }
  let out = StringBuilder()
  out.write_string("start,stop,\{summary_header()}\n")
  for window in windows {
    match window.summary.validate() {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    if window.start < 0 || window.stop <= window.start || window.stop > 4096 {
      return Err(Invalid("window report positions"))
    }
    out.write_string(
      "\{window.start},\{window.stop},\{summary_columns(window.summary)}\n",
    )
  }
  Ok(out.to_string())
}

///|
pub fn thresholds_csv(
  scan : Array[ThresholdSummary],
) -> Result[String, RqaError] {
  if scan.length() > 256 {
    return Err(Limit("threshold report rows"))
  }
  let out = StringBuilder()
  out.write_string("threshold,\{summary_header()}\n")
  for row in scan {
    match row.summary.validate() {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    if !finite(row.threshold) || row.threshold < 0.0 {
      return Err(Invalid("threshold report value"))
    }
    out.write_string("\{row.threshold},\{summary_columns(row.summary)}\n")
  }
  Ok(out.to_string())
}

///|
pub fn lags_csv(profile : Array[LagPoint]) -> Result[String, RqaError] {
  if profile.length() > 8193 {
    return Err(Limit("lag report rows"))
  }
  let out = StringBuilder()
  out.write_string("lag,recurrent,eligible,rate\n")
  for row in profile {
    if row.lag < -4096 ||
      row.lag > 4096 ||
      row.recurrent < 0 ||
      row.eligible < row.recurrent ||
      row.eligible > 4096 {
      return Err(Invalid("lag report counts"))
    }
    // Recompute ratio to avoid trusting externally constructed summary fields.
    let rate = if row.eligible == 0 {
      None
    } else {
      Some(row.recurrent.to_double() / row.eligible.to_double())
    }
    out.write_string(
      "\{row.lag},\{row.recurrent},\{row.eligible},\{csv_option(rate)}\n",
    )
  }
  Ok(out.to_string())
}
