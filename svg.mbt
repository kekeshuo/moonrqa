///|
fn xml_text(text : String) -> Result[String, RqaError] {
  if text.length() > 512 {
    return Err(Limit("SVG title length"))
  }
  let out = StringBuilder()
  for ch in text.iter() {
    if ch.to_int() < 32 && ch != '\n' && ch != '\r' && ch != '\t' {
      return Err(Invalid("SVG XML control character"))
    }
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&apos;")
      _ => out.write_char(ch)
    }
  }
  Ok(out.to_string())
}

///|
/// A static SVG document with no active content, external resources or injected markup.
/// Columns are x, rows are y increasing downward. Gray means excluded, white eligible,
/// dark blue recurrent. The budget caps output primitives independently of analysis.
pub fn Recurrence::to_svg(
  self : Recurrence,
  cell_size : Int32,
  title : String,
  max_cells : Int32,
) -> Result[String, RqaError] {
  if cell_size < 1 || cell_size > 32 {
    return Err(Invalid("SVG cell size 1..32"))
  }
  if max_cells < 1 || max_cells > 65536 || self.height > max_cells / self.width {
    return Err(Limit("SVG cell budget <=65536"))
  }
  let escaped = match xml_text(title) {
    Err(e) => return Err(e)
    Ok(s) => s
  }
  let width = self.width * cell_size
  let height = self.height * cell_size
  let out = StringBuilder()
  out.write_string(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\{width}\" height=\"\{height}\" viewBox=\"0 0 \{width} \{height}\" role=\"img\">\n",
  )
  out.write_string("<title>\{escaped}</title>\n")
  out.write_string("<rect width=\"100%\" height=\"100%\" fill=\"#ffffff\"/>\n")
  for i in 0..<self.height {
    for j in 0..<self.width {
      let p = i * self.width + j
      if !self.mask[p] || self.bits[p] {
        let color = if !self.mask[p] { "#cbd5e1" } else { "#163a5f" }
        out.write_string(
          "<rect x=\"\{j*cell_size}\" y=\"\{i*cell_size}\" width=\"\{cell_size}\" height=\"\{cell_size}\" fill=\"\{color}\"/>\n",
        )
      }
    }
  }
  out.write_string("</svg>\n")
  Ok(out.to_string())
}
