# MoonRQA：MoonBit 递归定量分析

MoonRQA 将有限时间序列或多维状态轨迹转换为递归矩阵，计算连续对角线、竖线与有界回返间隔，并输出可复现的统计报告。适合设备信号工程师、时间序列研究者和多传感器系统开发者。这里的 recurrence 指状态空间中的再次邻近；不处理日历重复规则。

本项目是独立实现的通用离线分析库。数学定义参考 RQA 文献与 pyunicorn；不宣称新算法、与 pyunicorn 全接口兼容或适用于临床判断。查询范围与相邻项目差异见[查重记录](docs/competition/duplicate-check.md)。

## 安装与环境

版本 `0.1.3`（完整 MoonBit 工具链精确验证版；不含库 API 变更），模块 `kekeshuo/moonrqa`，MIT 许可。项目固定验证 MoonBit 工具链：`moon 0.1.20261119`、`moonc 0.10.22+124d61d05`、`moonrun 0.1.20261119`（moonc 不低于比赛要求的 `0.10.16`）。GitHub CI 对三个版本均执行精确断言。MoonCakes 的公开包清单不提供服务端编译器版本，因此这里声明的是项目 CI 的验证工具链，不代表 MoonCakes 服务端实际版本。生产库只依赖该工具链的官方 core。CI 在 Ubuntu 24.04 分别检查、构建、测试并运行 wasm-gc、wasm、js、native；JS 需要 Node.js 22，native 需要平台 C 编译器。Windows 没有 C 编译器时仍可使用前三种目标。

在一个空目录初始化消费者，安装精确版本：

```sh
moon new demo
cd demo
moon add kekeshuo/moonrqa@0.1.3
```

在 `moon.pkg` 加入：

```moonbit
import {
  "kekeshuo/moonrqa" @rqa,
}
options("is-main": true)
```

将下面代码保存为 `main.mbt`，删除初始化模板中冲突的示例文件，然后执行 `moon run .`：

```moonbit
fn main {
  let t = @rqa.embed([0.0, 1.0, 0.0, 1.0, 0.0], 2, 1).unwrap()
  let r = @rqa.recurrence(t, 0.0, @rqa.Chebyshev, 0, 16).unwrap()
  let q = r.quantify(2, 2).unwrap()
  println(q.to_json().stringify())
}
```

这里得到 4 个二维嵌入点；12 个可比较位置中 4 个递归，RR 为 `1/3`。对角线长度下限为 2，DET 为 1。示例为了简洁使用 `unwrap`；业务程序应匹配 `Result` 并处理 `Invalid`、`Limit`、`Numeric`。

## 已实现的能力

- 轨迹拥有自己的数据快照；检查非空、矩形、有限坐标和资源上限。支持前向延迟嵌入、切片、坐标投影、抽取、去线性趋势和总体标准差缩放。
- Chebyshev、Manhattan、Euclidean 三种距离；自递归、矩形交叉递归、联合交集及共同可比较域上的并集／一致性分析。
- 独立保存“排除”掩码。三值矩阵中 `-1` 表示排除、`0` 表示可比较但不递归、`1` 表示递归。
- 最长对角线、竖线、横线直方图，以及两次递归之间完整观测到的白色间隔；RR、DET、LAM、均线长、发散度、自然对数熵、捕获时间和平均回返间隔。
- 目标递归率阈值选择（包含相等距离，不拆分并列点）、滞后剖面、完整滑窗分析、阈值敏感性扫描、局部矩形裁剪和分块密度。
- 有界数值 CSV／JSON 输入，参数明确的 JSON 报告，数值 CSV 汇总，静态 SVG 递归图。

完整公开接口见 [pkg.generated.mbti](pkg.generated.mbti)，数据模型和复杂度见[设计说明](docs/architecture.md)。

## 三个可运行工作流

克隆仓库后运行：

```sh
git clone https://github.com/kekeshuo/moonrqa.git
cd moonrqa
moon run examples/signal
moon run examples/regime
moon run examples/coupling
```

1. **设备信号**：工程师读取一列周期电压 CSV，前向嵌入成二维轨迹，生成自递归矩阵、参数化 JSON 统计和 SVG。示例将 SVG 文本作为 JSON 字段输出，调用方可将其写入文件。
2. **区间变化**：研究者读取 JSON 轨迹，分别对常值段和漂移段计算完整窗口 RQA，导出窗口与阈值扫描 CSV，比较 RR 的变化；不输出未经验证的异常概率。
3. **多传感器对齐**：集成程序比较原始与延迟轨迹，计算交叉滞后剖面；按所得滞后显式切片对齐后，输出联合递归摘要和共同可比较域 Jaccard 系数。

Python 3.8 及以上可自动检查三个流程的结构化输出、数值结果及 SVG XML：

```sh
python scripts/verify_workflows.py --target wasm-gc
```

## 核心 API 示例

