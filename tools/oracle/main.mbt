///|
fn main {
  for n in 1..<4 {
    for m in 1..<4 {
      let mut cases = 1
      for _ in 0..<(n * m) {
        cases *= 3
      }
      for code in 0..<cases {
        let mut number = code
        let rows = Array::makei(n, fn(_) {
          Array::makei(m, fn(_) {
            let x = number % 3 - 1
            number /= 3
            x
          })
        })
        let r = @rqa.recurrence_from_rows(rows).unwrap()
        let summaries = [1, 2, 4].map(fn(minimum) {
          let q = r.quantify(minimum, minimum).unwrap()
          q.validate().unwrap()
          q.to_json()
        })
        println(
          Json::object({
            "kind": @json.to_json("matrix"),
            "n": @json.to_json(n),
            "m": @json.to_json(m),
            "code": @json.to_json(code),
            "d": @json.to_json(r.diagonal_histogram()),
            "v": @json.to_json(r.vertical_histogram()),
            "h": @json.to_json(r.horizontal_histogram()),
            "w": @json.to_json(r.return_histogram()),
            "q": Json::array(summaries),
          }).stringify(),
        )
      }
    }
  }
  for c in 0..<128 {
    let a = @rqa.trajectory(
      Array::makei(3, fn(i) {
        Array::makei(3, fn(k) {
          ((c * 17 + i * 7 + k * 11) % 19 - 9).to_double() / 4.0
        })
      }),
    ).unwrap()
    let b = @rqa.trajectory(
      Array::makei(4, fn(i) {
        Array::makei(3, fn(k) {
          ((c * 13 + i * 11 + k * 3) % 23 - 11).to_double() / 4.0
        })
      }),
    ).unwrap()
    for
      (index, metric) in [@rqa.Chebyshev, @rqa.Manhattan, @rqa.Euclidean].iter2() {
      let r = @rqa.cross_recurrence(a, b, 2.5, metric, 12).unwrap()
      let target = @rqa.recurrence_at_rate(a, 0.3, metric, 0, 9).unwrap()
      println(
        Json::object({
          "kind": @json.to_json("distance"),
          "case": @json.to_json(c),
          "metric": @json.to_json(index),
          "grid": @json.to_json(@rqa.distances(a, b, metric, 12).unwrap()),
          "cross": r.to_json(),
          "self": @rqa.recurrence(a, 2.5, metric, 0, 9).unwrap().to_json(),
          "threshold": @json.to_json(target.threshold),
          "rate": @json.to_json(target.achieved_rate),
          "target": target.matrix.to_json(),
        }).stringify(),
      )
    }
  }
}
