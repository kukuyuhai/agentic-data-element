---
name: asset-inventory-workbook
description: >-
  数据资产盘点台账：域/系统/表/字段/责任人/等级/更新频率/血缘。当年度盘点、并购尽调、体系认证前使用。
license: Apache-2.0
metadata:
  scope: role/data-asset-operations
  mounted_by: ["dam-05"]
  standard_ref: ["GB/T 40685-2021 §6", "GB/T 36073-2018"]
  risk: low
  openclaw:
    emoji: "📓"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 📓 asset-inventory-workbook

数据资产盘点台账是数据资产管理的根基工具，用于系统化记录企业全部数据资产的域、系统、表、字段、责任人、等级、更新频率与血缘关系，确保资产"可见、可管、可用、可追溯"。

## When to Use

- **年度盘点**：每年一次全量资产盘点，更新台账基线版本（§6.1）
- **并购尽调**：并购前对目标企业数据资产进行清点，评估资产完整性与合规性（§6.2）
- **体系认证前**：DCMM、ISO 27001 等认证评审前的资产清单准备（§6.3）
- **系统迁移/重构**：系统迁移或架构重构前，确认资产范围与依赖关系
- **安全审计**：安全合规审计需要提供完整的资产清单与责任人矩阵
- **数据治理专项**：数据治理项目启动时，以盘点台账作为治理基线

## 工作原则

1. **全量覆盖**：盘点范围覆盖所有业务域、所有系统、所有表与字段，不留盲区（§6.1）
2. **责任到人**：每条资产必须明确到具体责任人，禁止使用"团队""部门"等模糊归属
3. **分级标注**：按安全级别（公开/内部/敏感/核心）和数据分类（个人/组织/业务/技术）标注
4. **血缘可溯**：记录上游来源与下游消费，形成完整血缘链路
5. **版本管理**：台账每次更新生成新版本，保留历史版本以支持差异对比
6. **校验闭环**：采集→校验→录入→复核，四步闭环确保数据质量

## 盘点台账结构

台账由五大分区构成，每个分区承载不同维度的资产信息。

### 1. 资产总览

记录资产的全局概要信息，是台账的索引层。

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| 资产ID | string | 唯一标识，全局唯一 | AST-2026-00001 |
| 数据域 | enum | 业务域分类 | 用户域/订单域/财务域 |
| 所属系统 | string | 来源系统名称 | CRM/ERP/数仓 |
| 表名 | string | 物理表名 | dwd_user_profile |
| 资产类型 | enum | 表/视图/API/文件/流 | 表 |
| 记录数 | number | 当前数据行数 | 12,500,000 |
| 数据大小 | string | 存储占用 | 2.3 GB |
| 存储格式 | enum | ORC/Parquet/CSV/JSON | Parquet |

### 2. 字段明细

逐字段记录元数据，是台账的原子层。

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| 字段名 | string | 物理字段名 | user_mobile |
| 数据类型 | string | 字段数据类型 | VARCHAR(20) |
| 约束 | string | 主键/外键/非空/唯一 | NOT NULL |
| 业务描述 | string | 字段业务含义 | 用户手机号 |
| PII标记 | boolean | 是否含个人信息 | true |
| 枚举值 | string | 取值范围 | — |

### 3. 管理信息

记录资产的管理归属与运维节奏。

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| 责任人 | string | 数据所有者姓名 | 张三 |
| 归属部门 | string | 责任部门 | 数据平台部 |
| 创建时间 | date | 资产创建日期 | 2024-03-15 |
| 更新频率 | enum | 实时/小时/天/周/月 | 天 |
| 最近更新 | datetime | 最近变更时间 | 2026-07-20 03:00:00 |
| 运维负责人 | string | 技术运维人员 | 李四 |

### 4. 安全信息

记录安全分级与脱敏状态，支撑合规管控（§6.4）。

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| 安全级别 | enum | 公开/内部/敏感/核心 | 敏感 |
| 数据分类 | enum | 个人/组织/业务/技术 | 个人 |
| 脱敏状态 | enum | 未脱敏/部分脱敏/全脱敏 | 部分脱敏 |
| 加密方式 | string | 传输/存储加密方式 | AES-256 |
| 访问权限 | string | 可访问角色列表 | 数据分析师组 |

### 5. 血缘信息

记录上下游依赖关系，支撑影响分析。

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| 上游来源 | string | 来源表/API | ods_user_log |
| 来源类型 | enum | 批量/实时/手动 | 批量 |
| 下游消费 | string | 消费方列表 | ads_user_dashboard |
| 消费类型 | enum | 查询/ETL/API | ETL |
| 血缘链路 | string | 完整血缘路径 | ods→dwd→ads |

