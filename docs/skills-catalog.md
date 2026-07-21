# Skills 目录（Skills Catalog）

> 数据要素岗位数字员工的**能力单元清单**：72 个 skill，分为「共用底座」「方向共用」「岗位专用」三层。
> 与角色定义（`agents/*.md`）解耦，可被多个 agent 挂载。

## 1. 设计原则

- **规范优先**：`SKILL.md` 顶部 front-matter 遵循 [Anthropic Agent Skills 规范](https://agentskills.io/specification)——`name` 与目录同名、纯小写 kebab、≤ 64 字符；`description` ≤ 1024 字符，说清 *做什么 + 何时用*。
- **可移植**：基础字段兼容 Anthropic / Claude Code / Cursor；项目专有字段放 `metadata`；OpenClaw 扩展放 `metadata.openclaw`。
- **分层挂载**：foundation 全员挂载，方向共用按需，专用只属本岗——避免 prompt 膨胀（OpenClaw `skills.limits.maxSkillsPromptChars` 默认 18000 char）。
- **溯源可查**：每个 skill 声明 `metadata.standard_ref`，产出末尾自动附标注。

## 2. 目录结构

```
skills/
├── manifest.json             # 机器可读清单（供 install/convert 消费）
├── mount-map.json            # 挂载映射：agent-id → [skill 全名]
├── foundation/               # 10 个 · 全员挂载
│   ├── standard-lookup/SKILL.md
│   ├── regulation-lookup/SKILL.md
│   └── ...
├── management/               # 6 个 · DAM 方向共用
│   ├── asset-catalog-crud/SKILL.md
│   └── ...
├── trading/                  # 5 个 · DAT 方向共用
│   └── ...
└── role/                     # 岗位专用 · **目录名用英文 slug**，与 agents/**/*.md 一致
    ├── chief-data-officer/                    # DAM-01
    │   ├── data-strategy-canvas/SKILL.md
    │   └── ...
    ├── data-asset-registration-specialist/    # DAM-03 ⭐ 确权师
    │   └── ...
    └── ...                   # 每个岗位 2~4 个专用 skill
```

> `mount-map.json` 的 **key 仍为 agent-id**（如 `dam-01`），便于 OpenClaw / 安装器按 id 查找；`value` 中的 skill 全名使用物理路径（如 `role/chief-data-officer/data-strategy-canvas`）。

## 3. Skill front-matter 规范

```yaml
---
name: income-approach-calc              # 必填 · 与目录同名 · 小写 kebab · ≤64
description: >-                         # 必填 · ≤1024 · 说清做什么 + 何时用
  数据资产收益法（DCF）估值计算器。用于 DAM-08 输出《数据资产评估报告》时
  的现金流折现估算，覆盖收入预测、折现率选取、敏感性分析三段计算。
license: Apache-2.0
compatibility: Requires Python 3.10+ and pandas
metadata:                               # 项目专有 · 客户端可安全忽略
  scope: role/data-asset-accounting-engineer   # foundation | management | trading | role/<slug>
  mounted_by: [dam-08]                  # 允许挂载的 agent id 列表（仍用 id）
  standard_ref:                         # 标准/法规溯源
    - "GB/T 42129-2022 §7.2"
    - "T/MIITEC 025-2024 §5.1.8"
  risk: low                             # low | medium | high（涉及财务/合规审慎标 high）
  openclaw:                             # 可选 · OpenClaw 特有字段
    emoji: "💵"
    requires:
      bins: [python3]
allowed-tools: Read Write Bash(python3:*)   # 可选 · 预授权工具（实验性）
---

# income-approach-calc

## When to use
...

## Inputs
...

## Outputs
...

## Steps
...

## References
- `references/dcf-method.md`
- `assets/example.xlsx`
```

## 4. Foundation · 共用底座（10）

**挂载策略：17 个 agent 全员挂载**

| # | Name | Emoji | 能力概述 | 标准溯源 |
|---|---|---|---|---|
| 1 | `standard-lookup` | 📚 | 检索团体/国家标准原文 | T/MIITEC 025-2024, GB/T 40685, DCMM |
| 2 | `regulation-lookup` | ⚖️ | 检索数据相关法规原文 | 数据二十条, 数安法, 个保法, 财会〔2023〕11号 |
| 3 | `citation-attach` | 🔖 | 输出末尾自动附加标准/法规溯源标注 | — |
| 4 | `pii-scan` | 🔍 | 识别个人信息/敏感数据字段 | 个保法, GB/T 43697 |
| 5 | `data-classify` | 🗂️ | 数据分级分类（一般/重要/核心；个人/公共/法人/衍生） | GB/T 43697 |
| 6 | `metadata-extract` | 📋 | 从 DDL / OpenAPI / CSV 抽取结构化元数据 | GB/T 40685 §6 |
| 7 | `dq-6d-check` | ✅ | 数据质量六性检查 | GB/T 36344-2018 |
| 8 | `sql-safe-explain` | 🛡️ | SQL 静态分析、性能提示、注入风险识别 | — |
| 9 | `handoff-router` | 🔀 | 命中他岗职责时输出转交建议卡 | T/MIITEC 025-2024 §5 |
| 10 | `deliverable-templater` | 📐 | 从角色 md 的"交付物模板"段生成骨架 | — |

## 5. Management · 数据资产管理方向共用（6）

**挂载策略：按需挂载给 DAM-* 岗位**

| # | Name | Emoji | 能力概述 | 挂载岗位 |
|---|---|---|---|---|
| 11 | `asset-catalog-crud` | 📇 | 数据资产目录增删改查 | dam-02, dam-05, dam-06 |
| 12 | `dcmm-scoring` | 🏅 | DCMM 五级 8 大能力域打分 | dam-01, dam-02 |
| 13 | `lineage-graph` | 🌳 | 数据血缘图查询/生成 | dam-03, dam-05, dam-08 |
| 14 | `data-domain-mapping` | 🗺️ | 业务域 ↔ 数据域映射 | dam-02, dam-05 |
| 15 | `data-product-canvas` | 🖼️ | 数据产品画布 | dam-02, dam-06 |
| 16 | `stakeholder-raci` | 👥 | 数据角色 RACI 矩阵 | dam-01, dam-02 |

## 6. Trading · 数据资产交易方向共用（5）

**挂载策略：按需挂载给 DAT-* 岗位**

| # | Name | Emoji | 能力概述 | 挂载岗位 |
|---|---|---|---|---|
| 17 | `listing-quality-scorer` | 🎯 | 挂牌产品质量分（完备/合规/可交付） | dat-01, dat-03, dat-05 |
| 18 | `deal-lifecycle-tracker` | 🔄 | 交易 9 步状态机 | dat-05, dat-06 |
| 19 | `kyc-kyb-runner` | 🪪 | KYC/KYB 检查清单 | dat-02, dat-05 |
| 20 | `cross-border-checker` | 🌐 | 数据出境安全评估触发判断 | dat-02, dam-04 |
| 21 | `contract-clause-library` | 📜 | 三权分置合同条款库 | dat-02, dat-05, dat-06 |

## 7. Role · 岗位专用（51）

### 数据资产管理方向

<details open><summary><strong>DAM-01 · 首席数据官</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `data-strategy-canvas` | 🗺️ | 数据战略画布（愿景/目标/关键结果/责任矩阵） |
| `data-roi-model` | 💹 | 数据 ROI 模型（投入-产出-归因） |
| `boardroom-brief` | 🎤 | 董事会数据议题简报（≤2 页） |

</details>

<details><summary><strong>DAM-02 · 数据资产规划师</strong>（2）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `asset-planning-roadmap` | 🛣️ | 3 年数据资产建设路线图 |
| `capability-gap-analysis` | 📊 | 能力差距分析（当前 vs DCMM 目标级） |

</details>

<details open><summary><strong>DAM-03 · 数据资产确权师</strong> ⭐（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `three-rights-analyzer` | ⚖️ | 三权分析（持有/加工使用/产品经营） |
| `evidence-chain-builder` | 🔗 | 证据链构建（来源合法+加工留痕+权属声明） |
| `registration-cert-drafter` | 📜 | 数据资产登记证书草稿 |

</details>

<details><summary><strong>DAM-04 · 数据资产安全合规师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `de-identification-toolkit` | 🎭 | 去标识化工具箱（k-匿名 / 差分隐私） |
| `security-audit-checklist` | 🛡️ | 数据安全审计检查表 |
| `incident-response-playbook` | 🚨 | 数据泄露应急响应剧本 |

</details>

<details><summary><strong>DAM-05 · 数据资产管理运营师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `asset-inventory-workbook` | 📓 | 资产盘点台账 |
| `inventory-diff` | 🔀 | 前后期盘点差异对比 |
| `data-sharing-workflow` | 🤝 | 内部数据共享工作流（申请/审批/发布/审计） |

</details>

<details><summary><strong>DAM-06 · 数据资产运营规划师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `data-product-plan` | 🖼️ | 数据产品季度/年度规划 |
| `pricing-tier-designer` | 💰 | 定价分层设计（订阅/按次/包月） |
| `api-marketplace-config` | 🏪 | API 集市上架配置 |

</details>

<details open><summary><strong>DAM-07 · 数据资产评估计价师</strong> ⭐（4）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `income-approach-calc` | 💵 | 收益法 DCF 计算器 |
| `cost-approach-calc` | 🧮 | 成本法计算器 |
| `market-approach-lookup` | 📊 | 市场法可比交易检索 |
| `valuation-report-drafter` | 📄 | 评估报告草稿 |

</details>

<details open><summary><strong>DAM-08 · 数据资产入表工程师</strong> ⭐（4）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `accounting-treatment-classifier` | 📚 | 会计处理判定（无形资产/存货/长期待摊，财会〔2023〕11 号） |
| `amortization-scheduler` | 📅 | 摊销计划表 |
| `measurement-model-selector` | 📐 | 计量模式选择（历史/重置/公允/可变现净值） |
| `initial-recognition-worksheet` | 📓 | 初始确认工作底稿 |

</details>

<details open><summary><strong>DAM-09 · 数据资产入表保荐师</strong> ⭐（4）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `disclosure-note-drafter` | 📝 | 财务附注披露段 |
| `audit-workpaper-builder` | 📋 | 审计底稿模板 |
| `sponsorship-opinion-letter` | ✍️ | 保荐意见书草稿（面向监管/审计方） |
| `continuous-supervision-checklist` | 🔍 | 持续督导清单（使用量/收益/减值迹象） |

</details>

<details><summary><strong>DAM-10 · 数据信用管理师</strong>（2）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `credit-policy-designer` | ⚖️ | 信用体系政策设计 |
| `credit-red-lines` | 🚩 | 信用风险红线清单 |

</details>

<details><summary><strong>DAM-11 · 数据信用评价师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `credit-scorecard-builder` | 💳 | 信用评分卡构建 |
| `credit-rating-committee` | 🏛️ | 评级委员会流程与异议规则 |
| `credit-report-drafter` | 📄 | 信用评级报告草稿 |

</details>

### 数据资产交易方向

<details><summary><strong>DAT-01 · 数据交易规划师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `exchange-topology-designer` | 🏛️ | 交易所拓扑设计（挂牌/撮合/交割/清算） |
| `listing-category-designer` | 🗂️ | 挂牌品类设计（产品形态 × 领域） |
| `deal-mechanism-designer` | ⚙️ | 交易机制设计（撮合/协议/招标/拍卖） |

</details>

<details><summary><strong>DAT-02 · 数据交易合规师</strong>（2）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `compliance-review-sheet` | ✅ | 合规评审意见书 |
| `breach-response-sop` | 🚨 | 数据泄露应急 SOP |

</details>

<details><summary><strong>DAT-03 · 数据交易运营师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `growth-plan-quarterly` | 📈 | 季度运营计划 |
| `platform-metric-dashboard` | 📊 | 核心指标看板 |
| `campaign-retrospective` | 🎬 | 活动复盘模板 |

</details>

<details><summary><strong>DAT-04 · 数据交易分析师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `gmv-forecast-holt-winters` | 📈 | GMV 预测（Holt-Winters / Prophet） |
| `category-hotspot-detector` | 🔥 | 爆款品类识别 |
| `price-elasticity-model` | 💹 | 价格弹性模型 |

</details>

<details><summary><strong>DAT-05 · 数据交易经纪师</strong>（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `deal-intake-form` | 📝 | 需求 intake 表单 |
| `matching-scorecard` | 🎯 | 供需匹配打分卡 |
| `deal-9steps-checklist` | ✅ | 9 步经纪流程 Checklist |

</details>

<details open><summary><strong>DAT-06 · 数据产权交易师</strong> ⭐（3）</summary>

| Name | Emoji | 能力概述 |
|---|---|---|
| `three-rights-due-diligence` | 🔎 | 三权分置尽调 |
| `deal-structuring-3paths` | 🏗️ | 三条路径结构方案（转让 / 独家许可 / 作价入股） |
| `contract-key-clauses` | 📜 | 关键条款清单 |

</details>

## 8. 挂载分布校验

| 分组 | 岗位数 | 平均 skill 数（Foundation + 方向 + 专用） | 单 agent 峰值 |
|---|---:|---:|---:|
| DAM（11 岗） | 11 | 10 + 2 + 3 ≈ **15** | dam-08 / dam-09 · **~15** |
| DAT（6 岗） | 6 | 10 + 2～3 + 3 ≈ **15～16** | dat-05 · **~17** |
| 核心岗（DAM-03/07/08/09、DAT-06） | 5 | 10 + 1～2 + 3～4 ≈ **14～16** | — |

单 agent 挂载均值 ~15 个 skill × 每 `SKILL.md` 描述控制在 ≤ 300 字 ≈ **≤ 5000 char**，远低于 OpenClaw `maxSkillsPromptChars: 18000` 默认阈值。

## 9. 生成与安装

生成骨架（可幂等重跑）：

```bash
./scripts/gen-skills.sh
# 产出：skills/**/SKILL.md（72 个）+ skills/manifest.json + skills/mount-map.json
```

安装到 OpenClaw 时会自动为每个 agent 注入 `skills:` 字段：

```bash
./install.sh openclaw
# .openclaw/config.json5 中每个 agent 的 skills[] 由 mount-map.json 驱动
```

参考：
- [Anthropic Agent Skills 规范](https://agentskills.io/specification)
- [OpenClaw skill format](https://docs.openclaw.ai/clawhub/skill-format)
- 项目内：[agent-development-guide.md](./agent-development-guide.md)
