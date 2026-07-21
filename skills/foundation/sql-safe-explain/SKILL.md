---
name: sql-safe-explain
description: >-
  对 SQL 做静态分析：语法校验、全表扫描告警、注入风险识别、权限过大提示。当需要对模型/报表 SQL 做代码评审时使用。
license: Apache-2.0
metadata:
  scope: foundation
  mounted_by: ["dam-01", "dam-02", "dam-03", "dam-04", "dam-05", "dam-06", "dam-07", "dam-08", "dam-09", "dam-10", "dam-11", "dat-01", "dat-02", "dat-03", "dat-04", "dat-05", "dat-06"]
  standard_ref:
    - "GB/T 36344-2018 §4"
  risk: medium
  openclaw:
    emoji: "🛡️"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🛡️ sql-safe-explain

## When to Use

当出现以下场景时调用本技能：

- **报表/模型 SQL** 代码评审，在上线前识别性能与安全风险
- **数据资产 ETL** 任务 SQL 评审，确保不影响生产环境稳定性
- **数据共享/开放** SQL 审查，防止越权访问敏感数据
- **SQL 代码审计**，识别注入风险与不安全写法
- 用户直接贴出 SQL 请求评审或优化建议

本技能执行**静态分析**（不执行 SQL），不连接数据库，不访问真实数据。

## 工作原则

1. **只读分析**：本技能不对数据库执行任何操作，仅做文本级静态分析
2. **安全优先**：对可能导致数据泄露或越权的写法必须标为"阻断"级
3. **性能兼顾**：对可能导致全表扫描、内存溢出的写法标为"严重"级
4. **可操作建议**：每个问题必须给出具体的修复 SQL 示例，而非仅指出问题

## 检查维度

### 一、安全性检查

| 检查项 | 触发条件 | 级别 |
|--------|---------|------|
| SQL 注入风险 | 字符串拼接 WHERE 条件（如 `WHERE id = ' + input + '`） | 阻断 |
| 敏感字段暴露 | SELECT * 含 PII 字段且无脱敏 | 阻断 |
| 权限过大 | 使用 root/superuser 执行 | 阻断 |
| DDL 危险操作 | DROP TABLE / TRUNCATE / ALTER 在生产环境 | 阻断 |
| 无 LIMIT 的 DELETE | DELETE 无 WHERE 或无 LIMIT | 阻断 |
| 明文密码 | SQL 中含密码字面量 | 严重 |

### 二、性能检查

| 检查项 | 触发条件 | 级别 |
|--------|---------|------|
| 全表扫描 | SELECT 无 WHERE 或 WHERE 条件不含索引列 | 严重 |
| 大表 JOIN 无条件 | JOIN 无 ON 条件（笛卡尔积） | 阻断 |
| SELECT * | 查询所有字段而非指定字段 | 一般 |
| 无 LIMIT 的大结果集 | 预估结果集 >100万行无 LIMIT | 严重 |
| 子查询过深 | 嵌套子查询 >3 层 | 一般 |
| OR 条件阻止索引 | WHERE 使用 OR 导致索引失效 | 一般 |

### 三、语法检查

| 检查项 | 触发条件 | 级别 |
|--------|---------|------|
| 关键字拼写 | SELECT/FORM 等关键字拼写错误 | 阻断 |
| 括号不匹配 | 括号数量不对称 | 阻断 |
| 表名/列名不存在 | 引用未定义的表或列（需 schema 信息） | 阻断 |
| 类型不匹配 | WHERE 条件中字段类型与值类型不匹配 | 严重 |

### 四、规范检查

| 检查项 | 触发条件 | 级别 |
|--------|---------|------|
| 无表别名 | 多表 JOIN 时未使用表别名 | 建议 |
| 命名不规范 | 表名/列名不符合命名规范（如驼峰 vs 下划线） | 建议 |
| 无注释 | 复杂 SQL 无注释说明 | 建议 |
| 魔法数字 | WHERE 中使用未解释的字面量 | 建议 |

