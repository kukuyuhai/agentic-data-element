# 工作流指南（Workflows）

本项目预置了 3 个跨岗位标准工作流，用于串联多个数字员工完成典型场景。
所有工作流定义位于 [`workflows/`](../workflows/)，由 `workflow.sh` 调度。

## 1. 数据资产入表标准作业流

**id**：`data-asset-onboarding`
**参与角色**：DAM-03 → DAM-07 → DAM-08 → DAM-09
**触达法规**：财会〔2023〕11 号、GB/T 40685-2021

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ DAM-03   │→→│ DAM-07   │→→│ DAM-08   │→→│ DAM-09   │
│ 确权师   │   │ 评估师   │   │ 入表工程 │   │ 保荐师   │
└──────────┘   └──────────┘   └──────────┘   └──────────┘
   权属确认      估值报告       会计分录        保荐意见
```

**使用**：
```bash
./workflow.sh info data-asset-onboarding
./workflow.sh run  data-asset-onboarding
```

## 2. 数据产品挂牌交易流

**id**：`data-trading-listing`
**参与角色**：DAT-01 → DAT-02 → DAM-07 → DAT-03 → (DAT-05 | DAT-06)

```
DAT-01 产品设计
  ↓
DAT-02 合规评审 ─── 【决策 Gate】通过 / 有条件通过 / 不通过
  ↓
DAM-07 估值定价
  ↓
DAT-03 上架挂牌
  ↓
DAT-05 撮合成交（非产权）  ▲
  或                          │ 交易类型判断
DAT-06 产权交易（三权流转）  ▼
```

## 3. 企业数据信用评估流

**id**：`data-credit-assessment`
**参与角色**：DAM-04 → DAM-10 → DAM-11

```
DAM-04 数据合规授权
  ↓
DAM-10 数据信用管理（内部评分卡、监控预警）
  ↓
DAM-11 独立信用评价（方法论、跟踪评级）
```

## 4. 自定义工作流

新增一个工作流的最小步骤：

```bash
# 1. 复制模板
cat > workflows/my-workflow.yaml <<'YAML'
id: my-workflow
name: 我的工作流
standard: T/MIITEC 025-2024
description: >-
  说明

roles:
  - id: DAM-01
    role: 战略负责人

steps:
  - "[DAM-01] 目标制定"
  - "    交付物：《XX 战略方案》"

acceptance:
  - 战略经管理层批准
YAML

# 2. 更新 roster.json 的 workflows 数组
$EDITOR roster.json

# 3. 测试
./workflow.sh list
./workflow.sh run my-workflow
```

## 5. 编排到编程助手

在 Claude Code / Cursor / Copilot 中，可以让 agent 声明"我需要与 XX 岗位协同"，然后
按工作流依次唤起对应角色：

```
> 请以 DAM-07 数据资产评估计价师身份，
> 按 data-asset-onboarding 工作流第 2 步产出评估报告，
> 输出后交由 DAM-08 数据资产入表工程师继续第 3 步。
```