CSV 是受限的数值方言：逗号分隔、可选首行标题、LF／CRLF、允许末尾一个换行；拒绝引号、空字段、空记录和不等宽行。它不实现完整 RFC 4180。

```moonbit
let t = @rqa.trajectory_csv("x,y\n0,1\n1,0\n0,1\n", true).unwrap()
let scaled = t.standardize().unwrap()
let chosen = @rqa.recurrence_at_rate(scaled, 0.4, @rqa.Euclidean, 0, 9).unwrap()
let summary = chosen.matrix.quantify(2, 2).unwrap()
let svg = chosen.matrix.to_svg(8, "观测状态", 9).unwrap()
ignore(summary)
ignore(svg)
```

`recurrence_at_rate` 在可比较距离中选出达到请求比例的最小观测阈值。包含所有相等距离，因此实际比例可能超过目标；目标 0 选择最小观测距离，也可能有递归点。没有可比较点时返回错误。

```moonbit
let a = @rqa.embed([0.0, 1.0, 2.0], 1, 1).unwrap()
let b = @rqa.embed([9.0, 0.0, 1.0, 2.0], 1, 1).unwrap()
let cross = @rqa.cross_recurrence(a, b, 0.0, @rqa.Chebyshev, 12).unwrap()
let profile = cross.lag_profile(-3, 3).unwrap()
let best = @rqa.best_lag(profile) // Some(1)
ignore(best)
```

正滞后 `k` 比较 `A[i]` 与 `B[i+k]`。并列时先选支持点更多的滞后，再选绝对值更小、最后有符号值更小的滞后；无有效可比较点则返回 `None`。交叉分析不自动推断时钟、采样率、插值或因果关系。

## 统计约定与已知限制

- 阈值判断为 `distance <= threshold`。自递归排除 `abs(i-j) <= theiler`，所以 `theiler=0` 也排除主对角线；交叉矩阵默认不排除任何位置，需要时显式调用 `exclude_band`。
- RR 分母仅包含未排除位置；DET／LAM 分母为全部可比较递归点。无递归点时 DET／LAM 为 0；没有可比较点的 RR、没有合格线的均值／发散度为 `None`，JSON 中表示为 `null`。
- 每条最大连续黑线只计一次；排除位置中断线段。白间隔只统计被两个黑点包围且不含排除位置的竖向间隔，首尾不完整间隔被删失，不是无偏回返时间估计。
- 总体标准化逐坐标处理，常值坐标映射为 0；标准化通过平移并缩放坐标差避免极小非正规数下溢；去趋势会将常值坐标（包括次正规常值）归零；欧氏范数与标准差使用缩放计算，减少小数值平方下溢。计算使用 Double，不提供任意精度或误差区间。
- 每条轨迹至多 4,096 行、64 维，坐标绝对值不超过 `1e100`；矩阵至多 1,048,576 格，且每边至多 4,096。每次分配还受调用方 `max_cells` 约束；不是所有最大行数都能组成最大方阵。
- 目标率选择至多 262,144 格，保存并排序可比较距离；窗口／阈值扫描累计访问至多 16,777,216 格。SVG 至多 65,536 格；数值输入文本至多 2 Mi 个 UTF-16 代码单元。详见[资源与输入边界](docs/security.md)。
- 不支持缺失值插补、不规则时间重采样、GPU、流式无限输入、显著性检验、Lyapunov 指数拟合或医疗解释；发散度只是最长合格对角线长度的倒数。

## 检查、构建与测试

```sh
moon info
moon fmt --check
moon check --deny-warn
moon build --deny-warn
moon test --deny-warn
python scripts/verify_workflows.py --target wasm-gc
python scripts/verify_oracle.py --target wasm-gc
```

使用 `--target wasm-gc`、`wasm`、`js`、`native` 选择后端。CI 覆盖四个后端的 check/build/test、三个完整工作流、独立预言机和格式／接口检查，见 [ci.yml](.github/workflows/ci.yml)。

当前 30 项 MoonBit 测试覆盖正常路径、数值与资源边界、输入所有权、三值掩码、线段端点、统计分母及报告格式。独立 Python 预言机不调用库实现作为预期值：穷举 21,297 个 1×1 至 3×3 的三值矩阵，比较四种直方图及三个下限下的 63,891 份摘要，另验证 384 个轨迹／距离／目标阈值案例。命令会校验样本数并在任何不一致时失败；这是有界正确性证据，不是全输入证明或代码覆盖率百分比。

## 许可、参考与 AI 使用

项目采用 [MIT](LICENSE)。数学行为参考 Marwan 等人的 RQA 综述和 BSD-3-Clause 的 pyunicorn；没有复制其实现或测试素材。依赖、许可边界见 [THIRD_PARTY.md](THIRD_PARTY.md)。本项目使用 AI 辅助调研、实现、测试和文档，具体责任与验证范围见 [AI_USE.md](AI_USE.md)。
