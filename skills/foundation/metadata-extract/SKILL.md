---
name: metadata-extract
description: >-
  从 DDL / OpenAPI / CSV 头 / Parquet 抽取结构化元数据（字段名/类型/约束/示例），符合 GB/T 40685 §6 的最小元数据集。当资产盘点、目录登记、血缘建立时使用。
license: Apache-2.0
metadata:
  scope: foundation
  mounted_by: ["dam-01", "dam-02", "dam-03", "dam-04", "dam-05", "dam-06", "dam-07", "dam-08", "dam-09", "dam-10", "dam-11", "dat-01", "dat-02", "dat-03", "dat-04", "dat-05", "dat-06"]
  standard_ref:
    - "GB/T 40685-2021 §6"
  risk: low
  openclaw:
    emoji: "📋"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 📋 metadata-extract

## When to Use

当出现以下场景时调用本技能：

- **资产盘点**时需要从数据源自动抽取元数据登记入目录
- **目录登记**时需要补全数据集的结构化描述信息
- **血缘建立**时需要解析上下游表/字段的结构以建立映射关系
- **数据交换/共享**前需要向对方提供数据集的元数据说明
- **质量评估**前需要获取字段约束信息作为校验基准

本技能是数据资产管理的**结构化入口**，抽取的元数据是 `asset-catalog-crud`、`dq-6d-check`、`lineage-graph` 等技能的公共输入。

## 工作原则

1. **最小元数据集对齐**：抽取结果必须包含 GB/T 40685 §6 定义的最小元数据集（标识/定义/类型/约束/来源/归属）
2. **保留原始约束**：DDL 中的 NOT NULL、UNIQUE、外键等约束必须保留，不可丢弃
3. **示例值代表性强**：抽取的示例值应覆盖正常值、边界值、空值等典型情况
4. **跨格式统一**：不同来源（DDL/OpenAPI/CSV/Parquet）抽取后统一为同一结构输出

## 支持的输入格式

### 1. DDL（CREATE TABLE 语句）

```sql
CREATE TABLE user_behavior_log (
    id BIGINT PRIMARY KEY COMMENT '日志唯一ID',
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID',
    event_type VARCHAR(32) NOT NULL COMMENT '事件类型: click/view/purchase',
    event_time DATETIME NOT NULL COMMENT '事件发生时间',
    ip_address VARCHAR(45) COMMENT '用户IP地址',
    amount DECIMAL(10,2) DEFAULT 0 COMMENT '交易金额'
) COMMENT='用户行为日志表';
```

### 2. OpenAPI（接口定义）

从 OpenAPI 3.0 spec 的 `components.schemas` 中提取数据模型的字段定义。

### 3. CSV 头（首行+前几行）

```
user_id,event_type,amount,timestamp
U001,click,0,2024-01-01 10:00:00
U002,purchase,99.50,2024-01-01 10:05:00
```

### 4. Parquet Schema（字段类型定义）

从 Parquet 文件的 schema 信息中提取字段名和类型。

## 最小元数据集（GB/T 40685-2021 §6）

| 元素 | 说明 | 必填 |
|------|------|------|
| 标识符 | 数据集唯一标识（表名/数据集名） | 是 |
| 名称 | 人类可读名称 | 是 |
| 描述 | 数据集用途说明 | 是 |
| 字段列表 | 每个字段的名称、类型、约束、注释 | 是 |
| 数据量 | 记录条数或数据大小 | 否 |
| 数据来源 | 数据的生产方式或来源系统 | 否 |
| 归属部门 | 数据的所有者/责任部门 | 否 |
| 更新频率 | 实时/日/周/月/不定期 | 否 |
| 安全级别 | 来自 `data-classify` 的分级结果 | 否 |

## Inputs

- **输入格式**（enum）：`ddl` / `openapi` / `csv` / `parquet` / `auto`（自动识别）
- **输入内容**（string）：DDL 语句、OpenAPI JSON/YAML、CSV 文本、Parquet schema
- **可选·补充信息**（object）：人工补充的描述、归属部门、更新频率等

## Outputs

```yaml
dataset:
  identifier: "user_behavior_log"
  name: "用户行为日志表"
  description: "记录用户在平台上的行为事件"
  source: "app_backend"
  owner_department: "数据平台部"
  update_frequency: "实时"
  data_volume: "~5亿条/月"
  security_level: "重要"
fields:
  - name: "id"
    type: "BIGINT"
    nullable: false
    primary_key: true
    comment: "日志唯一ID"
    sample_values: [1, 2, 3]
  - name: "user_id"
    type: "VARCHAR(64)"
    nullable: false
    comment: "用户ID"
    sample_values: ["U001", "U002", "U003"]
  - name: "event_type"
    type: "VARCHAR(32)"
    nullable: false
    comment: "事件类型: click/view/purchase"
    enum_values: ["click", "view", "purchase"]
    sample_values: ["click", "purchase"]
  - name: "amount"
    type: "DECIMAL(10,2)"
    nullable: true
    default: 0
    comment: "交易金额"
    sample_values: [0, 99.50, 128.00]
constraints:
  - type: "primary_key"
    fields: ["id"]
  - type: "not_null"
    fields: ["user_id", "event_type", "event_time"]
standard_ref: "[GB/T 40685-2021 §6.2]"
```

## Steps

### 步骤一：格式识别

1. 如果用户指定了格式，按指定格式解析
2. 如果为 `auto`，自动识别输入内容格式（含 CREATE → DDL，含 paths/schemas → OpenAPI，含逗号分隔首行 → CSV）

### 步骤二：结构解析

1. **DDL**：解析字段名、类型、约束（NOT NULL/UNIQUE/PRIMARY KEY/DEFAULT/外键）、COMMENT
2. **OpenAPI**：解析 schema 的 properties，提取 type、format、description、enum、required
3. **CSV**：解析首行作为字段名，前 N 行推断类型（int/float/date/string/bool）
4. **Parquet**：解析 schema 定义，提取字段名和逻辑类型

### 步骤三：补全元数据

1. 将解析结果映射到最小元数据集结构
2. 从 COMMENT/description 中提取字段描述
3. 从示例数据中推断枚举值、值域范围
4. 标注未能从输入中获取的元数据元素（如归属部门、更新频率），提示用户补充

### 步骤四：验证与输出

1. 校验元数据完整性：标识符、名称、字段列表是否齐全
2. 输出结构化元数据 JSON
3. 如检测到 PII 字段（如 ip_address、phone），建议调用 `pii-scan` 进一步扫描
4. 如需要登记入目录，转交 `management/asset-catalog-crud`

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "帮我提取这个表的元数据" | 解析 DDL，输出结构化元数据 |
| "这个 API 返回什么字段？" | 解析 OpenAPI spec 的 response schema |
| "CSV 有哪些列？类型是什么？" | 解析 CSV 头+前几行，推断列名和类型 |
| "字段注释不全怎么办？" | 标注"描述缺失"，建议用户从业务方补充 |
| "元数据能自动入目录吗？" | 提取完成后转交 `asset-catalog-crud` 登记入库 |
| "这个字段含个人信息吗？" | 提取后建议调用 `pii-scan` 扫描 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`foundation/pii-scan`（PII 识别）、`management/asset-catalog-crud`（资产目录登记）、`management/lineage-graph`（血缘建立）、`foundation/dq-6d-check`（质量评估）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
