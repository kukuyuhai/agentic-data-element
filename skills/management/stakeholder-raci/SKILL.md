---
name: stakeholder-raci
description: >-
  输出数据角色 RACI 矩阵（Responsible/Accountable/Consulted/Informed），明确权责边界。当治理体系搭建、跨部门协同前使用。
license: Apache-2.0
metadata:
  scope: management
  mounted_by: ["dam-01", "dam-02"]
  standard_ref:
    - "T/MIITEC 025-2024"
    - "GB/T 36073-2018 §5.2"
  risk: low
  openclaw:
    emoji: "👥"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 👥 stakeholder-raci

## When to Use

当出现以下场景时调用本技能：

- **数据治理体系搭建**时，需要明确各角色的权责边界
- **跨部门数据协同**前，需要定义谁负责、谁审批、谁知会
- **DCMM 评估**中数据治理能力域需要展示组织权责矩阵
- **数据安全事件**发生时，需要明确谁负责响应、谁负责上报
- **项目启动**时，需要定义数据项目的角色分工

本技能基于 RACI 模型（Responsible/Accountable/Consulted/Informed）输出数据治理的权责矩阵。

## 工作原则

1. **A 唯一原则**：每个任务只能有一个 Accountable（最终负责人），避免多头管理
2. **R 可多人**：每个任务可以有多个 Responsible（执行人），但需指定主执行人
3. **C/I 适度**：Consulted（咨询）和 Informed（知会）不应过多，避免流程冗长
4. **无空缺**：每个任务的四个角色至少有 A 和 R，不可有任务无人负责

## RACI 角色定义

| 角色 | 含义 | 职责说明 |
|------|------|---------|
| R (Responsible) | 执行者 | 具体执行任务的人，做实际工作 |
| A (Accountable) | 负责人 | 对任务结果负最终责任，只有一个，有权决策 |
| C (Consulted) | 咨询方 | 在执行前需咨询意见，提供专业建议 |
| I (Informed) | 知会方 | 任务完成后需知会结果，不需参与执行 |

## 数据治理典型角色

| 角色 | 典型岗位 | 核心职责 |
|------|---------|---------|
| 数据所有者 | 业务部门负责人 | 对数据资产负最终责任，授权数据使用 |
| 数据管家 | 数据管理岗 | 日常数据质量管理、元数据维护 |
| 数据管理员 | DBA / 数据工程师 | 技术层面的数据存储、备份、权限管理 |
| 数据安全官 | 安全合规岗 | 数据安全策略制定与监督 |
| 数据使用者 | 分析师 / 业务方 | 数据消费方，按授权使用数据 |
| 数据架构师 | 架构岗 | 数据模型设计、数据域划分 |

## Inputs

- **任务/活动列表**（array）：需要分配权责的数据治理活动（如"数据资产登记""质量巡检""安全审计"）
- **角色清单**（array）：参与方列表（含姓名、岗位、部门）
- **可选·已有分工**（object）：用户已确定的部分 RACI 分配

## Outputs

```yaml
raci_matrix:
  activities:
    - activity: "数据资产登记"
      description: "新增数据资产入目录"
      R: ["数据管家"]
      A: "数据所有者"
      C: ["数据架构师"]
      I: ["数据管理员", "数据使用者"]
    - activity: "数据质量巡检"
      description: "周期性数据质量检查"
      R: ["数据管家"]
      A: "数据所有者"
      C: ["数据管理员"]
      I: ["数据使用者"]
    - activity: "数据安全审计"
      description: "数据安全合规检查"
      R: ["数据安全官"]
      A: "数据所有者"
      C: ["数据管理员"]
      I: ["数据所有者"]
    - activity: "数据共享审批"
      description: "跨部门数据共享授权"
      R: ["数据管家"]
      A: "数据所有者"
      C: ["数据安全官"]
      I: ["数据使用者"]
    - activity: "数据脱敏处理"
      description: "敏感数据脱敏执行"
      R: ["数据管理员"]
      A: "数据安全官"
      C: ["数据管家"]
      I: ["数据使用者"]
  validation:
    unique_A: true
    no_orphans: true
    overloaded_roles: []
  recommendations:
    - "数据所有者承担过多 A 角色，建议部分授权给数据管家"
    - "数据使用者仅作为 I 出现，建议在'数据需求收集'活动中设为 C"
standard_ref: "[GB/T 36073-2018 §5.2; T/MIITEC 025-2024 §5.1.1]"
```

## Steps

### 步骤一：梳理治理活动

1. 与用户确认需要分配权责的数据治理活动列表
2. 如用户未提供，使用典型活动清单：资产登记、质量巡检、安全审计、共享审批、脱敏处理、血缘维护、标准制定、变更管理
3. 为每个活动补充简要描述

### 步骤二：确定参与角色

1. 从组织架构中提取参与角色清单
2. 如用户未提供，使用典型角色：数据所有者、数据管家、数据管理员、数据安全官、数据使用者、数据架构师
3. 为每个角色标注岗位和部门

### 步骤三：分配 RACI

1. 对每个活动逐一分配 R/A/C/I
2. 分配逻辑：
   - **A**：对结果负责的最终决策者（通常是数据所有者）
   - **R**：具体执行者（通常是数据管家或数据管理员）
   - **C**：需要咨询的专业方（如安全活动咨询安全官）
   - **I**：需要知会结果的相关方（如数据使用者）
3. 标注溯源依据：`[GB/T 36073-2018 §5.2]`

### 步骤四：校验矩阵

1. **A 唯一性校验**：每个活动是否只有一个 A
2. **空缺校验**：每个活动是否至少有 A 和 R
3. **负载均衡校验**：是否有角色承担过多 A 或 R（建议单角色 A ≤5、R ≤8）
4. 如有违反，输出修正建议

### 步骤五：输出与流转

1. 输出 RACI 矩阵（表格形式 + 校验结果）
2. 附角色负载分析图
3. 如需要建立岗位与 T/MIITEC 025-2024 的对应关系，转交 `foundation/handoff-router`

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "搭建数据治理 RACI" | 收集活动和角色清单，执行分配流程 |
| "数据共享谁审批？" | 查矩阵中"数据共享审批"活动，返回 A 角色 |
| "数据安全谁负责？" | 查矩阵中"数据安全审计"活动，返回 R 和 A 角色 |
| "某个角色太忙了" | 执行负载均衡分析，建议分摊 |
| "加一个新活动怎么分配？" | 按活动内容分配 RACI 并更新矩阵 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`management/data-domain-mapping`（业务域 owner 确认）、`foundation/handoff-router`（岗位转交映射）、`role/data-asset-security-compliance/security-audit-checklist`（安全审计活动）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
