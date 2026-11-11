# 依赖与参考边界

- **MoonBit 官方 core**：随固定工具链提供，使用 debug、math、string、json 及 builtin；其代码没有复制到仓库。core 项目许可证为 Apache-2.0，参见 https://github.com/moonbitlang/core 。
- **pyunicorn**：https://github.com/pik-copan/pyunicorn ，BSD-3-Clause。研发时阅读 `timeseries/recurrence_plot.py` 的指标定义及许可证，作为行为和公式基线。本项目未移植、复制其源码或测试，不声称 API／默认参数／所有统计约定等同。尤其排除掩码、空集、白间隔删失和目标率并列规则按本项目文档定义。
- **Marwan, Romano, Thiel, Kurths (2007)**，Recurrence plots for the analysis of complex systems，Physics Reports 438，DOI 10.1016/j.physrep.2006.11.001。作为 RQA 方法背景，没有复制论文文字、图表或数据。

实现、示例信号和 Python 枚举预言机在本项目中独立编写。例子全部为明确的合成输入，不包含患者、设备用户或私人测量数据。本项目 MIT 许可仅适用于本仓库作品，不重新许可外部依赖或文献。
