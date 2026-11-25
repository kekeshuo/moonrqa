///|
#derive(Debug, Eq)
pub(all) struct Agreement {
  both : Int32
  only_first : Int32
  only_second : Int32
  neither : Int32
  common_eligible : Int32
  jaccard : Double?
  first_given_second : Double?
  second_given_first : Double?
}

///|
pub extend Agreement with @debug.Debug::{to_repr}

///|
pub extend Agreement with Eq::{equal, not_equal}

///|
/// Compare only cells eligible in both matrices. Empty unions have undefined Jaccard.
/// These are descriptive conditional fractions, not significance or causality tests.
pub fn recurrence_agreement(
  first : Recurrence,
  second : Recurrence,
) -> Result[Agreement, RqaError] {
  if first.shape() != second.shape() {
    return Err(Invalid("agreement shape mismatch"))
  }
  let mut both = 0
  let mut only_first = 0
  let mut only_second = 0
  let mut neither = 0
  for p in 0..<first.bits.length() {
    if !first.mask[p] || !second.mask[p] {
      continue
    }
    if first.bits[p] && second.bits[p] {
      both += 1
    } else if first.bits[p] {
      only_first += 1
    } else if second.bits[p] {
      only_second += 1
    } else {
      neither += 1
    }
  }
  let union = both + only_first + only_second
  let first_count = both + only_first
  let second_count = both + only_second
  Ok({
    both,
    only_first,
    only_second,
    neither,
    common_eligible: union + neither,
    jaccard: if union == 0 {
      None
    } else {
      Some(both.to_double() / union.to_double())
    },
    first_given_second: if second_count == 0 {
      None
    } else {
      Some(both.to_double() / second_count.to_double())
    },
    second_given_first: if first_count == 0 {
      None
    } else {
      Some(both.to_double() / first_count.to_double())
    },
  })
}

///|
/// Or-combination for alternate recurrence criteria; common eligibility is still required.
pub fn union_recurrence(
  matrices : Array[Recurrence],
) -> Result[Recurrence, RqaError] {
  if matrices.length() < 1 || matrices.length() > 64 {
    return Err(Invalid("union matrix count"))
  }
  let first = matrices[0]
  let bits = Array::make(first.bits.length(), false)
  let mask = first.mask.copy()
  for r in matrices {
    if r.shape() != first.shape() {
      return Err(Invalid("union shape mismatch"))
    }
    for p in 0..<bits.length() {
      mask[p] = mask[p] && r.mask[p]
      bits[p] = mask[p] && (bits[p] || r.bits[p])
    }
  }
  Ok({ height: first.height, width: first.width, bits, mask, })
}
