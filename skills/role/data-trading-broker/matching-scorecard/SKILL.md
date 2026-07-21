---
name: matching-scorecard
description: >-
  供需匹配打分卡（覆盖度 / 时效性 / 价格 / 合规 / 售后），输出 Top-N 推荐。当为买方推送候选卖方时使用。
license: Apache-2.0
metadata:
  scope: role/data-trading-broker
  mounted_by: ["dat-05"]
  standard_ref: []
  risk: low
  openclaw:
    emoji: "🎯"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🎯 matching-scorecard

<!-- TODO: 完善正文；参考规范 https://agentskills.io/specification -->

## When to Use

供需匹配打分卡（覆盖度 / 时效性 / 价格 / 合规 / 售后），输出 Top-N 推荐。当为买方推送候选卖方时使用。

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
