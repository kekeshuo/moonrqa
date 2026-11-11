///|
fn main {
  // A sensor integrator measures a delayed stream, explicitly aligns, then compares.
  let reference = @rqa.embed([0.0, 1.0, 2.0, 0.0, 1.0, 2.0], 1, 1).unwrap()
  let delayed = @rqa.embed([9.0, 0.0, 1.0, 2.0, 0.0, 1.0, 2.0], 1, 1).unwrap()
  let cross = @rqa.cross_recurrence(reference, delayed, 0.0, @rqa.Manhattan, 42).unwrap()
  let profile = cross.lag_profile(-2, 2).unwrap()
  let lag = @rqa.best_lag(profile).unwrap()
  let aligned = delayed.slice(lag, reference.len()).unwrap()
  let first = @rqa.recurrence(reference, 0.0, @rqa.Chebyshev, 0, 36).unwrap()
  let second = @rqa.recurrence(aligned, 0.0, @rqa.Chebyshev, 0, 36).unwrap()
  let joint = @rqa.joint_recurrence([first, second]).unwrap()
  let agreement = @rqa.recurrence_agreement(first, second).unwrap()
  println(
    Json::object({
      "workflow": @json.to_json("coupling"),
      "best_lag": @json.to_json(lag),
      "joint": joint.quantify(2, 2).unwrap().to_json(),
      "common_eligible": @json.to_json(agreement.common_eligible),
      "jaccard": @json.to_json(agreement.jaccard.unwrap()),
      "profile_csv": @json.to_json(@rqa.lags_csv(profile).unwrap()),
    }).stringify(),
  )
}
