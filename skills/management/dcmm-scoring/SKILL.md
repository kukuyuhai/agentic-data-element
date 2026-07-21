---
name: dcmm-scoring
description: >-
  按 GB/T 36073-2018（DCMM）对组织在 8 大能力域上打五级分数（初始/受管理/稳健/量化/优化），并输出提升建议。当做能力评估、体系认证准备时使用。
license: Apache-2.0
metadata:
  scope: management
  mounted_by: ["dam-01", "dam-02"]
  standard_ref: []
  risk: low
  openclaw:
    emoji: "🏅"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# 🏅 dcmm-scoring

<!-- TODO: 完善正文；参考规范 https://agentskills.io/specification -->

## When to Use

按 GB/T 36073-2018（DCMM）对组织在 8 大能力域上打五级分数（初始/受管理/稳健/量化/优化），并输出提升建议。当做能力评估、体系认证准备时使用。

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
