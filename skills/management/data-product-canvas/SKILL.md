---
name: data-product-canvas
description: >-
  数据产品画布（业务问题 → 数据组合 → 交付形态 → 定价与SLA），一屏产出。当规划新数据产品、上架前评审时使用。
license: Apache-2.0
metadata:
  scope: management
  mounted_by: ["dam-02", "dam-06"]
  standard_ref:
    - "GB/T 40685-2021 §7"
  risk: low
  openclaw:
    emoji: "🖼️"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🖼️ data-product-canvas

## When to Use

当出现以下场景时调用本技能：

- **规划新数据产品**时，需要一屏式梳理产品的核心要素
- **数据产品上架前评审**时，需要检查产品定义是否完整
- **产品迭代规划**时，需要对比当前状态与目标状态
- **向管理层汇报**数据产品组合时，需要结构化呈现

本技能生成"数据产品画布"——一个涵盖从业务问题到交付形态的完整产品定义框架。

## 工作原则

1. **一屏概览**：画布所有核心要素在一页内呈现，便于快速理解全貌
2. **从业务问题出发**：产品画布从"解决什么业务问题"开始，而非从"有什么数据"开始
3. **交付形态明确**：必须定义清晰的数据交付方式（API/数据集/报告/可视化）
4. **定价与SLA联动**：定价策略必须与SLA承诺匹配，不同定价层级对应不同服务等级

## 画布结构（7 大板块）

### 1. 业务问题

```
解决谁的问题？
- 目标用户：（如：风控分析师、营销运营）
- 核心痛点：（如：缺乏实时用户行为数据做风控决策）
- 预期价值：（如：降低欺诈率 15%）
```

### 2. 数据组合

```
用什么数据？
- 核心数据集：（如：用户行为日志、交易记录、设备指纹）
- 辅助数据：（如：第三方黑名单、地理位置库）
- 数据来源：（内部/外部/混合）
- 更新频率：（实时/小时/日）
- 数据质量要求：（完整性 ≥99%、准确性 ≥98%）
```

### 3. 交付形态

```
以什么形式交付？
- 交付方式：□ API  □ 数据集  □ 报告  □ 可视化看板  □ 数据服务
- 交付规格：
  - API：RESTful / GraphQL / 流式推送
  - 数据集：CSV / Parquet / JSON
  - 报告：PDF / Excel / 在线
- 交付频率：实时 / T+1 / 周 / 月
- 交付渠道：数据集市 / API网关 / 邮件 / 平台内嵌
```

### 4. 用户场景

```
怎么用？
- 典型场景1：风控分析师实时调用API做交易反欺诈
- 典型场景2：营销运营每日下载用户画像数据做精准推送
- 使用频率：□ 高频(日)  □ 中频(周)  □ 低频(月)
- 使用规模：QPS / 日调用量 / 月下载量
```

### 5. 定价策略

```
怎么收费？
- 定价模式：□ 订阅  □ 按次  □ 包月  □ 阶梯  □ 免费
- 价格区间：
  - 基础版：¥X/月（基础字段+日更）
  - 专业版：¥Y/月（全字段+实时）
  - 企业版：¥Z/月（定制+SLA保障）
- 成本估算：数据获取成本 + 计算/存储成本 + 运营成本
- 毛利目标：≥40%
```

### 6. SLA 承诺

```
承诺什么？
- 可用性：99.5% / 99.9% / 99.99%
- 响应时间：API P95 < 200ms
- 数据时效性：T+1 / T+0 / 实时
- 故障恢复：RTO ≤ 4h / RPO ≤ 1h
- 售后支持：工作日 9-18点 / 7×24
```

### 7. 合规与安全

```
怎么保障？
- 数据分级：一般 / 重要 / 核心
- PII 处理：已脱敏 / 需脱敏 / 无PII
- 授权链路：数据来源授权完备性
- 使用限制：使用范围 / 禁止转售 / 保密义务
- 跨境合规：是否涉及数据出境
```

## Inputs

