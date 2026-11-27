# 版本记录

## 0.1.4 — 2026-11-27

- 修复非恒定次正规数轨迹去趋势时均值下溢造成的伪残差；以平移、二次幂缩放的坐标拟合，保留既有线性数据行为。
- SVG 标题严格按 XML 1.0 字符范围验证，拒绝 U+FFFE/U+FFFF 等非法字符，保留中文和合法补充平面字符。
- 新增三个回归测试，覆盖极小线性/非线性数据、大偏移数据及 XML 字符边界；公共 API 与依赖保持不变。

## 0.1.3 — 2026-11-26

- 修复中文 README 安装命令仍指定旧版的问题，使版本说明、安装命令与模块版本一致。
- 增加 CI 文档版本检查；工具链与库 API 保持不变。

## 0.1.2 — 2026-11-26

- CI now asserts exact versions for `moon 0.1.20261119`, `moonc 0.10.22+124d61d05`, and `moonrun 0.1.20261119` on every target.
- Clarified that these are the project CI toolchain versions; the MoonCakes public manifest does not expose the server-side compiler version.
- No library API or algorithm changes.

## 0.1.1 — 2026-11-25

- Fixed population standardization underflow for minimum subnormal Double values and constant coordinates; detrending now zeros constant subnormal coordinates.
- Added five numerical regression tests covering subnormal, mixed-dimension, close-large, and single-sample inputs.
- Updated derived-trait syntax and CI pin for MoonBit 0.10.22+124d61d05 without changing the public API.

## 0.1.0 — 2026-11-11

首次发布：有限轨迹、前向嵌入与预处理，三种距离，自／交叉／联合递归，排除掩码，最大线直方图和有界回返间隔，RQA 摘要、目标率阈值、滞后／窗口／阈值扫描、矩形裁剪与分块密度、CSV／JSON 及静态 SVG。附三个完整工作流、25 项测试与独立枚举预言机。