## Inputs

- `domain_scope`（string，必填）：盘点范围，如"用户域"或"全量"
- `system_list`（array，可选）：指定系统列表，默认全部系统
- `baseline_version`（string，可选）：基线版本号，用于增量盘点
- `inventory_mode`（enum，必填）：全量盘点 / 增量盘点
- `deadline`（date，必填）：盘点截止日期

**示例输入：**

```json
{
  "domain_scope": "用户域",
  "system_list": ["CRM", "数仓"],
  "baseline_version": "v2025Q4",
  "inventory_mode": "增量盘点",
  "deadline": "2026-08-15"
}
```

## Outputs

- `workbook_version`（string）：台账版本号，如 `v2026Q3`
- `total_assets`（number）：盘点资产总数
- `summary_report`（object）：各域资产统计摘要
- `exception_list`（array）：异常项清单（责任人缺失/类型冲突等）
- `workbook_file`（string）：台账文件路径（Excel/CSV）

**示例输出：**

```json
{
  "workbook_version": "v2026Q3",
  "total_assets": 3580,
  "summary_report": {
    "用户域": { "tables": 120, "fields": 3400, "pii_tables": 45 }
  },
  "exception_list": [
    { "asset_id": "AST-2026-00102", "issue": "责任人缺失" }
  ],
  "workbook_file": "/inventory/v2026Q3_workbook.xlsx"
}
```

## Steps

1. **准备阶段**：确定盘点范围、组建盘点团队、制定盘点计划与时间表（§6.1.1）
2. **采集阶段**：通过元数据采集工具自动抓取表结构信息，调用 `` `role/data-asset-operations/metadata-extract` `` 获取元数据（§6.1.2）
3. **校验阶段**：对采集结果进行完整性校验（责任人是否为空、类型是否合法、PII标记是否准确），调用 `` `role/data-asset-operations/data-classify` `` 辅助分类（§6.1.3）
4. **录入阶段**：将校验通过的数据录入台账模板，补充管理信息与安全信息
5. **复核阶段**：各域数据负责人复核本域资产，确认责任人、安全级别、更新频率等关键字段
6. **归档阶段**：生成台账正式版本，通过 `` `role/data-asset-operations/asset-catalog-crud` `` 写入资产目录，归档历史版本

### 盘点流程图

```
准备 → 采集 → 校验 → 录入 → 复核 → 归档
  │       │       │       │       │       │
  │       │       │       │       │       └─ 写入目录 + 版本归档
  │       │       │       │       └─ 域负责人签字确认
  │       │       │       └─ 填充管理/安全/血缘信息
  │       │       └─ 完整性/一致性/PII校验
  │       └─ 元数据采集工具自动抓取
  └─ 范围/团队/计划/时间表
```

## 常见问法与处理策略

| 常见问法 | 处理策略 | 标准溯源 |
|---------|---------|---------|
| "今年年度盘点怎么做？" | 按全量盘点模式执行六步流程，以去年台账为基线做增量对比 | §6.1 |
| "并购目标公司的数据资产怎么盘点？" | 优先采集元数据，重点标注PII资产与合规风险，输出尽调报告 | §6.2 |
| "DCMM认证需要什么资产清单？" | 输出含安全分级、责任人、血缘的完整台账，附资产统计摘要 | §6.3 |
| "盘点发现责任人缺失怎么办？" | 标记为异常项，按系统归属回溯推断责任人，强制要求补全 | §6.1.3 |
| "字段太多采不过来怎么办？" | 按域分批采集，优先盘点敏感/核心资产，一般资产用自动采集 | §6.1.2 |
| "台账更新频率怎么定？" | 核心资产实时更新、重要资产日更、一般资产月更，年度全量盘点 | §6.1 |
| "血缘信息不全怎么办？" | 调用 `` `role/data-asset-operations/lineage-graph` `` 补充血缘链路 | §6.5 |
| "盘点数据和实际不一致怎么办？" | 记录差异项，触发异常处理流程，更新后重新校验 | §6.1.3 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`` `role/data-asset-operations/metadata-extract` `` · `` `role/data-asset-operations/asset-catalog-crud` `` · `` `role/data-asset-operations/data-classify` `` · `` `role/data-asset-operations/lineage-graph` `` · `` `role/data-asset-operations/inventory-diff` ``
- 规范：GB/T 40685-2021 §6 · GB/T 36073-2018 · [Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