## Inputs

- **SQL 语句**（string）：待分析的 SQL（支持 SELECT / INSERT / UPDATE / DELETE / DDL）
- **数据库类型**（enum，可选）：`mysql` / `postgresql` / `hive` / `spark` / `generic`（默认）
- **Schema 信息**（object，可选）：表结构定义，用于字段存在性校验和索引判断
- **执行环境**（enum，可选）：`production` / `staging` / `development`（影响 DDL 危险操作判定）

## Outputs

```yaml
sql: "SELECT * FROM user_log WHERE create_time > '2024-01-01'"
db_type: "mysql"
analysis_summary:
  total_issues: 3
  blocking: 0
  serious: 2
  general: 0
  suggestion: 1
issues:
  - level: "serious"
    category: "performance"
    title: "全表扫描风险"
    description: "WHERE 条件中的 create_time 列可能未建索引，导致全表扫描"
    location: "WHERE create_time > '2024-01-01'"
    suggestion: "确认 create_time 是否有索引；如无，建议添加 CREATE INDEX idx_create_time ON user_log(create_time)"
  - level: "serious"
    category: "performance"
    title: "SELECT * 性能浪费"
    description: "查询了所有字段，但可能只需要部分字段"
    location: "SELECT *"
    suggestion: "替换为 SELECT id, user_id, event_type, create_time FROM user_log ..."
  - level: "suggestion"
    category: "convention"
    title: "建议添加 LIMIT"
    description: "无 LIMIT 子句，结果集可能过大"
    suggestion: "添加 LIMIT 1000 或分页查询"
overall_assessment: "可执行但存在性能风险，建议优化后上线"
```

## Steps

### 步骤一：解析 SQL 结构

1. 识别 SQL 类型（SELECT / INSERT / UPDATE / DELETE / DDL）
2. 解析涉及的表名、字段名、WHERE 条件、JOIN 条件、GROUP BY、ORDER BY
3. 如有 Schema 信息，校验表名和字段名是否存在

### 步骤二：安全性扫描

1. 检查是否有字符串拼接（SQL 注入风险）
2. 检查 SELECT * 是否暴露敏感字段（结合 `pii-scan` 识别结果）
3. 检查 DDL 操作是否在安全环境执行
4. 检查 DELETE/UPDATE 是否有 WHERE 条件保护

### 步骤三：性能扫描

1. 检查 WHERE 条件字段是否有索引（需 Schema 信息）
2. 检查是否有大表 JOIN 无 ON 条件
3. 检查 SELECT * 可优化为指定字段
4. 检查是否有 OR 条件导致索引失效
5. 评估结果集大小，判断是否需要 LIMIT

### 步骤四：规范扫描

1. 检查表别名使用、命名规范、注释完整性
2. 检查魔法数字、硬编码值

### 步骤五：生成评审报告

1. 汇总所有问题，按级别排序
2. 每个问题附带修复建议和 SQL 示例
3. 输出总体评估结论（可上线 / 需优化后上线 / 不可上线）
4. 每条结论附标准溯源标注（如涉及质量标准引用 `[GB/T 36344-2018 §4]`）

## 常见问法与处理策略

| 用户问法 | 处理策略 |
|---------|---------|
| "帮我看看这段 SQL 有没有问题" | 执行四维检查，输出问题清单 |
| "这个 SQL 慢不慢？" | 重点执行性能检查，分析索引和扫描情况 |
| "这个 SQL 安全吗？" | 重点执行安全检查，分析注入和敏感字段风险 |
| "SELECT * 行不行？" | 标为一般级问题，建议替换为指定字段 |
| "生产环境能跑 DROP 吗？" | 标为阻断级，生产环境禁止未经审批的 DDL |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`foundation/pii-scan`（PII 字段识别）、`foundation/metadata-extract`（Schema 信息获取）
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