- **产品名称**（string）：数据产品名称
- **已有信息**（object）：用户已确定的部分画布内容
- **数据资产清单**（array，可选）：可用的数据资产列表（来自 `asset-catalog-crud`）
- **评审模式**（bool，可选）：是否为上架评审模式（检查完整性）

## Outputs

```yaml
product_name: "实时用户风控数据服务"
canvas:
  business_problem:
    target_user: "风控分析师"
    pain_point: "缺乏实时用户行为数据做风控决策"
    expected_value: "降低欺诈率15%"
  data_combination:
    core_datasets: ["用户行为日志", "交易记录", "设备指纹"]
    auxiliary_datasets: ["第三方黑名单"]
    source: "内部+外部"
    update_frequency: "实时"
    quality_requirement: "完整性≥99%, 准确性≥98%"
  delivery_format:
    type: "API"
    spec: "RESTful, JSON"
    frequency: "实时"
    channel: "API网关"
  user_scenario:
    scenario: "风控分析师实时调用API做交易反欺诈"
    frequency: "高频(日)"
    scale: "QPS 500, 日调用50万次"
  pricing:
    model: "阶梯"
    tiers:
      - name: "基础版"
        price: "¥5,000/月"
        features: "基础字段, 日更"
      - name: "专业版"
        price: "¥15,000/月"
        features: "全字段, 实时"
      - name: "企业版"
        price: "¥50,000/月"
        features: "定制字段, SLA保障"
    cost_estimate: "¥3,000/月"
    margin_target: "60%"
  sla:
    availability: "99.9%"
    response_time: "P95 < 200ms"
    data_freshness: "实时"
    rto: "4h"
    support: "7x24"
  compliance:
    level: "重要"
    pii: "已脱敏"
    authorization: "授权链路完备"
    restrictions: "禁止转售, 使用范围限定"
    cross_border: "不涉及"
completeness_check:
  total_sections: 7
  completed: 7
  missing: []
  ready_for_listing: true
```

## Steps

### 步骤一：业务问题定义

1. 引导用户明确目标用户、核心痛点和预期价值
2. 确保业务问题具体可量化（如"降低欺诈率15%"而非"提升风控"）

### 步骤二：数据组合设计

1. 根据业务问题匹配所需数据集
2. 如有资产目录，从 `asset-catalog-crud` 中查找可用数据
3. 定义数据质量和更新频率要求
4. 标注数据来源（内部/外部）

### 步骤三：交付形态确定

1. 根据用户场景选择交付方式（API/数据集/报告/看板）
2. 定义交付规格（格式/频率/渠道）
3. 评估技术可行性

### 步骤四：定价与SLA设计

1. 设计定价模式和分层策略
2. 估算成本并设定毛利目标
3. 匹配SLA承诺（定价越高，SLA越高）
4. 如需详细定价设计，转交 `role/data-asset-operations-planner/pricing-tier-designer`

### 步骤五：合规检查

1. 检查数据分级（配合 `data-classify`）
2. 检查 PII 处理情况（配合 `pii-scan`）
3. 检查授权链路完备性
4. 检查跨境合规（配合 `trading/cross-border-checker`）

### 步骤六：完整性评审

1. 检查 7 大板块是否全部填写
2. 评估产品是否满足上架条件
3. 如需挂牌质量评分，转交 `trading/listing-quality-scorer`

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "设计一个数据产品" | 引导填写画布7大板块 |
| "这个产品能上架吗？" | 执行完整性评审，检查7板块是否齐全 |
| "定价怎么定？" | 设计定价分层，转交 `pricing-tier-designer` 做详细测算 |
| "数据来源合不合规？" | 检查授权链路和PII处理，配合 `pii-scan` |
| "API 怎么配置？" | 交付形态确定后，转交 `api-marketplace-config` 做上架配置 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`management/asset-catalog-crud`（数据资产查询）、`role/data-asset-operations-planner/pricing-tier-designer`（定价设计）、`role/data-asset-operations-planner/api-marketplace-config`（API配置）、`trading/listing-quality-scorer`（挂牌质量评分）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
