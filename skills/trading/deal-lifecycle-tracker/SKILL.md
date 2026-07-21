---
name: deal-lifecycle-tracker
description: >-
  数据交易 9 步状态机（intake → matching → compliance → trial → pricing → contract → delivery → acceptance → maintenance），驱动流程推进与卡点提醒。经纪与产权类交易通用。
license: Apache-2.0
metadata:
  scope: trading
  mounted_by: ["dat-05", "dat-06"]
  standard_ref:
    - "T/MIITEC 025-2024 §5.2.5"
  risk: low
  openclaw:
    emoji: "🔄"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🔄 deal-lifecycle-tracker

## When to Use

当出现以下场景时调用本技能：

- **推进单笔交易**全流程时，需要知道当前处于哪个阶段、下一步是什么
- **卡点提醒**：某步骤长时间未推进或缺少必要材料时触发告警
- **交易状态查询**：快速了解某笔交易的完整生命周期状态
- **批量交易管理**：监控多笔交易的整体进度

本技能是数据交易流程的**状态机引擎**，驱动从需求收集到售后维护的 9 步全流程。

## 工作原则

1. **线性推进**：9 个步骤按序推进，不可跳步（除非用户明确要求终止）
2. **卡点感知**：每步设有预期完成时间，超时自动告警
3. **材料校验**：每步进入前校验必要材料是否齐备，不齐备则卡在前一步
4. **可回退**：特殊情况允许回退到前序步骤（如合规审查失败回退到匹配阶段）

## 9 步状态机

```
[1]intake → [2]matching → [3]compliance → [4]trial → [5]pricing
                                                        ↓
[9]maintenance ← [8]acceptance ← [7]delivery ← [6]contract
```

### 步骤详解

| 步骤 | 名称 | 核心动作 | 必要材料 | 预期时长 | 关联技能 |
|------|------|---------|---------|---------|---------|
| 1 | Intake 需求收集 | 收集买方需求，填写 intake 表单 | 需求描述、预算范围 | 1-3天 | `deal-intake-form` |
| 2 | Matching 供需匹配 | 匹配卖方和数据产品，输出推荐清单 | 买方需求、卖方产品库 | 2-5天 | `matching-scorecard` |
| 3 | Compliance 合规审查 | 买卖双方资质审查 + 数据合规检查 | KYC/KYB 结果、合规报告 | 3-7天 | `kyc-kyb-runner`、`cross-border-checker` |
| 4 | Trial 试用验证 | 买方试用数据产品，验证适用性 | 试用数据样本、试用报告 | 5-10天 | — |
| 5 | Pricing 定价协商 | 确定最终价格和交易条款 | 定价方案、成本分析 | 2-5天 | `pricing-tier-designer` |
| 6 | Contract 合同签署 | 起草、审核、签署数据交易合同 | 合同草稿、条款清单 | 5-10天 | `contract-clause-library` |
| 7 | Delivery 交付执行 | 按合同约定交付数据/API/报告 | 交付物、交付确认单 | 1-5天 | — |
| 8 | Acceptance 验收确认 | 买方验收交付物，确认合格 | 验收报告、问题清单 | 2-5天 | — |
| 9 | Maintenance 售后维护 | 持续提供更新、支持、SLA保障 | SLA报告、维护记录 | 持续 | — |

## 卡点规则

| 卡点类型 | 触发条件 | 告警动作 |
|---------|---------|---------|
| 材料缺失 | 进入某步骤但必要材料未齐备 | 阻断推进，提示补充材料 |
| 超时未推进 | 超过预期时长 × 1.5 | 发送提醒，标注为"缓慢" |
| 超时严重 | 超过预期时长 × 3 | 发送告警，标注为"停滞"，建议人工介入 |
| 合规失败 | compliance 步骤未通过 | 阻断推进，回退到 matching 或终止交易 |
| 验收不通过 | acceptance 步骤买方拒绝 | 回退到 delivery，要求重新交付 |

## Inputs

- **交易 ID**（string）：唯一标识某笔交易
- **当前步骤**（enum）：`1_intake` ~ `9_maintenance`
- **操作类型**（enum）：`advance`（推进）/ `query`（查询）/ `regress`（回退）/ `alert`（告警检查）
- **步骤产出物**（object）：当前步骤完成的产出物和材料
- **交易信息**（object）：买卖双方信息、交易标的、金额

## Outputs

```yaml
deal_id: "DEAL-2024-00123"
current_step: "3_compliance"
step_status: "in_progress"
progress: 33.3%
next_step: "4_trial"
next_step_requirements:
  - "合规审查通过"
  - "试用数据样本准备就绪"
materials_check:
  required: ["KYC报告", "KYB报告", "合规审查报告"]
  provided: ["KYC报告", "KYB报告"]
  missing: ["合规审查报告"]
  status: "blocked"
alerts:
  - type: "material_missing"
    message: "合规审查报告尚未提交，无法推进到试用阶段"
    severity: "blocking"
timeline:
  - step: "1_intake"
    status: "completed"
    started: "2024-07-10"
    completed: "2024-07-12"
    duration: "2天"
  - step: "2_matching"
    status: "completed"
    started: "2024-07-12"
    completed: "2024-07-15"
    duration: "3天"
  - step: "3_compliance"
    status: "in_progress"
    started: "2024-07-15"
    expected_complete: "2024-07-22"
    days_elapsed: 6
    days_remaining: 1
```

## Steps

### 推进流程（advance）

1. **校验当前步骤**：确认当前步骤状态为 in_progress
2. **检查材料齐备**：校验当前步骤的必要材料是否全部提交
3. **检查步骤产出**：确认当前步骤的核心产出物已完成
4. **推进到下一步**：如材料齐备，将状态推进到下一步
5. **更新时间线**：记录步骤完成时间和产出物

### 查询流程（query）

1. **定位交易**：按 deal_id 查找交易
2. **输出状态**：当前步骤、进度百分比、时间线
3. **检查卡点**：是否有材料缺失或超时告警
4. **提示下一步**：下一步所需材料和预期时长

### 回退流程（regress）

1. **确认回退原因**：记录回退原因（合规失败/验收不通过等）
2. **校验回退目标**：确认回退到的步骤是合法的前序步骤
3. **执行回退**：更新当前步骤状态
4. **记录回退日志**：保留回退前的产出物和状态

### 告警检查（alert）

1. **遍历所有进行中步骤**：检查是否有超时
2. **检查材料齐备**：进行中步骤是否有缺失材料
3. **输出告警清单**：按严重程度排序

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "这笔交易到哪一步了？" | 执行查询，输出当前步骤和进度 |
| "能推进到下一步吗？" | 检查材料齐备性，齐备则推进 |
| "为什么卡住了？" | 检查卡点，输出缺失材料或超时告警 |
| "合规没过怎么办？" | 执行回退到 matching 或终止交易 |
| "这批交易有卡住的吗？" | 批量检查告警，输出停滞交易清单 |
| "整个流程要多久？" | 列出9步预期时长，总计 21-50 天 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`role/data-trading-broker/deal-intake-form`（需求收集）、`role/data-trading-broker/matching-scorecard`（供需匹配）、`trading/kyc-kyb-runner`（KYC/KYB）、`trading/cross-border-checker`（跨境合规）、`trading/contract-clause-library`（合同条款）、`role/data-trading-broker/deal-9steps-checklist`（9步清单）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
