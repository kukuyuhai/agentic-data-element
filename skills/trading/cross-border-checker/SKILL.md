---
name: cross-border-checker
description: >-
  按数据出境安全评估办法与个保法判断数据出境是否触发申报/认证/合同标准。当涉及跨境数据流通、境外 IP 访问时使用。
license: Apache-2.0
metadata:
  scope: trading
  mounted_by: ["dat-02", "dam-04"]
  standard_ref: []
  risk: high
  openclaw:
    emoji: "🌐"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🌐 cross-border-checker

<!-- TODO: 完善正文；参考规范 https://agentskills.io/specification -->

## When to Use

按数据出境安全评估办法与个保法判断数据出境是否触发申报/认证/合同标准。当涉及跨境数据流通、境外 IP 访问时使用。

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
