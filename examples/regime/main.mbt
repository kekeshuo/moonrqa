///|
fn main {
  // A time-series researcher compares stationary and drifting intervals.
  let t = @rqa.trajectory_json("[[0],[0],[0],[0],[1],[2],[3],[4]]").unwrap()
  let windows = @rqa.window_rqa(t, 4, 4, 0.0, @rqa.Euclidean, 0, 2, 2, 32).unwrap()
  let scan = @rqa.threshold_scan(
    t,
    [0.0, 1.0, 4.0],
    @rqa.Euclidean,
    0,
    2,
    2,
    192,
  ).unwrap()
  println(
    Json::object({
      "workflow": @json.to_json("regime"),
      "windows_csv": @json.to_json(@rqa.windows_csv(windows).unwrap()),
      "thresholds_csv": @json.to_json(@rqa.thresholds_csv(scan).unwrap()),
    }).stringify(),
  )
}
