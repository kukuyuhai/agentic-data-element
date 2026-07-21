---
name: incident-response-playbook
description: >-
  数据泄露应急响应剧本：72 小时时间线（识别/遏制/根除/恢复/告知）。当发生疑似泄露时使用。
license: Apache-2.0
metadata:
  scope: role/data-asset-security-compliance
  mounted_by: ["dam-04"]
  standard_ref: []
  risk: high
  openclaw:
    emoji: "🚨"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🚨 incident-response-playbook

<!-- TODO: 完善正文；参考规范 https://agentskills.io/specification -->

## When to Use

数据泄露应急响应剧本：72 小时时间线（识别/遏制/根除/恢复/告知）。当发生疑似泄露时使用。

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
