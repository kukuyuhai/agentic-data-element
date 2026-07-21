---
name: dcmm-scoring
description: >-
  按 GB/T 36073-2018（DCMM）对组织在 8 大能力域上打五级分数（初始/受管理/稳健/量化/优化），并输出提升建议。当做能力评估、体系认证准备时使用。
license: Apache-2.0
metadata:
  scope: management
  mounted_by: ["dam-01", "dam-02"]
  standard_ref:
    - "GB/T 36073-2018"
  risk: low
  openclaw:
    emoji: "🏅"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🏅 dcmm-scoring

## When to Use

当出现以下场景时调用本技能：

- **数据管理能力评估**：评估组织当前数据管理成熟度水平
- **DCMM 认证准备**：申请 DCMM 等级认证前的自评估
- **能力提升规划**：识别短板并制定改进路线（配合 `capability-gap-analysis`）
- **年度复盘**：对比不同时期 DCMM 得分变化趋势
- **供应商评估**：评估数据服务供应商的数据管理能力

本技能基于 GB/T 36073-2018《数据管理能力成熟度评估模型（DCMM）》执行标准化评分。

## 工作原则

1. **证据导向**：每个能力项的评分必须有证据支撑（制度文档/系统截图/操作记录），不可凭印象打分
2. **就低不就高**：能力域等级取该域内最低能力项等级——一票低则域低
3. **改进可操作**：提升建议必须具体到行动项（如"建立 XX 制度""部署 XX 工具"），而非泛泛而谈
4. **评分基准统一**：严格按照 GB/T 36073 的等级定义判定，不自行放宽或收紧标准

## DCMM 八大能力域

| 能力域 | 能力项数 | 核心覆盖 |
|--------|---------|---------|
| 数据战略 | 2 | 战略规划、战略实施 |
| 数据治理 | 3 | 治理组织、制度建设、沟通机制 |
| 数据架构 | 3 | 数据模型、元数据、数据分布 |
| 数据应用 | 3 | 数据分析、数据开放、数据洞察 |
| 数据安全 | 2 | 安全策略、安全管理 |
| 数据质量 | 2 | 质量需求、质量检查 |
| 数据标准 | 2 | 业务术语、参考数据 |
| 数据生存周期 | 2 | 数据需求、数据退役 |

## 五级成熟度定义

| 等级 | 名称 | 特征 | 判定要点 |
|------|------|------|---------|
| L1 | 初始级 | 未规范化，依赖个人经验 | 无制度、无流程、无工具 |
| L2 | 受管理级 | 有初步制度和流程 | 有制度但执行不一致，有基本工具 |
| L3 | 稳健级 | 制度化、流程化 | 制度覆盖全、流程稳定、有度量 |
| L4 | 量化管理级 | 数据驱动管理 | 有 KPI 度量、量化分析、持续改进 |
| L5 | 优化级 | 持续创新优化 | 行业标杆、自动优化、创新引领 |

## Inputs

- **评估范围**（string）：评估的组织边界（全公司/某事业部/某团队）
- **能力域选择**（array）：评估哪些能力域（默认全部 8 个）
- **证据材料**（object）：每个能力项的证据列表（制度文档/系统截图/操作记录）
- **自评打分**（object，可选）：用户预填的自评分数

## Outputs

```yaml
assessment_target: "某科技公司数据团队"
assessment_date: "2024-07-21"
overall_level: "L2（受管理级）"
overall_score: 2.375
domain_scores:
  - domain: "数据战略"
    level: "L2"
    score: 2.0
    items:
      - item: "数据战略规划"
        level: "L2"
        evidence: "有年度数据规划但未形成3年战略"
      - item: "数据战略实施"
        level: "L2"
        evidence: "有实施计划但跟踪不到位"
  - domain: "数据治理"
    level: "L2"
    score: 2.0
  - domain: "数据架构"
    level: "L3"
    score: 3.0
    items:
      - item: "元数据管理"
        level: "L3"
        evidence: "已部署元数据管理平台，覆盖率85%"
  - domain: "数据应用"
    level: "L2"
    score: 2.0
  - domain: "数据安全"
    level: "L2"
    score: 2.0
  - domain: "数据质量"
    level: "L1"
    score: 1.5
  - domain: "数据标准"
    level: "L3"
    score: 3.0
  - domain: "数据生存周期"
    level: "L2"
    score: 2.0
gap_analysis:
  weakest_domain: "数据质量"
  current_level: "L1"
  target_level: "L3"
  key_gaps:
    - "缺乏数据质量管理制度"
    - "无定期质量巡检机制"
    - "质量度量指标未建立"
improvement_plan:
  - priority: "高"
    domain: "数据质量"
    action: "制定数据质量管理规范，明确质量指标与检查频率"
    target_level: "L2"
    timeline: "3个月"
  - priority: "高"
    domain: "数据战略"
    action: "制定3年数据战略规划，明确北极星指标"
    target_level: "L3"
    timeline: "6个月"
  - priority: "中"
    domain: "数据安全"
    action: "建立数据分级分类制度，部署数据脱敏工具"
    target_level: "L3"
    timeline: "6个月"
standard_ref: "[GB/T 36073-2018]"
```

## Steps

### 步骤一：确定评估范围

1. 与用户确认评估的组织边界
2. 确定评估的能力域（默认全部 8 个）
3. 收集证据材料清单

### 步骤二：逐域评分

1. 对每个能力域下的能力项逐一评分
2. 评分依据：证据材料对照 GB/T 36073 的等级描述
3. 能力域等级 = 该域内最低能力项等级（就低不就高）
4. 记录每个能力项的评分依据（证据描述）

### 步骤三：计算总体等级

1. 总体等级 = 8 大能力域中的最低等级
2. 总体分数 = 8 大能力域分数的加权平均
3. 输出等级分布图（各域雷达图）

### 步骤四：差距分析

1. 识别最弱能力域（当前等级最低）
2. 与目标等级对比，识别关键差距
3. 如用户未指定目标等级，建议目标等级（通常为当前+1级）

### 步骤五：制定提升计划

1. 按优先级排序改进项（高/中/低）
2. 每个改进项明确：行动内容、目标等级、时间线、责任人
3. 建议配合使用的技能（如数据质量改进 → `dq-6d-check`）

### 步骤六：输出评估报告

1. 输出完整的 DCMM 评估报告
2. 附改进路线图
3. 如需要转交 `capability-gap-analysis` 做详细的能力差距分析

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "我们 DCMM 几级了？" | 引导收集证据，执行八域评分 |
| "数据质量为什么是 L1？" | 展示该域的评分依据，说明 L1 判定理由 |
| "怎么提升到 L3？" | 基于差距分析，输出改进路线图 |
| "认证 DCMM 需要什么准备？" | 说明 DCMM 认证流程和材料要求 |
| "跟上次比有进步吗？" | 对比历史评分，输出变化趋势 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`role/data-asset-planner/capability-gap-analysis`（能力差距分析）、`foundation/dq-6d-check`（数据质量检查）、`management/stakeholder-raci`（治理组织权责）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
