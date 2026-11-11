///|
/// Numeric CSV dialect: comma delimiter, optional first header, LF/CRLF.
/// Quotes, missing cells and blank records are rejected; one trailing newline is allowed.
pub fn trajectory_csv(
  text : String,
  header : Bool,
) -> Result[Trajectory, RqaError] {
  if text.length() > 2097152 {
    return Err(Limit("CSV text size"))
  }
  let lines = text.split("\n").to_array()
  if lines.length() > 0 && lines[lines.length() - 1].length() == 0 {
    ignore(lines.pop())
  }
  let first = if header { 1 } else { 0 }
  if lines.length() <= first || lines.length() - first > 4096 {
    return Err(Limit("CSV data rows"))
  }
  let rows : Array[Array[Double]] = []
  let mut width = 0
  if header {
    let fields = lines[0].trim().split(",").to_array()
    width = fields.length()
    for field in fields {
      let clean = field.trim()
      if clean.length() == 0 || clean.contains("\"") {
        return Err(Invalid("CSV header field"))
      }
    }
  }
  for line in first..<lines.length() {
    let clean = lines[line].trim()
    if clean.length() == 0 {
      return Err(Invalid("CSV blank record at line \{line+1}"))
    }
    let fields = clean.split(",").to_array()
    if width == 0 {
      width = fields.length()
    }
    if width < 1 || width > 64 || fields.length() != width {
      return Err(Invalid("CSV width at line \{line+1}"))
    }
    let row : Array[Double] = []
    for field in fields {
      let token = field.trim()
      if token.length() == 0 || token.contains("\"") {
        return Err(Invalid("CSV numeric field at line \{line+1}"))
      }
      let value = @string.parse_double(token) catch {
        _ => return Err(Invalid("CSV number at line \{line+1}"))
      }
      if !valid_number(value) {
        return Err(Numeric("CSV coordinate at line \{line+1}"))
      }
      row.push(value)
    }
    rows.push(row)
  }
  trajectory(rows)
}

///|
/// Round-trip numeric CSV without a header. Double formatting is locale independent.
pub fn Trajectory::to_csv(self : Trajectory) -> String {
  let out = StringBuilder()
  for i in 0..<self.samples {
    for k in 0..<self.dimensions {
      if k > 0 {
        out.write_string(",")
      }
      out.write_string(self.values[i * self.dimensions + k].to_string())
    }
    out.write_string("\n")
  }
  out.to_string()
}
