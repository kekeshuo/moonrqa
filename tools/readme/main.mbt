///|
fn main {
  let t = @rqa.embed([0.0, 1.0, 0.0, 1.0, 0.0], 2, 1).unwrap()
  let r = @rqa.recurrence(t, 0.0, @rqa.Chebyshev, 0, 16).unwrap()
  let q = r.quantify(2, 2).unwrap()
  println(q.to_json().stringify())

  assert_eq(r.counts(), (4, 12)) catch {
    _ => abort("README counts")
  }
  assert_eq(q.determinism, 1.0) catch {
    _ => abort("README DET")
  }
  let t = @rqa.trajectory_csv("x,y\n0,1\n1,0\n0,1\n", true).unwrap()
  let scaled = t.standardize().unwrap()
  let chosen = @rqa.recurrence_at_rate(scaled, 0.4, @rqa.Euclidean, 0, 9).unwrap()
  let summary = chosen.matrix.quantify(2, 2).unwrap()
  let svg = chosen.matrix.to_svg(8, "观测状态", 9).unwrap()
  ignore(summary)
  ignore(svg)
  let a = @rqa.embed([0.0, 1.0, 2.0], 1, 1).unwrap()
  let b = @rqa.embed([9.0, 0.0, 1.0, 2.0], 1, 1).unwrap()
  let cross = @rqa.cross_recurrence(a, b, 0.0, @rqa.Chebyshev, 12).unwrap()
  let profile = cross.lag_profile(-3, 3).unwrap()
  let best = @rqa.best_lag(profile) // Some(1)
  ignore(best)

  assert_eq(best, Some(1)) catch {
    _ => abort("README lag")
  }
}
