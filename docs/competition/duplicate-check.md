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
