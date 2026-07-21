# 贡献指南 CONTRIBUTING

感谢你有意贡献！本项目致力于将 T/MIITEC 025-2024《数据要素产业人才岗位能力要求》标准
持续沉淀为高质量、可复用、可组合的数字员工角色库。

## 🧭 贡献方式

### 1. 完善现有角色
- 补充某个岗位的**关键工具链**（如新的数据资产管理平台、评估模型、合规工具）
- 添加**真实项目案例**到工程实践段落（脱敏处理后）
- 修正与标准原文不一致的表述

### 2. 新增工作流
- 在 `workflows/` 下按 YAML schema 编写跨岗位标准作业流（SOP）
- 需要至少涉及 3 个岗位，并说明协作时序、上下游交付物

### 3. 新增目标工具支持
- 在 `scripts/lib/` 增加转换器（如 Dify、FastGPT、Coze、通义灵码）
- 在 `scripts/install.sh` 注册新目标

### 4. 修复与增强脚本
- 增强 install.sh 的稳定性、跨平台兼容（macOS/Linux/WSL）
- 补充干跑（--dry-run）、幂等安装、多版本支持

## 📐 角色文件规范

新增或修改 `agents/**/*.md` 时，必须遵循以下规范：

### YAML Front-Matter

```yaml
---
id: DAM-XX 或 DAT-XX      # 角色唯一编号
name: <标准中的岗位中文名>  # 必须与标准第 3 章表 1 完全一致
direction: 数据资产管理 | 数据资产交易
level: 初级|中级|高级       # 默认能力等级（建议高级）
description: <一句话岗位职责>
color: <标签色 emoji 或颜色词>
emoji: <单个 emoji>
vibe: <一句话个性/口号>
standard: T/MIITEC 025-2024
standard_section: 5.1.X 或 5.2.X   # 对标章节号
---
```

### 内容分层（必须包含以下 8 个 H2 段落）

1. `## 🧠 岗位身份`
2. `## 🎯 核心使命`
3. `## 📚 专业知识` （细分 `### 基础知识` 与 `### 专业知识`）
4. `## 🛠️ 技术技能` （细分 `### 基本技能` 与 `### 专业技能`）
5. `## 🏗️ 工程实践`
6. `## 🚨 关键规则`
7. `## 📋 交付物模板`
8. `## 🔄 工作流程`
9. `## 💬 沟通风格`
10. `## 🎯 成功指标`
11. `## 🤝 协作对象`（列出与其它 16 个岗位的主要协作关系）

### 可追溯性要求

- 每条能力条目末尾应以脚注方式标注标准章节号，例：
  > 掌握数据资产入表的技术和方法... `— T/MIITEC 025-2024 §5.1.8 b)`
- 保持与标准术语一致（如"数据资产确权 dataAssetRegistration"，不要自创译法）

## 🔀 Pull Request 流程

1. Fork 本仓库、切出功能分支：`feat/<agent-id>-<short-desc>` 或 `docs/xxx`、`fix/xxx`。
2. 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/) 规范：
   - `feat(agent): 新增 数据资产入表工程师 交付物模板`
   - `fix(script): 修复 install.sh 在 macOS zsh 下的路径展开问题`
   - `docs(workflow): 补充数据产品挂牌 SOP`
3. PR 描述中说明：
   - **变更内容概述**
   - **对应标准条款**（如涉及）
   - **是否影响 `roster.json`**（如影响，请同步更新）
4. 通过 CI 校验（YAML front-matter、章节完整性、roster.json 一致性）后合并。

## 🧪 本地校验

```bash
# 校验所有角色文件的元数据与章节完整性
./scripts/lint.sh

# 生成目标格式并做干跑安装
./scripts/convert.sh
./scripts/install.sh --tool claude-code --dry-run
```

## 📜 行为准则

请保持专业、友善、以事实为依据的讨论。禁止在角色定义或工作流中包含违反数据安全法、
个人信息保护法或国家网络安全要求的内容。

## 📮 联系

- Issues: 用于讨论 bug、能力条目缺失、标准解读
- Discussions: 用于工作流设计、行业最佳实践交流
