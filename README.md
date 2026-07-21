# 🏛️ 数据要素产业人才数字员工系统 (Agentic Data Element)

> 基于工信部人才交流中心《数据要素产业人才岗位能力要求》（**T/MIITEC 025-2024**）团体标准，
> 将 17 个数据要素相关岗位转化为可自动化调度的**数字员工（Digital Employees）**角色。

[![Standard](https://img.shields.io/badge/Standard-T%2FMIITEC%20025--2024-blue)](docs/standard-overview.md)
[![Agents](https://img.shields.io/badge/Agents-17-brightgreen)](roster.json)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## 🎯 项目愿景

数据要素市场化配置改革正处于全面深化阶段，数据资产管理与交易的**专业人才缺口巨大**。
本项目通过将 T/MIITEC 025-2024 标准中定义的 17 个岗位的**专业知识、技术技能、工程实践**能力
"人格化"到一组结构化 Markdown 角色文件中，实现三重目标：

1. **对齐标准** ── 每个数字员工角色都严格映射到标准第 5 章的能力要求条目，可追溯、可审计。
2. **即插即用** ── 通过安装脚本一键注入 Claude Code、Cursor、Copilot、通义灵码等主流 AI 编码/办公助手。
3. **可扩展** ── 采用 YAML front-matter + 分层 Markdown 的元数据格式，支持社区共建与企业内定制。

---

## 📚 岗位全景（17 个数字员工）

### 🧭 方向一：数据资产管理（11 人）

| 编号 | 角色 | 关键能力 | 角色文件 |
|:---:|---|---|---|
| DAM-01 | 首席数据官（CDO） | 数据战略、组织治理、跨部门协同 | [agents/data-asset-management/01-chief-data-officer.md](agents/data-asset-management/01-chief-data-officer.md) |
| DAM-02 | 数据资产规划师 | 全生命周期规划、市场调研、路线图 | [agents/data-asset-management/02-data-asset-planner.md](agents/data-asset-management/02-data-asset-planner.md) |
| DAM-03 | 数据资产确权师 | 权属界定、知识产权、合规确权 | [agents/data-asset-management/03-data-asset-registration-specialist.md](agents/data-asset-management/03-data-asset-registration-specialist.md) |
| DAM-04 | 数据资产安全合规师 | 数据分类分级、安全审计、应急响应 | [agents/data-asset-management/04-data-asset-security-compliance.md](agents/data-asset-management/04-data-asset-security-compliance.md) |
| DAM-05 | 数据资产管理运营师 | 日常运营、数据服务、业务对接 | [agents/data-asset-management/05-data-asset-operations.md](agents/data-asset-management/05-data-asset-operations.md) |
| DAM-06 | 数据资产运营规划师 | 战略规划、行业分析、投资评估 | [agents/data-asset-management/06-data-asset-operations-planner.md](agents/data-asset-management/06-data-asset-operations-planner.md) |
| DAM-07 | 数据资产评估计价师 | 价值评估、折旧模型、定价策略 | [agents/data-asset-management/07-data-asset-appraiser.md](agents/data-asset-management/07-data-asset-appraiser.md) |
| DAM-08 | 数据资产入表工程师 | 会计确认、计量披露、财务系统 | [agents/data-asset-management/08-data-asset-accounting-engineer.md](agents/data-asset-management/08-data-asset-accounting-engineer.md) |
| DAM-09 | 数据资产入表保荐师 | 合规审核、入表评估、保荐建议 | [agents/data-asset-management/09-data-asset-sponsor.md](agents/data-asset-management/09-data-asset-sponsor.md) |
| DAM-10 | 数据信用管理师 | 信用体系、风险监测、征信登记 | [agents/data-asset-management/10-data-credit-manager.md](agents/data-asset-management/10-data-credit-manager.md) |
| DAM-11 | 数据信用评价师 | 信用评级、评估模型、报告输出 | [agents/data-asset-management/11-data-credit-appraiser.md](agents/data-asset-management/11-data-credit-appraiser.md) |

### 💱 方向二：数据资产交易（6 人）

| 编号 | 角色 | 关键能力 | 角色文件 |
|:---:|---|---|---|
| DAT-01 | 数据交易规划师 | 产品规划、定价模型、平台运营 | [agents/data-asset-trading/01-data-trading-planner.md](agents/data-asset-trading/01-data-trading-planner.md) |
| DAT-02 | 数据交易安全合规师 | 交易审核、跨境合规、风险控制 | [agents/data-asset-trading/02-data-trading-compliance.md](agents/data-asset-trading/02-data-trading-compliance.md) |
| DAT-03 | 数据交易运营师 | 平台运营、用户体验、KPI 优化 | [agents/data-asset-trading/03-data-trading-operator.md](agents/data-asset-trading/03-data-trading-operator.md) |
| DAT-04 | 数据交易分析师 | 市场分析、数据挖掘、决策支持 | [agents/data-asset-trading/04-data-trading-analyst.md](agents/data-asset-trading/04-data-trading-analyst.md) |
| DAT-05 | 数据交易经纪师 | 交易撮合、趋势预测、量化策略 | [agents/data-asset-trading/05-data-trading-broker.md](agents/data-asset-trading/05-data-trading-broker.md) |
| DAT-06 | 数据产权交易师 | 产权评估、合同法务、纠纷处置 | [agents/data-asset-trading/06-data-property-broker.md](agents/data-asset-trading/06-data-property-broker.md) |

> 完整的机器可读元数据见 [`roster.json`](roster.json)。

---

## 🚀 快速开始

### 方式一：直接引用（推荐入门）

每个 `agents/**.md` 文件都是一个自包含的角色系统提示词，可直接复制/粘贴到 ChatGPT、Claude、
文心一言、通义千问、Kimi、DeepSeek 等对话框中激活对应"数字员工"。

```bash
git clone https://github.com/kukuyuhai/agentic-data-element.git
cd agentic-data-element
cat agents/data-asset-management/07-data-asset-appraiser.md   # 激活数据资产评估计价师
```

### 方式二：批量安装到 AI 编码助手

```bash
# 交互式向导（自动检测已安装工具）
./scripts/install.sh

# 或指定目标工具
./scripts/install.sh --tool claude-code
./scripts/install.sh --tool cursor
./scripts/install.sh --tool copilot
./scripts/install.sh --tool aider

# 按方向选择部分安装
./scripts/install.sh --tool claude-code --direction management
./scripts/install.sh --tool cursor --agent 07-data-asset-appraiser
```

### 方式三：编排为多智能体工作流

```bash
# 生成一个"数据资产入表"标准作业流（SOP）：DAM-03 → DAM-07 → DAM-08 → DAM-09
./scripts/workflow.sh --scenario data-asset-onboarding
```

详见 [`docs/workflows.md`](docs/workflows.md)。

---

## 🏗️ 项目结构

```
agentic-data-element/
├── README.md                       # 项目总览（本文件）
├── LICENSE                         # MIT 许可证
├── CHANGELOG.md                    # 版本变更记录
├── CONTRIBUTING.md                 # 贡献指南
├── roster.json                     # 17 个角色的机器可读元数据
├── agents/                         # 数字员工角色定义
│   ├── data-asset-management/      #   ├─ 数据资产管理方向（11 人）
│   └── data-asset-trading/         #   └─ 数据资产交易方向（6 人）
├── templates/
│   └── agent-template.md           # 新角色开发模板
├── scripts/                        # 安装 / 转换 / 编排脚本
│   ├── install.sh                  #   ├─ 主安装器
│   ├── convert.sh                  #   ├─ 多目标格式转换
│   ├── workflow.sh                 #   └─ 多角色工作流编排
│   └── lib/                        #      公共 shell 函数
├── workflows/                      # 预置多智能体工作流
│   ├── data-asset-onboarding.yaml
│   ├── data-trading-listing.yaml
│   └── data-credit-assessment.yaml
├── docs/
│   ├── standard-overview.md        # 标准概览与条款对应表
│   ├── capability-model.md         # 三维能力模型说明
│   ├── agent-development-guide.md  # 数字员工开发指南
│   ├── evaluation.md               # 能力评价体系（附录 B）
│   └── workflows.md                # 工作流使用手册
└── .github/                        # CI 配置与 issue 模板
    └── workflows/ci.yml
```

---

## 🧬 数字员工能力模型

每个数字员工严格遵循 T/MIITEC 025-2024 第 4 章定义的**三维能力要素**：

```
┌─────────────────────────────────────────────────────────────────┐
│                  数字员工三维能力模型                             │
├──────────────────┬──────────────────┬───────────────────────────┤
│  📚 专业知识     │  🛠️ 技术技能    │  🏗️ 工程实践             │
│                  │                  │                           │
│  · 基础知识      │  · 基本技能      │  · 项目经验               │
│  · 专业知识      │  · 专业技能      │  · 交付案例               │
│                  │                  │                           │
│  评价占比         │  评价占比         │  评价占比                 │
│  初级 70%        │  初级 25%        │  初级  5%                 │
│  中级 50%        │  中级 25%        │  中级 25%                 │
│  高级 20%        │  高级 30%        │  高级 50%                 │
└──────────────────┴──────────────────┴───────────────────────────┘
```

评价等级共 3 级 9 等（初级 1-3、中级 4-6、高级 7-9），详见 [`docs/evaluation.md`](docs/evaluation.md)。

---

## 📖 相关标准与规范

- **主标准**：T/MIITEC 025-2024《数据要素产业人才岗位能力要求》
- **术语引用**：GB/T 40685-2021 信息技术服务 数据资产管理要求
- **能力评估**：GB/T 42129-2022 数据管理能力成熟度评估方法
- **成熟度模型**：GB/T 36073-2018 数据管理能力成熟度评估模型
- **交易评价**：GB/T 37550-2019 电子商务数据资产评价指标体系
- **术语基础**：GB/T 35295-2017 信息技术 大数据 术语

---

## 🛣️ 路线图（Roadmap）

- [x] v0.1 — 17 个标准岗位数字员工首发
- [ ] v0.2 — 预置 6 个跨岗位工作流（数据资产入表、数据产品挂牌、跨境合规等）
- [ ] v0.3 — 提供 MCP Server / Dify / FastGPT / Coze 平台一键部署包
- [ ] v0.4 — 集成能力评价自动化打分（对齐附录 B 权重）
- [ ] v0.5 — 支持"数字员工组织架构图"可视化与虚拟组织编排

---

## 🤲 贡献

欢迎从事数据要素、数据资产、数据交易的从业者共建。请参考 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 📄 许可证

[MIT License](LICENSE) © 2024 agentic-data-element contributors

> 本项目为对 T/MIITEC 025-2024 团体标准的**技术落地开源实现**，标准原文著作权归工业和信息化部人才交流中心所有。
