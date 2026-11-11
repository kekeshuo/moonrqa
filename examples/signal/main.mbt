///|
fn main {
  // A signal engineer receives a numeric CSV trace from a data acquisition system.
  let raw = @rqa.trajectory_csv("voltage\n0\n1\n0\n1\n0\n1\n0\n1\n", true).unwrap()
  let series = raw.rows().map(fn(row) { row[0] })
  let embedded = @rqa.embed(series, 2, 1).unwrap()
  let matrix = @rqa.recurrence(embedded, 0.0, @rqa.Chebyshev, 0, 49).unwrap()
  let report = @rqa.analysis_json(embedded, 0.0, @rqa.Chebyshev, 0, 2, 2, 49).unwrap()
  let plot = matrix.to_svg(8, "periodic signal", 49).unwrap()
  println(
    Json::object({
      "workflow": @json.to_json("signal"),
      "report": report,
      "svg": @json.to_json(plot),
    }).stringify(),
  )
}
