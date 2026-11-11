///|
pub(all) struct LagPoint {
  lag : Int32
  recurrent : Int32
  eligible : Int32
  rate : Double?
} derive(Debug, Eq)

///|
pub extend LagPoint with @debug.Debug::{to_repr}

///|
pub extend LagPoint with Eq::{equal, not_equal}

///|
/// Positive lag compares A[i] against B[i+lag]; no clock alignment is inferred.
pub fn Recurrence::lag_profile(
  self : Recurrence,
  minimum : Int32,
  maximum : Int32,
) -> Result[Array[LagPoint], RqaError] {
  if minimum > maximum ||
    minimum < -4096 ||
    maximum > 4096 ||
    maximum - minimum > 8192 {
    return Err(Invalid("lag profile range"))
  }
  let out : Array[LagPoint] = []
  for lag = minimum; lag <= maximum; lag = lag + 1 {
    let mut recurrent = 0
    let mut eligible = 0
    for i in 0..<self.height {
      let j = i + lag
      if j >= 0 && j < self.width {
        let p = i * self.width + j
        if self.mask[p] {
          eligible += 1
          if self.bits[p] {
            recurrent += 1
          }
        }
      }
    }
    out.push({
      lag,
      recurrent,
      eligible,
      rate: if eligible == 0 {
        None
      } else {
        Some(recurrent.to_double() / eligible.to_double())
      },
    })
  }
  Ok(out)
}

///|
/// None if every requested lag has no eligible pairs. Ties prefer greater support,
/// then smaller absolute lag, then the smaller signed lag.
pub fn best_lag(profile : Array[LagPoint]) -> Int32? {
  let mut best : LagPoint? = None
  for p in profile {
    if p.lag < -4096 ||
      p.lag > 4096 ||
      p.eligible < 1 ||
      p.eligible > 4096 ||
      p.recurrent < 0 ||
      p.recurrent > p.eligible {
      continue
    }
    guard p.rate is Some(rate) else { continue }
    if !finite(rate) ||
      (rate - p.recurrent.to_double() / p.eligible.to_double()).abs() > 1.0e-12 {
      continue
    }
    match best {
      None => best = Some(p)
      Some(old) => {
        let previous = old.rate.unwrap()
        if rate > previous ||
          (
            rate == previous &&
            (
              p.eligible > old.eligible ||
              (
                p.eligible == old.eligible &&
                (
                  p.lag.abs() < old.lag.abs() ||
                  (p.lag.abs() == old.lag.abs() && p.lag < old.lag)
                )
              )
            )
          ) {
          best = Some(p)
        }
      }
    }
  }
  best.map(fn(x) { x.lag })
}
