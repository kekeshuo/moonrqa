///|
fn optional_nonnegative(x : Double?, maximum : Double) -> Bool {
  match x {
    None => true
    Some(value) => finite(value) && value >= 0.0 && value <= maximum
  }
}

///|
/// Validate externally assembled summaries before exporting numeric tables.
/// This checks domain and internal arithmetic, not provenance or statistical meaning.
pub fn RqaSummary::validate(self : RqaSummary) -> Result[Unit, RqaError] {
  if self.recurrent < 0 ||
    self.eligible < self.recurrent ||
    self.eligible > 1048576 {
    return Err(Invalid("summary counts"))
  }
  let expected = if self.eligible == 0 {
    None
  } else {
    Some(self.recurrent.to_double() / self.eligible.to_double())
  }
  match (self.recurrence_rate, expected) {
    (None, None) => ()
    (Some(a), Some(b)) =>
      if !finite(a) || (a - b).abs() > 1.0e-12 {
        return Err(Invalid("summary recurrence rate"))
      }
    _ => return Err(Invalid("summary undefined recurrence rate"))
  }
  for fraction in [self.determinism, self.laminarity] {
    if !finite(fraction) || fraction < 0.0 || fraction > 1.0 {
      return Err(Invalid("summary line fraction"))
    }
  }
  for entropy in [self.diagonal_entropy, self.vertical_entropy] {
    if !finite(entropy) || entropy < 0.0 || entropy > @math.ln(4096.0) + 1.0e-12 {
      return Err(Invalid("summary entropy"))
    }
  }
  if self.longest_diagonal < 0 ||
    self.longest_diagonal > 4096 ||
    self.longest_vertical < 0 ||
    self.longest_vertical > 4096 {
    return Err(Invalid("summary longest line"))
  }
  if !optional_nonnegative(self.mean_diagonal, 4096.0) ||
    !optional_nonnegative(self.trapping_time, 4096.0) ||
    !optional_nonnegative(self.mean_return_gap, 4096.0) ||
    !optional_nonnegative(self.divergence, 1.0) {
    return Err(Invalid("summary mean or divergence"))
  }
  match (self.mean_diagonal, self.divergence) {
    (None, None) =>
      if self.longest_diagonal != 0 {
        return Err(Invalid("summary missing diagonal mean"))
      }
    (Some(mean), Some(divergence)) =>
      if self.longest_diagonal < 1 ||
        mean < 1.0 ||
        mean > self.longest_diagonal.to_double() ||
        (divergence - 1.0 / self.longest_diagonal.to_double()).abs() > 1.0e-12 {
        return Err(Invalid("summary diagonal consistency"))
      }
    _ => return Err(Invalid("summary diagonal presence"))
  }
  match self.trapping_time {
    None =>
      if self.longest_vertical != 0 {
        return Err(Invalid("summary missing vertical mean"))
      }
    Some(mean) =>
      if mean < 1.0 || mean > self.longest_vertical.to_double() {
        return Err(Invalid("summary vertical consistency"))
      }
  }
  if self.recurrent == 0 &&
    (
      self.determinism != 0.0 ||
      self.laminarity != 0.0 ||
      self.longest_diagonal != 0 ||
      self.longest_vertical != 0
    ) {
    return Err(Invalid("summary empty recurrence consistency"))
  }
  Ok(())
}
