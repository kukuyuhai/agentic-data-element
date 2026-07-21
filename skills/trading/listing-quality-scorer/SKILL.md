---
name: listing-quality-scorer
description: >-
  挂牌数据产品的质量三维评分：完备性（元数据/样例/文档）、合规性（来源/PII/授权）、可交付性（接口/SLA/售后），输出总分与红旗项。当挂牌准入评审时使用。
license: Apache-2.0
metadata:
  scope: trading
  mounted_by: ["dat-01", "dat-03", "dat-05"]
  standard_ref: []
  risk: low
  openclaw:
    emoji: "🎯"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🎯 listing-quality-scorer

<!-- TODO: 完善正文；参考规范 https://agentskills.io/specification -->

## When to Use

挂牌数据产品的质量三维评分：完备性（元数据/样例/文档）、合规性（来源/PII/授权）、可交付性（接口/SLA/售后），输出总分与红旗项。当挂牌准入评审时使用。

## Inputs

- `todo`: TODO 待补充输入契约（字段/类型/示例）

## Outputs

- `todo`: TODO 待补充输出契约（字段/类型/示例）

## Steps

1. TODO 待补充执行步骤
2. 每条能力性判断末尾附标准溯源标注（形如 `§5.X.X`）
3. 命中他岗职责时调用 `foundation/handoff-router` 转交

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
