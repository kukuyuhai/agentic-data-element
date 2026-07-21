---
name: deliverable-templater
description: >-
  从当前 agent 的角色 md "交付物模板"段落生成结构化骨架，避免手工重排。当用户请求某个可交付物但未提供模板时使用。
license: Apache-2.0
metadata:
  scope: foundation
  mounted_by: ["dam-01", "dam-02", "dam-03", "dam-04", "dam-05", "dam-06", "dam-07", "dam-08", "dam-09", "dam-10", "dam-11", "dat-01", "dat-02", "dat-03", "dat-04", "dat-05", "dat-06"]
  standard_ref: []
  risk: low
  openclaw:
    emoji: "📐"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 📐 deliverable-templater

<!-- TODO: 完善正文；参考规范 https://agentskills.io/specification -->

## When to Use

从当前 agent 的角色 md "交付物模板"段落生成结构化骨架，避免手工重排。当用户请求某个可交付物但未提供模板时使用。

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
