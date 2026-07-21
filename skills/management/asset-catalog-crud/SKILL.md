---
name: asset-catalog-crud
description: >-
  数据资产目录的增删改查，对齐 GB/T 40685-2021 的最小元数据集。当新增/下架/变更资产条目、批量导入台账时使用。
license: Apache-2.0
metadata:
  scope: management
  mounted_by: ["dam-02", "dam-05", "dam-06"]
  standard_ref:
    - "GB/T 40685-2021 §6"
  risk: low
  openclaw:
    emoji: "📇"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 📇 asset-catalog-crud

## When to Use

当出现以下场景时调用本技能：

- **新增资产**入目录时，需要按标准元数据集登记
- **下架/变更**已有资产条目时，需要记录变更原因和影响
- **批量导入**台账时，需要校验数据完整性和格式合规性
- **资产查询**时，需要按多维度（域/等级/责任人/来源）检索
- **目录治理**时，需要发现重复、孤儿、过期资产

本技能是数据资产目录管理的核心操作能力，所有资产目录变更必须经过本技能流程。

## 工作原则

1. **元数据最小集必填**：新增/变更条目时，GB/T 40685 §6 定义的最小元数据集字段必须填写完整
2. **变更留痕**：所有 CUD 操作必须记录操作人、时间、变更内容，支持审计追溯
3. **级别同步**：资产安全级别变更时，联动更新访问控制和保护措施
4. **引用完整性**：下架资产前检查是否有其他资产引用（血缘/依赖），有则告警

## 资产目录元数据模型

### 最小元数据集（GB/T 40685-2021 §6.2）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| asset_id | string | 是 | 资产唯一标识（UUID 或编码规则生成） |
| name | string | 是 | 资产名称（中文可读） |
| description | string | 是 | 资产用途描述 |
| domain | string | 是 | 所属业务域（如：客户域/交易域/风控域） |
| owner_department | string | 是 | 归属部门 |
| owner_person | string | 是 | 责任人 |
| security_level | enum | 是 | 安全级别：一般/重要/核心 |
| data_category | enum | 是 | 数据分类：个人/公共/法人/衍生 |
| update_frequency | enum | 否 | 更新频率：实时/日/周/月/不定期 |
| source_system | string | 否 | 来源系统 |
| fields | array | 是 | 字段列表（来自 metadata-extract） |
| create_time | datetime | 是 | 登记时间 |
| update_time | datetime | 是 | 最后更新时间 |
| status | enum | 是 | 状态：active/inactive/deprecated |

## 操作类型

### Create（新增）

```
输入：资产元数据（最小元数据集 + 补充信息）
流程：
  1. 校验必填字段完整性
  2. 生成 asset_id
  3. 查重（名称/字段是否已有同类资产）
  4. 写入目录
  5. 记录操作日志
输出：asset_id + 登记确认
```

### Read（查询）

```
输入：查询条件（域/级别/责任人/状态/关键词）
流程：
  1. 多维度筛选
  2. 返回资产列表（含元数据摘要）
  3. 支持模糊搜索和组合查询
输出：资产列表 + 总数
```

### Update（变更）

```
输入：asset_id + 变更字段
流程：
  1. 校验 asset_id 存在性
  2. 记录变更前值（old_value）
  3. 更新字段值
  4. 如变更安全级别，联动保护措施
  5. 记录操作日志
输出：变更确认 + 变更内容对比
```

### Delete（下架）

```
输入：asset_id + 下架原因
流程：
  1. 校验 asset_id 存在性
  2. 检查引用关系（血缘/依赖）
  3. 如有引用，输出告警并要求确认
  4. 标记 status=deprecated（软删除）
  5. 记录操作日志
输出：下架确认 + 引用告警（如有）
```

## Inputs

- **操作类型**（enum）：`create` / `read` / `update` / `delete` / `batch_import`
- **资产数据**（object）：操作的资产元数据（create/update 时提供）
- **查询条件**（object）：筛选条件（read 时提供）
- **批量数据**（array）：批量导入的资产列表（batch_import 时提供）

## Outputs

```yaml
operation: "create"
result: "success"
asset_id: "DA-2024-00001"
warnings: []
log:
  operator: "dam-05"
  timestamp: "2024-07-21T10:30:00"
  action: "create"
  details: "新增资产：用户行为日志数据集"
```

## Steps

### Create 流程

1. **校验元数据**：检查最小元数据集字段是否完整，缺失字段提示用户补充
2. **查重**：按名称和字段列表检查是否已有同类资产，如发现疑似重复，提示用户确认
3. **生成 ID**：按编码规则生成 asset_id（如 `DA-YYYY-NNNNN`）
4. **写入目录**：将完整元数据写入目录
5. **记录日志**：记录操作人、时间、操作类型

### Read 流程

1. **构建查询**：根据用户提供的筛选条件构建查询
2. **执行查询**：在目录中匹配资产条目
3. **返回结果**：输出资产列表（含元数据摘要），支持分页

### Update 流程

1. **校验存在性**：确认 asset_id 在目录中存在
2. **记录变更前值**：保存 old_value 用于审计
3. **更新字段**：更新指定字段
4. **联动更新**：如变更安全级别，联动保护措施和访问控制
5. **记录日志**：记录变更内容

### Delete 流程

1. **校验存在性**：确认 asset_id 存在
2. **引用检查**：通过 `lineage-graph` 检查是否有其他资产引用本资产
3. **告警确认**：如有引用，输出告警并列出引用方，要求用户确认
4. **软删除**：将 status 标记为 `deprecated`，不物理删除
5. **记录日志**：记录下架原因和操作人

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "新增一个资产" | 执行 Create 流程，引导用户填写最小元数据集 |
| "查一下风控域有哪些资产" | 执行 Read 流程，按 domain 筛选 |
| "这个资产的级别改成重要" | 执行 Update 流程，联动更新保护措施 |
| "下架这个资产" | 执行 Delete 流程，先检查引用关系 |
| "批量导入 100 条台账" | 执行 batch_import，逐条校验并汇总成功/失败 |
| "有没有重复资产？" | 执行查重，按名称+字段匹配疑似重复项 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`foundation/metadata-extract`（元数据获取）、`foundation/data-classify`（安全分级）、`management/lineage-graph`（引用关系检查）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
