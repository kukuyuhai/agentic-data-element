---
name: data-domain-mapping
description: >-
  建立业务域 ↔ 数据域的双向映射，输出对齐表与冲突项。当组织架构调整、数据资产目录初建时使用。
license: Apache-2.0
metadata:
  scope: management
  mounted_by: ["dam-02", "dam-05"]
  standard_ref:
    - "GB/T 40685-2021 §5"
  risk: low
  openclaw:
    emoji: "🗺️"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🗺️ data-domain-mapping

## When to Use

当出现以下场景时调用本技能：

- **数据资产目录初建**时，需要建立业务域与数据域的映射关系，为目录分类打基础
- **组织架构调整**后，业务域归属变化，需要同步更新数据域映射
- **数据治理体系搭建**时，需要明确每个数据域的业务 owner
- **跨部门数据协同**前，需要确认数据域归属与权责
- **DCMM 评估**中数据架构能力域需要展示业务-数据对齐情况

本技能建立业务域（按业务能力划分）与数据域（按数据主题划分）的双向映射关系。

## 工作原则

1. **双向映射**：业务域 ↔ 数据域是多对多关系，一个业务域可能涉及多个数据域，反之亦然
2. **主映射 + 辅助映射**：每个数据域有唯一主业务域 owner，但可有多个辅助业务域
3. **冲突显式标注**：当多个业务域对同一数据域主张 ownership 时，标为冲突项需人工裁决
4. **动态维护**：组织架构变化后需重新校准映射关系

## 业务域与数据域定义

### 典型业务域

| 业务域 | 核心业务能力 | 典型部门 |
|--------|------------|---------|
| 客户域 | 客户管理、客户画像 | 客户服务部 |
| 交易域 | 订单、支付、结算 | 交易业务部 |
| 产品域 | 产品管理、产品目录 | 产品部 |
| 营销域 | 营销活动、推广 | 市场部 |
| 风控域 | 风险评估、反欺诈 | 风控部 |
| 人力域 | 员工、组织、薪酬 | 人力资源部 |
| 财务域 | 会计、成本、预算 | 财务部 |

### 典型数据域

| 数据域 | 核心数据实体 | 典型表 |
|--------|------------|--------|
| 客户数据 | 客户基本信息、画像标签 | dim_customer, tag_customer |
| 交易数据 | 订单、支付流水、退款 | fact_order, fact_payment |
| 产品数据 | 产品信息、SKU、属性 | dim_product |
| 行为数据 | 浏览、点击、搜索日志 | log_user_behavior |
| 风控数据 | 风险评分、规则命中 | fact_risk_event |
| 组织数据 | 部门、岗位、人员 | dim_org, dim_employee |
| 财务数据 | 科目余额、凭证、成本 | fact_gl_balance |

## Inputs

- **业务域清单**（array）：企业现有业务域列表（含名称、归属部门）
- **数据域清单**（array）：数据资产目录中的数据域列表
- **映射规则**（object，可选）：已知的映射关系（业务域 → 数据域）
- **组织架构信息**（object，可选）：部门列表与汇报关系

## Outputs

```yaml
mapping_table:
  - business_domain: "客户域"
    owner_department: "客户服务部"
    primary_data_domain: "客户数据"
    secondary_data_domains: ["行为数据"]
    data_owner: "张三"
    confidence: "high"
  - business_domain: "交易域"
    owner_department: "交易业务部"
    primary_data_domain: "交易数据"
    secondary_data_domains: ["财务数据"]
    data_owner: "李四"
    confidence: "high"
  - business_domain: "营销域"
    owner_department: "市场部"
    primary_data_domain: "行为数据"
    secondary_data_domains: ["客户数据"]
    data_owner: "王五"
    confidence: "medium"
conflicts:
  - data_domain: "行为数据"
    claiming_domains: ["客户域", "营销域"]
    conflict_type: "ownership_dispute"
    description: "客户域和营销域都主张行为数据的主 ownership"
    suggestion: "建议行为数据归客户域主有，营销域为辅助使用方"
  - data_domain: "财务数据"
    claiming_domains: ["交易域", "财务域"]
    conflict_type: "ownership_dispute"
    description: "交易域认为交易流水属于本域，财务域认为会计科目属于本域"
    suggestion: "交易流水归交易域，会计科目归财务域，按实体细分"
unmapped:
  business_domains: ["人力域"]
  data_domains: ["组织数据"]
  note: "人力域未提供数据资产，建议补充登记"
standard_ref: "[GB/T 40685-2021 §5.3]"
```

## Steps

### 步骤一：收集业务域

1. 从组织架构中提取业务域清单
2. 为每个业务域标注归属部门和业务负责人
3. 如用户未提供，按典型业务域清单引导用户确认

### 步骤二：收集数据域

1. 从数据资产目录（`asset-catalog-crud`）中提取数据域分类
2. 如目录尚未建立数据域分类，从元数据中按表名/字段特征推断
3. 为每个数据域标注当前已知的 owner 信息

### 步骤三：建立映射

1. 按实体匹配度建立初始映射：业务域的核心实体 → 数据域的核心表
2. 确定主映射关系（primary）和辅助映射关系（secondary）
3. 标注映射置信度（high/medium/low）

### 步骤四：识别冲突

1. 检查是否存在多个业务域对同一数据域主张主 ownership
2. 检查是否存在未被任何业务域认领的数据域（孤儿数据）
3. 检查是否存在无数据资产的业务域（空业务域）
4. 输出冲突清单及处理建议

### 步骤五：输出映射表

1. 输出完整的业务域 ↔ 数据域映射表
2. 附冲突项清单和裁决建议
3. 附孤儿数据和空业务域告警
4. 如需要 RACI 矩阵，转交 `management/stakeholder-raci`

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "建立业务域和数据域的映射" | 收集双方清单，执行映射流程 |
| "这张表归哪个业务域？" | 按表内容匹配数据域，再查映射表找到业务域 owner |
| "行为数据归谁管？" | 检查冲突清单，如有争议输出裁决建议 |
| "组织架构变了怎么办？" | 重新执行映射流程，更新 owner 信息 |
| "有没有孤儿数据？" | 检查未被任何业务域认领的数据域，输出告警 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`management/asset-catalog-crud`（资产目录）、`management/stakeholder-raci`（权责矩阵）、`foundation/metadata-extract`（元数据获取）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
