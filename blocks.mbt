///|
pub(all) struct BlockDensity {
  row_start : Int32
  column_start : Int32
  row_stop : Int32
  column_stop : Int32
  recurrent : Int32
  eligible : Int32
  rate : Double?
} derive(Debug, Eq)

///|
pub extend BlockDensity with @debug.Debug::{to_repr}

///|
pub extend BlockDensity with Eq::{equal, not_equal}

///|
/// Block output is row-major; partial bottom/right blocks are included.
pub fn Recurrence::block_densities(
  self : Recurrence,
  rows_per_block : Int32,
  cols_per_block : Int32,
) -> Result[Array[BlockDensity], RqaError] {
  if rows_per_block < 1 ||
    cols_per_block < 1 ||
    rows_per_block > 4096 ||
    cols_per_block > 4096 {
    return Err(Invalid("block dimensions"))
  }
  let row_blocks = (self.height - 1) / rows_per_block + 1
  let col_blocks = (self.width - 1) / cols_per_block + 1
  let result : Array[BlockDensity] = []
  for bi in 0..<row_blocks {
    let row_start = bi * rows_per_block
    let row_stop = (row_start + rows_per_block).min(self.height)
    for bj in 0..<col_blocks {
      let column_start = bj * cols_per_block
      let column_stop = (column_start + cols_per_block).min(self.width)
      let mut recurrent = 0
      let mut eligible = 0
      for i in row_start..<row_stop {
        for j in column_start..<column_stop {
          let p = i * self.width + j
          if self.mask[p] {
            eligible += 1
            if self.bits[p] {
              recurrent += 1
            }
          }
        }
      }
      result.push({
        row_start,
        column_start,
        row_stop,
        column_stop,
        recurrent,
        eligible,
        rate: if eligible == 0 {
          None
        } else {
          Some(recurrent.to_double() / eligible.to_double())
        },
      })
    }
  }
  Ok(result)
}

///|
/// Extract a rectangular region without reinterpreting the time origin or mask.
pub fn Recurrence::crop(
  self : Recurrence,
  row : Int32,
  col : Int32,
  height : Int32,
  width : Int32,
) -> Result[Recurrence, RqaError] {
  if row < 0 ||
    col < 0 ||
    height < 1 ||
    width < 1 ||
    row >= self.height ||
    col >= self.width ||
    height > self.height - row ||
    width > self.width - col {
    return Err(Invalid("recurrence crop"))
  }
  Ok({
    height,
    width,
    bits: Array::makei(height * width, fn(p) {
      self.bits[(row + p / width) * self.width + col + p % width]
    }),
    mask: Array::makei(height * width, fn(p) {
      self.mask[(row + p / width) * self.width + col + p % width]
    }),
  })
}
