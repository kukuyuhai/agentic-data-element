# 数字员工开发指南（Agent Development Guide）

本指南面向希望**新增岗位数字员工**、**改造现有员工**或**扩展多目标安装**的开发者。

## 1. 目录结构

```
agentic-data-element/
├── agents/                          # 数字员工角色定义（source of truth）
│   ├── data-asset-management/       # 数据资产管理方向（DAM-01 ~ DAM-11）
│   └── data-asset-trading/          # 数据资产交易方向（DAT-01 ~ DAT-06）
├── templates/
│   └── agent-template.md            # 新增岗位时的模板
├── workflows/                       # 多岗位协同工作流（YAML）
│   ├── data-asset-onboarding.yaml
│   ├── data-trading-listing.yaml
│   └── data-credit-assessment.yaml
├── scripts/
│   ├── lib/common.sh                # 公共函数
│   └── validate.sh                  # 校验入口
├── docs/                            # 文档
├── install.sh                       # 一键安装到 Claude/Cursor/Copilot/Aider/OpenClaw
├── convert.sh                       # 生成 dist/{claude,cursor,copilot,aider,openclaw}
├── workflow.sh                      # 打印工作流作业单
└── roster.json                      # 机器可读的角色元数据
```

## 2. 角色文件规范

### 2.1 YAML front-matter（必填）

```yaml
---
id: DAM-XX                # 唯一标识符，格式：DAM-XX 或 DAT-XX
name: <标准岗位中文名>     # 例如：数据资产评估计价师
en_name: <English name>
direction: 数据资产管理 | 数据资产交易
level: 初级 | 中级 | 高级
description: <一句话说明>
color: <color name>       # 用于 UI 展示的颜色语义
emoji: <emoji>            # 头像 emoji
vibe: <一句 slogan>
standard: T/MIITEC 025-2024
standard_section: 5.X.X   # 对齐的标准章节号
---
```

### 2.2 必须包含的 11 个 H2 段落（顺序固定）

1. `## 🧠 岗位身份`
2. `## 🎯 核心使命`
3. `## 📚 专业知识`
   - `### 基础知识`
   - `### 专业知识`
4. `## 🛠️ 技术技能`
   - `### 基本技能`
   - `### 专业技能`
5. `## 🏗️ 工程实践`
6. `## 🚨 关键规则`
7. `## 📋 交付物模板`（至少 1 个可复制的模板；建议 3 个）
8. `## 🔄 工作流程`
9. `## 💬 沟通风格`
10. `## 🎯 成功指标`
11. `## 🤝 协作对象`

### 2.3 标准溯源

每一条能力条目末尾必须以 `— §5.X.X x)` 的形式引用标准章节，例如：

```markdown
- 熟悉数据交易市场的基本概念 — `§5.2.4 a)`
```

`x)` 对应标准中的 a)/b)/c)（分别代表专业知识 / 技术技能 / 工程实践）。

## 3. 新增一个数字员工

```bash
# 1. 复制模板
cp templates/agent-template.md \
   agents/data-asset-management/12-my-new-agent.md

# 2. 修改 front-matter 与各段落
$EDITOR agents/data-asset-management/12-my-new-agent.md

# 3. 更新 roster.json
$EDITOR roster.json

# 4. 校验
./scripts/validate.sh

# 5. 再生成分发目标
./convert.sh
```

## 4. 一键安装

```bash
# 交互式选择目标
./install.sh

# 直接指定
./install.sh claude       # → .claude/agents/
./install.sh cursor       # → .cursor/rules/ (转换为 .mdc)
./install.sh copilot      # → .github/prompts/
./install.sh aider        # → .aider/agents/ + .aider.conf.yml
./install.sh openclaw     # → .openclaw/workspaces/ + .openclaw/config.json5
./install.sh all

# 用户级全局安装（Claude/Cursor/OpenClaw 支持）
./install.sh claude --global
./install.sh openclaw --global   # → ~/.openclaw/workspaces-data-element/ + ~/.openclaw/config.data-element.json5
```

## 5. 多目标格式转换

| 目标 | 目录 | 命名 | 说明 |
|---|---|---|---|
| Claude Code | `.claude/agents/` | `<id>-<name>.md` | 直接使用 front-matter |
| Cursor | `.cursor/rules/` | `<id>-<name>.mdc` | 头部改写为 Cursor 规则头 |
| GitHub Copilot | `.github/prompts/` | `<id>-<name>.prompt.md` | 遵循 prompt 命名 |
| Aider | `.aider/agents/` | `<id>-<name>.md` | 配套生成 `.aider.conf.yml` |
| OpenClaw | `.openclaw/workspaces/<id>/` | `AGENTS.md` / `IDENTITY.md` / `BOOTSTRAP.md` / `TOOLS.md` | 配套生成可合并的 `config.json5` |

### 5.1 OpenClaw 细节

OpenClaw 采用 **一个 agent 一个 workspace 目录** 的模型，会将其中的 bootstrap Markdown 注入系统提示。生成内容：

- `AGENTS.md`：直接使用角色 md 全文，作为行为准则主体。
- `IDENTITY.md`：从 front-matter 提取的身份卡（`emoji` / `name` / `direction` / `color` / `vibe`）。
- `BOOTSTRAP.md`：会话启动检查表，确保输出末尾保留 `§5.X.X` 标准溯源。
- `TOOLS.md`：工具占位，默认不预置高危工具。

项目内安装会产出 `.openclaw/config.json5`，其 `agents.list[].workspace` 已固化为绝对路径，可直接将条目合入 `~/.openclaw/config.json5`。参考 [OpenClaw 官方文档](https://docs.openclaw.ai/gateway/config-agents)。

## 6. 工作流开发

工作流位于 `workflows/*.yaml`，最小结构：

```yaml
id: <workflow-id>
name: <人可读的名称>
standard: T/MIITEC 025-2024
description: >-
  一句话说明该流的目的

roles:
  - id: DAM-XX
    name: ...
    role: 上游·xxx

steps:
  - "[DAM-XX] 步骤 1 描述"
  - "    交付物：..."

decision_gate:      # 关键决策节点
  - name: ...
    owner: DAT-XX
    rule: ...

acceptance:         # 完成标准
  - ...
```

## 7. 校验规则

`scripts/validate.sh` 会执行：

1. 每个 agent 文件的 front-matter 必填字段是否齐全；
2. 是否包含全部 11 个 H2 段落；
3. 是否至少有一处 `§5.X.X` 章节引用；
4. `roster.json` 中每个 `file` 是否真实存在。

CI（`.github/workflows/ci.yml`）会在 PR 时自动运行。

## 8. 提交规范

请参考 [CONTRIBUTING.md](../CONTRIBUTING.md) 中的 Conventional Commits 规范。

常用类型：
- `feat(dam-07): 新增蒙特卡洛估值示例`
- `docs(capability-model): 修正等级权重计算`
- `fix(install): 修复 Cursor 生成 mdc 头顺序`
- `chore(workflow): 更新入表工作流决策节点`
