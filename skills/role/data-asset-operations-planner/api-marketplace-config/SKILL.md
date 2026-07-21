---
name: api-marketplace-config
description: >-
  API 集市上架配置：路径/参数/示例/限流/SLA/示例代码。当新数据产品上架、变更版本时使用。
license: Apache-2.0
metadata:
  scope: role/data-asset-operations-planner
  mounted_by: ["dam-06"]
  standard_ref: ["T/MIITEC 025-2024 §5.1.6"]
  risk: low
  openclaw:
    emoji: "🏪"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🏪 api-marketplace-config

API 集市上架配置工具，覆盖基本信息、接口定义、示例、限流、SLA、文档六大配置模块，采用 OpenAPI 规范格式，支撑数据产品高效上架与版本管理。

## When to Use

- **新品上架**：新数据产品首次发布到API集市（§5.1.6.7）
- **版本变更**：API 版本升级，新增/废弃接口或参数
- **配置调整**：调整限流策略、SLA等级或文档内容
- **集市迁移**：API 从旧集市迁移到新集市
- **上架审查**：上架前质量审查，调用 `` `role/data-asset-operations-planner/listing-quality-scorer` `` 评分
- **下架管理**：API 退役下架配置

## 工作原则

1. **规范优先**：配置遵循 OpenAPI 3.0 规范，确保通用性与兼容性（§5.1.6.7）
2. **文档完备**：每个API必须包含请求示例、响应示例、错误码、FAQ
3. **限流必配**：所有API必须配置限流策略，防止滥用与雪崩
4. **SLA明确**：可用性、响应时间、故障恢复等SLA指标明确标注
5. **版本管理**：API变更走版本管理，兼容性变更升minor版本，不兼容升major版本
6. **示例为王**：提供多语言示例代码（curl/Python/Java），降低集成门槛

## 配置模块详解

### 1. 基本信息

API 的全局元信息，是集市展示的概要层。

| 配置项 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| API名称 | string | 面向用户的名称 | 企业征信查询API |
| API描述 | string | 功能描述 | 查询企业工商、司法、经营信息 |
| API版本 | string | 语义化版本号 | v2.1.0 |
| API分类 | enum | 集市分类标签 | 企业信息/金融风控 |
| 供应商 | string | API提供方 | 数据产品部 |
| 标签 | array | 搜索标签 | 企业征信/工商查询 |
| 图标 | string | API图标URL | — |

### 2. 接口定义

API 的技术规格，是集市的实现层。

| 配置项 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| 路径 | string | API路径 | /api/v2/enterprise-credit |
| 方法 | enum | HTTP方法 | GET/POST |
| 请求参数 | array | 参数列表 | 见下方参数表 |
| 响应格式 | object | 响应结构 | JSON |
| 认证方式 | enum | 鉴权方式 | API-Key/OAuth2 |

**请求参数表示例：**

| 参数名 | 类型 | 必填 | 位置 | 说明 | 示例 |
|--------|------|------|------|------|------|
| enterprise_name | string | 是 | query | 企业名称 | 杭州科技有限公司 |
| credit_code | string | 否 | query | 统一社会信用代码 | 91330100MA2XXXXX |
| fields | array | 否 | query | 返回字段过滤 | ["basic","judicial"] |

### 3. 示例

请求与响应示例，帮助消费方快速集成。

**请求示例：**

```bash
curl -X GET "https://api.example.com/api/v2/enterprise-credit?enterprise_name=杭州科技" \
  -H "Authorization: Bearer your_api_key"
```

```python
import requests
resp = requests.get(
    "https://api.example.com/api/v2/enterprise-credit",
    params={"enterprise_name": "杭州科技"},
    headers={"Authorization": "Bearer your_api_key"}
)
print(resp.json())
```

