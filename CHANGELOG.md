# 版本记录

## 0.1.1 — 2026-11-25

- Fixed population standardization underflow for minimum subnormal Double values and constant coordinates; detrending now zeros constant subnormal coordinates.
- Added five numerical regression tests covering subnormal, mixed-dimension, close-large, and single-sample inputs.
- Updated derived-trait syntax and CI pin for MoonBit 0.10.22+124d61d05 without changing the public API.

## 0.1.0 — 2026-11-11

首次发布：有限轨迹、前向嵌入与预处理，三种距离，自／交叉／联合递归，排除掩码，最大线直方图和有界回返间隔，RQA 摘要、目标率阈值、滞后／窗口／阈值扫描、矩形裁剪与分块密度、CSV／JSON 及静态 SVG。附三个完整工作流、25 项测试与独立枚举预言机。
