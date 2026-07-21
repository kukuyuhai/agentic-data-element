---
name: lineage-graph
description: >-
  查询/生成数据血缘图（表 → 表、字段 → 字段），支持影响分析与溯源分析。当质量事件根因定位、资产变更影响评估时使用。
license: Apache-2.0
metadata:
  scope: management
  mounted_by: ["dam-03", "dam-05", "dam-08"]
  standard_ref:
    - "GB/T 40685-2021 §6.4"
  risk: low
  openclaw:
    emoji: "🌳"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🐳 lineage-graph

## When to Use

当出现以下场景时调用本技能：

- **质量事件根因定位**：下游报表数据异常，需要溯源到上游源头表
- **资产变更影响评估**：修改/下架某张表前，需要知道哪些下游资产会受影响
- **血缘建立**：从 ETL/SQL 脚本中解析数据流向，自动建立血缘关系
- **合规溯源**：数据确权或审计时，需要证明数据从来源到当前的全链路
- **数据产品溯源**：数据产品上架时需要提供数据来源链路证明

本技能是数据资产管理的**血脉系统**，维护表级和字段级的血缘关系图谱。

## 工作原则

1. **双向可查**：血缘图支持正向（影响分析：上游 → 下游）和反向（溯源分析：下游 → 上游）两种查询
2. **粒度可选**：支持表级血缘和字段级血缘两个粒度，默认表级，需要时展开到字段级
3. **实时同步**：ETL 变更后血缘关系应自动更新，保持与实际数据流向一致
4. **可视化输出**：血缘查询结果以 DAG（有向无环图）形式输出，支持文本和可视化两种呈现

## 血缘关系类型

| 关系类型 | 说明 | 示例 |
|---------|------|------|
| 直接依赖 | 下游表直接读取上游表数据 | `ods_user` → `dwd_user_detail` |
| 字段映射 | 下游字段由上游字段转换而来 | `raw.phone` → `clean.phone_number`（格式化） |
| 聚合衍生 | 下游字段由上游多个字段聚合计算 | `SUM(orders.amount)` → `daily_report.total_amount` |
| 条件分支 | 根据 ETL 逻辑分叉到不同下游 | `user_log` → `active_user` / `inactive_user` |
| 外部接入 | 外部数据源接入 | `api.third_party` → `ods_external_data` |

## Inputs

- **操作类型**（enum）：`query_upstream`（溯源）/ `query_downstream`（影响分析）/ `build_lineage`（建立血缘）/ `full_graph`（全链路图）
- **起点资产**（string）：起始表名或 asset_id
- **深度**（int）：查询的层级深度（默认 3 层）
- **粒度**（enum）：`table`（表级，默认）/ `field`（字段级）
- **ETL 脚本**（string，可选）：用于解析建立血缘的 SQL/脚本内容

## Outputs

```yaml
query_type: "downstream"
start_node: "ods_user_log"
depth: 3
granularity: "table"
lineage:
  nodes:
    - id: "ods_user_log"
      name: "ODS用户日志"
      level: 0
      type: "source"
    - id: "dwd_user_detail"
      name: "DWD用户明细"
      level: 1
      type: "intermediate"
    - id: "dws_user_daily_report"
      name: "DWS用户日报"
      level: 2
      type: "intermediate"
    - id: "ads_user_dashboard"
      name: "ADS用户看板"
      level: 3
      type: "sink"
  edges:
    - from: "ods_user_log"
      to: "dwd_user_detail"
      transform: "清洗+去重+格式化"
      etl_job: "etl_user_clean"
    - from: "dwd_user_detail"
      to: "dws_user_daily_report"
      transform: "按日聚合"
      etl_job: "etl_user_aggregate"
    - from: "dws_user_daily_report"
      to: "ads_user_dashboard"
      transform: "指标计算+展示"
      etl_job: "etl_user_dashboard"
impact_summary:
  total_affected: 3
  tables_affected: ["dwd_user_detail", "dws_user_daily_report", "ads_user_dashboard"]
  critical_affected: ["ads_user_dashboard"]
  warning: "修改 ods_user_log 将影响 3 个下游表，其中 ads_user_dashboard 为生产看板，需评估影响"
```

## Steps

### 溯源分析（query_upstream）

1. **确定起点**：从用户指定的异常表/字段出发
2. **反向遍历**：向上游追溯每一层的来源表和 ETL 作业
3. **标注转换逻辑**：每一层标注数据转换方式（清洗/聚合/关联/计算）
4. **输出链路图**：输出从源头到当前节点的完整链路
5. **根因定位**：在链路中标注可能的异常引入点

### 影响分析（query_downstream）

1. **确定起点**：从用户指定要变更的表/字段出发
2. **正向遍历**：向下游追踪每一层的消费表和 ETL 作业
3. **评估影响范围**：统计受影响的表数量、重要程度
4. **标注关键影响**：如有生产报表、线上接口受影响，标注为关键影响
5. **输出影响清单**：输出受影响表列表和风险等级

### 建立血缘（build_lineage）

1. **解析 ETL 脚本**：从 SQL INSERT...SELECT、Spark 代码中解析数据流向
2. **提取映射关系**：提取字段级映射（SELECT a AS b → a → b）
3. **写入血缘图谱**：将解析结果写入血缘图数据库
4. **去重校验**：检查是否与已有血缘冲突
5. **输出确认**：输出解析结果供用户确认

### 全链路图（full_graph）

1. **双向遍历**：从指定节点同时向上游和下游遍历
2. **合并路径**：合并上下游结果，形成完整链路图
3. **输出 DAG**：以有向无环图形式输出完整血缘拓扑

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "这张表的数据从哪来的？" | 执行溯源分析，输出上游链路 |
| "改了这张表会影响什么？" | 执行影响分析，输出下游受影响清单 |
| "报表数据异常，问题在哪？" | 执行溯源分析，在链路中标注可能的异常引入点 |
| "帮我画一下这个数据的血缘" | 执行全链路图，输出 DAG |
| "从 ETL 脚本建立血缘" | 解析 SQL/Spark 脚本，提取血缘关系写入图谱 |
| "下架前检查一下依赖" | 执行影响分析，如有下游依赖则告警 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`foundation/metadata-extract`（字段结构获取）、`foundation/sql-safe-explain`（ETL SQL 解析）、`management/asset-catalog-crud`（资产下架前引用检查）、`foundation/dq-6d-check`（质量事件根因定位）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