**响应示例：**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "enterprise_name": "杭州科技有限公司",
    "credit_code": "91330100MA2XXXXX",
    "legal_person": "张三",
    "registered_capital": "1000万",
    "status": "存续"
  }
}
```

**错误码表：**

| 错误码 | 含义 | 处理建议 |
|--------|------|---------|
| 0 | 成功 | — |
| 40001 | 参数缺失 | 检查必填参数 |
| 40003 | 认证失败 | 检查API Key |
| 42901 | 限流触发 | 降低调用频率 |
| 50000 | 服务异常 | 联系技术支持 |

### 4. 限流

限流策略配置，保护API稳定性。

| 配置项 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| QPS限制 | number | 每秒请求上限 | 50 |
| 日调用上限 | number | 每日调用上限 | 100,000 |
| 分级限流 | object | 按档次配置 | 见下方限流表 |
| 超限行为 | enum | 拒绝/排队 | 拒绝（返回429） |

**分级限流表：**

| 档次 | QPS | 日上限 | 并发上限 | 适用客户 |
|------|-----|--------|---------|---------|
| 基础版 | 5 | 5,000 | 3 | 试用/免费 |
| 专业版 | 50 | 100,000 | 20 | 付费标准 |
| 旗舰版 | 200 | 1,000,000 | 100 | 大客户 |

### 5. SLA

服务等级协议，明确服务质量承诺。

| SLA指标 | 基础版 | 专业版 | 旗舰版 | 不达标赔偿 |
|---------|--------|--------|--------|-----------|
| 可用性 | 99.5% | 99.9% | 99.95% | 月费10%/20%/30% |
| 响应时间P99 | ≤500ms | ≤200ms | ≤100ms | 月费5%/10%/15% |
| 故障恢复 | ≤4h | ≤2h | ≤30min | 月费5%/10%/15% |
| 维护通知 | 7天前 | 7天前 | 14天前 | — |

### 6. 文档

配套文档配置，支撑消费方自主集成。

| 文档类型 | 内容 | 格式 |
|---------|------|------|
| 使用说明 | 快速开始、认证方式、调用流程 | Markdown |
| 集成指南 | 多语言SDK使用、最佳实践 | Markdown |
| SDK | Python/Java/Go SDK下载 | 包 |
| FAQ | 常见问题与解答 | Markdown |
| 变更日志 | 版本变更记录 | Markdown |

## Inputs

- `product_id`（string，必填）：关联数据产品ID
- `api_spec`（object，必填）：OpenAPI规格定义
- `rate_limit_policy`（object，必填）：限流策略
- `sla_level`（enum，必填）：SLA等级
- `documentation`（object，必填）：文档内容
- `version_change`（enum，可选）：major/minor/patch

**示例输入：**

```json
{
  "product_id": "DP-001",
  "api_spec": {
    "name": "企业征信查询API",
    "version": "2.1.0",
    "path": "/api/v2/enterprise-credit",
    "method": "GET"
  },
  "rate_limit_policy": { "qps": 50, "daily_limit": 100000 },
  "sla_level": "专业版",
  "documentation": { "guide": "...", "faq": "..." },
  "version_change": "minor"
}
```

## Outputs

- `listing_id`（string）：集市上架ID
- `api_endpoint`（string）：API访问地址
- `config_status`（enum）：配置状态（草稿/已发布/已下架）
- `quality_score`（number）：上架质量评分
- `marketplace_url`（string）：集市展示页面URL

## Steps

1. **产品关联**：关联数据产品ID，调用 `` `role/data-asset-operations-planner/data-product-canvas` `` 获取产品画像（§5.1.6.7.1）
2. **基本信息填写**：填写API名称、描述、版本、分类、标签等基本信息
3. **接口定义**：按OpenAPI规范定义路径、方法、请求参数、响应格式、认证方式
4. **示例编写**：编写请求示例（curl/Python/Java）、响应示例、错误码表
5. **限流配置**：按产品档次配置QPS、日上限、分级限流策略
6. **SLA配置**：按档次配置可用性、响应时间、故障恢复承诺
7. **文档编写**：编写使用说明、集成指南、SDK、FAQ、变更日志
8. **质量审查**：调用 `` `role/data-asset-operations-planner/listing-quality-scorer` `` 评分，达标后提交
9. **上架发布**：发布到API集市，生成展示页面，通知潜在消费方
10. **版本管理**：后续变更走版本管理流程，兼容性变更升minor，不兼容升major

### 上架流程图

```
产品关联 → 基本信息填写 → 接口定义 → 示例编写 → 限流配置 → SLA配置 → 文档编写 → 质量审查 → 上架发布
                                                                         │
                                                                         └─ 评分不达标 → 回到文档编写
```

## 常见问法与处理策略

| 常见问法 | 处理策略 | 标准溯源 |
|---------|---------|---------|
| "新API怎么上架？" | 按十步流程执行，先关联产品再逐模块配置，最后质量审查 | §5.1.6.7 |
| "API改了参数怎么升版本？" | 兼容性变更升minor（v2.0→v2.1），不兼容升major（v2.0→v3.0） | §5.1.6.7.2 |
| "限流QPS怎么定？" | 按产品档次定，基础版5QPS、专业版50QPS、旗舰版200QPS | §5.1.6.7.3 |
| "SLA可用性怎么承诺？" | 基础版99.5%、专业版99.9%、旗舰版99.95%，不达标按比例赔偿 | §5.1.6.7.4 |
| "上架质量评分不达标怎么办？" | 补全缺失模块（示例/文档/FAQ），评分≥80分方可上架 | §5.1.6.7.5 |
| "API要下架怎么处理？" | 设置过渡期（≥30天），通知消费方迁移，到期后下架 | §5.1.6.7.6 |
| "多语言SDK怎么提供？" | 优先提供Python/Java，按消费方需求逐步增加Go/Node.js | §5.1.6.7.7 |
| "错误码怎么设计？" | 按业务域分段（40000参数/40001认证/42901限流/50000服务） | §5.1.6.7.8 |

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 关联技能：`` `role/data-asset-operations-planner/data-product-canvas` `` · `` `role/data-asset-operations-planner/listing-quality-scorer` `` · `` `role/data-asset-operations-planner/data-product-plan` `` · `` `role/data-asset-operations-planner/pricing-tier-designer` ``
- 规范：T/MIITEC 025-2024 §5.1.6 · [OpenAPI 3.0 规范](https://spec.openapis.org/oas/v3.0.3) · [Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
