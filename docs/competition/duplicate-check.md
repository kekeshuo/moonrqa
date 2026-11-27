# MoonRQA 需求与语义查重（2026-11-11）

按已安装 osc2026-guide 的 Project Research Guide 实际执行 moon search、MoonCakes 精确元数据、GitHub 实际源码与测试检查。研究原始证据保存在仓库外本地，不包含凭据。

## 候选比较与需求门禁
|方向|成熟需求基线|核心用户/任务|结论|
|---|---|---|---|
|系统发育树|Biopython Newick/tree|生物研究、可视化、距离分析|BioSeqs 实际 phylo.mbt 已覆盖，淘汰|
|物料计划|成熟 MRP/BOM 工具|制造、采购、库存管理|moon-mrp@0.3.0 README/lotting_test 已覆盖，淘汰|
|湿空气热力学|PsychroLib/ASHRAE|HVAC、温室、气象|energybalance psychrometrics.mbt 已覆盖，淘汰|
|RQA|pyunicorn、Marwan2007|设备信号、科研、多传感器|有界检索未发现成熟直接替代，入选|

前三方向硬失败，不通过打分弥补。RQA 在广度/用户/复用/低重合/深度/验证/工期/维护各为4/4/5/4/5/5/4/4（满分5）；这是工程选择判断而非客观测量。

RQA 的输入为有限等间隔观测或明确的多维轨迹，处理为状态空间距离阈值与连续线结构统计，输出为矩阵、统计量、滞后/窗口报告；不同于日历 recurrence、运行基准、信号预测或医疗诊断。三个闭环：传感器序列→嵌入→矩阵/DET；双轨迹→交叉/联合矩阵→滞后报告；分段信号→窗口分析→JSON/SVG结果。验收使用独立集合枚举/整数距离 Python 预言机、边界测试和真实消费者，不以代码量代替正确性。

## 实际查询与边界
Moon search 上限100：psychrometric/psychrolib/humid/moist air/wetbulb/dew point/HVAC/ASHRAE/Wagner Whitin/lot sizing/Newick/phylogenetic/recurrence quantification/RQA/recurrence plot/pyunicorn/cross recurrence/Takens/delay embedding/kriging/variogram/rough set/Pawlak/recurrence/nonlinear/time series/Rosenstein/phase space/Theiler/determinism/laminarity。Takens、determinism 等达到100条，不能当作穷尽；RQA零条仅为线索。GitHub repository/code per_page100，recurrence_rate/recurrence_plot/recurrence_matrix/laminarity/Theiler 反搜。宽泛 rqa 有127结果，仅检查前100，实际多为字体/编码数据字符串，不代表无遗漏。检查 moonbitlang/awesome-moonbit 清单和永久登记表全部候选关键词，阅读相关完整指纹。

