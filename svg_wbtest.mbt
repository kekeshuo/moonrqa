///|
test "SVG distinguishes exclusions and escapes user labels" {
  let r = recurrence_from_rows([[-1, 0, 1]]).unwrap()
  let svg = r.to_svg(4, "<script>&\"", 3).unwrap()
  assert_true(svg.contains("&lt;script&gt;&amp;&quot;"))
  assert_true(!svg.contains("<script>"))
  assert_true(svg.contains("#cbd5e1"))
  assert_true(svg.contains("x=\"8\""))
  assert_true(r.to_svg(4, "safe", 2) is Err(_))
  assert_true(r.to_svg(0, "safe", 3) is Err(_))
}