## 源码能力矩阵
|项目与证据|重合|关键差异与结论|
|---|---|---|
|[hrvkit](https://github.com/zhzh12345678/moonbit-hrvkit)@0.3.0 nonlinear.mbt、nonlinear_test.mbt、接口|标量半径/滞后 recurrence_rate，sample entropy|高度相邻基础运算；没有多维矩阵/线直方图/交叉联合/通用窗口RQA。避免耦合健康指标，独立轨迹模型更适合三类用户|
|[time-series-forecasting](https://github.com/wjhsb1/moonbit-time-series-forecasting)@0.1.0 README、diagnostics.mbt及测试|时间序列/滞后统计|预测与残差诊断，不是递归线结构。最初猜错仓库404，已按公开manifest定位正确仓库|
|[symbit](https://github.com/CAIMEOX/symbit)@0.5.10 src/symdiscrete/recurrences.mbt|recurrence名称|符号序列递推，不是数值相空间邻近关系|
|[moonplot](https://github.com/moonbit-community/moonplot) API|可视化|通用绘图，不是RQA引擎|
|[BioSeqs](https://github.com/paipai-Studio/BioSeqs) phylo.mbt|树领域|直接替代候选，拒绝|
|[moon-mrp](https://github.com/sun-zhao12/moon-mrp) README/lotting_test|物料/批量规则|直接替代候选，拒绝|
|[energybalance](https://github.com/liying-han/moonbit-energybalance) psychrometrics.mbt|热力学公式|直接替代候选，拒绝|

## 参考与独立建设
[pyunicorn recurrence_plot](https://github.com/pik-copan/pyunicorn/blob/master/src/pyunicorn/timeseries/recurrence_plot.py) BSD-3-Clause 为成熟行为基线，阅读定义和许可证，不复制实现或测试。论文 DOI:10.1016/j.physrep.2006.11.001。实现不是算法首创，也不是与 pyunicorn 全API兼容的移植。时间排除带和无结构时的零/None规则须显式定义并测试。源码访问 raw.github 失败后通过账号隔离GitHub只读API成功；没有关闭TLS或修改系统代理。

MoonRecur 的日历规则、MoonBench 的性能统计、MoonConformal 的校准集合、MoonSeqMine 的频繁子序列均不属于本项目输入/模型/输出。选题已在排他锁下重新检查并原子预留。仅声明上述日期/版本/查询范围内未发现成熟直接替代；发布前再次反搜，不保证绝对唯一或官方验收。

## 发布前复查（2026-11-11）

再次执行 GitHub code search（per_page=100）：recurrence quantification、diagonal_histogram、laminarity、cross_recurrence、theiler，均限定 language:MoonBit，返回计数均为 0。再次运行 moon search --limit 100：recurrence quantification 返回 HOL Light 定理证明器；cross recurrence 返回 symbit、prove、moon-certified、loop_invariants_math、moonrand、snn_mbt，其描述分别为符号递推证明、形式验证、随机数与循环神经网络，不属于状态空间 RQA；Theiler、laminarity 无结果。没有将模糊检索或词语命中等同于重复项目。初查已阅读高度相邻 hrvkit 的源码与测试，并保留区别。检索不是穷尽，无法保证未索引项目不存在。

完整功能现已通过三种本地可用运行后端、25 项单元／边界测试及独立穷举：21,297 个三值矩阵、63,891 份摘要和 384 个距离／阈值案例。选题比较的判断已由真实输入、输出和工作流兑现；平台发布结论另由外部验收报告记录。


## 2026-11-27 修复交付前复核

本次是既有 MoonRQA 数值/SVG 边界修复，不更换原选题。重新执行 `moon search`（各 `--limit 100`）：recurrence quantification、recurrence plot、Theiler、laminarity、pyunicorn、cross_recurrence、lag_profile；每组返回 0–6 项，未触及上限。GitHub MoonBit code 检索 recurrence quantification / Theiler / cross_recurrence 返回 0，索引有收录限制，不将零命中视为唯一性证明。

重新读取 hrvkit 的 nonlinear.mbt / nonlinear_test.mbt、time-series-forecasting 的 diagnostics.mbt / diagnostics_test.mbt、symbit 的 src/symdiscrete/recurrences.mbt；仍分别为单变量心率递归比例、预测诊断、符号递推，不替代多维三值掩码、线直方图与交叉/联合RQA工作流。新增关键词邻近结果 [moonbit-ocean-qc](https://github.com/lwq443/moonbit-ocean-qc) 与 [moon-missingness](https://github.com/liuminyuan/moon-missingness) 的 README / 源树分别是海洋质量控制、缺失值诊断插补，不是本项目核心任务。永久注册表 MoonRQA / MoonRecur 等指纹复查：日历规则展开与状态空间递归不属同一问题。

raw GitHub 读取连接被重置后使用官方 contents/tree API 核对真实源码；一个 MoonCakes 邻近包元数据读取超时，源码/测试通过 GitHub 核验。有限记录范围内未确认成熟、维护良好的直接替代；不声称穷尽生态、数学方法原创或获得官方查重认可。
