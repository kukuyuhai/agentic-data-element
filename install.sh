#!/usr/bin/env bash
# ==============================================================================
# data-element-agents · install.sh
#
# 将 17 个数据要素岗位数字员工安装到你选择的 AI 编程助手中。
#
# 用法：
#   ./install.sh                # 交互式选择目标
#   ./install.sh claude         # 安装到 Claude Code
#   ./install.sh cursor         # 安装到 Cursor
#   ./install.sh copilot        # 安装到 GitHub Copilot
#   ./install.sh aider          # 安装到 Aider
#   ./install.sh openclaw       # 安装到 OpenClaw（workspace 与 config 片段）
#   ./install.sh all            # 全部安装（当前项目内）
#   ./install.sh --global       # 安装到用户全局配置目录（Claude/Cursor/OpenClaw 支持）
# ==============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

TARGET="${1:-}"
GLOBAL=0
[[ "${2:-}" == "--global" || "${1:-}" == "--global" ]] && GLOBAL=1

usage() {
  cat <<EOF
data-element-agents installer

用法：
  $0 [claude|cursor|copilot|aider|openclaw|all] [--global]
  $0 --help

目标：
  claude    Claude Code           → .claude/agents/
  cursor    Cursor                → .cursor/rules/
  copilot   GitHub Copilot Chat   → .github/prompts/
  aider     Aider                 → .aider.conf.yml + .aider/agents/
  openclaw  OpenClaw              → .openclaw/workspaces/ + .openclaw/config.json5
  all       以上全部（当前项目内）

--global   Claude / Cursor / OpenClaw 使用用户级目录（~/.claude, ~/.cursor, ~/.openclaw）
EOF
}

install_claude() {
  local dst
  if [[ $GLOBAL -eq 1 ]]; then
    dst="${HOME}/.claude/agents"
  else
    dst="./.claude/agents"
  fi
  log "安装到 Claude Code：$dst"
  copy_agents_to "$dst" md
}

install_cursor() {
  local dst
  if [[ $GLOBAL -eq 1 ]]; then
    dst="${HOME}/.cursor/rules"
  else
    dst="./.cursor/rules"
  fi
  log "安装到 Cursor：$dst"
  mkdir -p "$dst"
  local count=0
  while IFS= read -r f; do
    local base name
    base="$(basename "$f" .md)"
    name="$(get_frontmatter "$f" name)"
    {
      echo "---"
      echo "description: 数据要素岗位数字员工——${name}"
      echo "globs: [\"**/*\"]"
      echo "alwaysApply: false"
      echo "---"
      echo
      cat "$f"
    } > "$dst/${base}.mdc"
    count=$((count+1))
  done < <(list_agent_files)
  ok "已同步 $count 个数字员工到 $dst"
}

install_copilot() {
  local dst="./.github/prompts"
  log "安装到 GitHub Copilot：$dst"
  copy_agents_to "$dst" prompt
}

install_aider() {
  local dst="./.aider/agents"
  log "安装到 Aider：$dst"
  copy_agents_to "$dst" md
  # 生成 Aider 配置（若不存在）
  if [[ ! -f ./.aider.conf.yml ]]; then
    cat > ./.aider.conf.yml <<'YML'
# data-element-agents · Aider 配置（自动生成）
# 使用：aider --model <provider> --read .aider/agents/<id>.md
read:
  - .aider/agents
YML
    ok "已生成 .aider.conf.yml"
  fi
}

# openclaw 侧 id 归一：小写 kebab
openclaw_id() { printf "%s" "$1" | tr '[:upper:]' '[:lower:]'; }

install_openclaw() {
  local base ws_root cfg
  if [[ $GLOBAL -eq 1 ]]; then
    base="${HOME}/.openclaw"
    ws_root="$base/workspaces-data-element"
    cfg="$base/config.data-element.json5"
  else
    base="./.openclaw"
    ws_root="$base/workspaces"
    cfg="$base/config.json5"
  fi
  log "安装到 OpenClaw：$ws_root"

  need awk
  rm -rf "$ws_root"
  mkdir -p "$ws_root"

  # 1) 为每个 agent 创建 workspace + bootstrap 四件套
  local n=0
  while IFS= read -r f; do
    local id name en dir section emoji color vibe oid ws
    id=$(get_frontmatter "$f" id)
    name=$(get_frontmatter "$f" name)
    en=$(get_frontmatter "$f" en_name)
    dir=$(get_frontmatter "$f" direction)
    section=$(get_frontmatter "$f" standard_section)
    emoji=$(get_frontmatter "$f" emoji)
    color=$(get_frontmatter "$f" color)
    vibe=$(get_frontmatter "$f" vibe)
    oid=$(openclaw_id "$id")
    ws="$ws_root/$oid"
    mkdir -p "$ws"

    cp "$f" "$ws/AGENTS.md"

    cat > "$ws/IDENTITY.md" <<EOF
# IDENTITY

你是 **${emoji} ${name}（${en}，${id}）**，来自 T/MIITEC 025-2024《数据要素产业人才岗位能力要求》§${section}。

- 所属方向：${dir}
- 岗位色号：${color}
- 岗位气质：${vibe}

始终以该岗位视角回应；跨界问题按 AGENTS.md "边界与协作" 段落转交对应岗位。
EOF

    cat > "$ws/BOOTSTRAP.md" <<EOF
# BOOTSTRAP · ${id}

## 标准依据
- 团体标准：T/MIITEC 025-2024《数据要素产业人才岗位能力要求》
- 所属章节：§${section}
- 岗位方向：${dir}

## 会话启动检查表
1. 明确用户所在场景（确权 / 评估 / 入表 / 交易 / 合规 / 运营 / …）。
2. 定位当前诉求是否落在本岗位职责边界内；若跨界，先给出转交建议。
3. 输出前对齐 AGENTS.md 中的“关键规则”与“交付物模板”章节。
4. 每条能力性判断末尾保留标准溯源标注（形如 §5.X.X）。
EOF

    cat > "$ws/TOOLS.md" <<EOF
# TOOLS · ${id}

本岗位数字员工不预置工具执行权限，请在 host（OpenClaw Gateway）侧为其绑定需要的 skills。
EOF
    n=$((n+1))
  done < <(list_agent_files)

  # 2) 生成可合并的 config.json5（已将 workspace 固化为绝对路径）
  local ws_abs
  ws_abs="$(cd "$ws_root" && pwd)"
  mkdir -p "$(dirname "$cfg")"
  {
    cat <<HDR
// ============================================================================
// data-element-agents · OpenClaw config（自动生成）
// 标准：T/MIITEC 025-2024《数据要素产业人才岗位能力要求》
// 合并方法：将本文件中的 agents.list 条目合入 ~/.openclaw/config.json5
// ============================================================================
{
  agents: {
    defaults: {
      contextInjection: "continuation-skip",
      bootstrapMaxChars: 30000,
      bootstrapTotalMaxChars: 120000,
    },
    list: [
HDR
    while IFS= read -r f; do
      local id name en dir section oid
      id=$(get_frontmatter "$f" id)
      name=$(get_frontmatter "$f" name)
      en=$(get_frontmatter "$f" en_name)
      dir=$(get_frontmatter "$f" direction)
      section=$(get_frontmatter "$f" standard_section)
      oid=$(openclaw_id "$id")
      cat <<EOF
      {
        // ${id} · ${name} (${en}) · §${section} · ${dir}
        id: "${oid}",
        workspace: "${ws_abs}/${oid}",
      },
EOF
    done < <(list_agent_files)
    cat <<'FTR'
    ],
  },
}
FTR
  } > "$cfg"

  ok "已生成 $n 个 workspace 于 $ws_abs"
  ok "已生成配置片段 $cfg"
  dim "合并到你现有 OpenClaw 配置：cat \"$cfg\" 后将 agents.list 条目拷入 ~/.openclaw/config.json5"
}

install_all() {
  install_claude
  install_cursor
  install_copilot
  install_aider
  install_openclaw
}

interactive_select() {
  cat <<EOF
请选择安装目标：
  1) Claude Code
  2) Cursor
  3) GitHub Copilot
  4) Aider
  5) OpenClaw
  6) 全部
EOF
  read -rp "输入编号 [1-6]: " choice
  case "$choice" in
    1) install_claude ;;
    2) install_cursor ;;
    3) install_copilot ;;
    4) install_aider ;;
    5) install_openclaw ;;
    6) install_all ;;
    *) err "无效选择"; exit 1 ;;
  esac
}

case "$TARGET" in
  ""|--interactive) interactive_select ;;
  claude)   install_claude ;;
  cursor)   install_cursor ;;
  copilot)  install_copilot ;;
  aider)    install_aider ;;
  openclaw) install_openclaw ;;
  all)      install_all ;;
  --global) interactive_select ;;
  -h|--help) usage ;;
  *) err "未知目标：$TARGET"; usage; exit 1 ;;
esac

echo
ok "安装完成。共 17 个数据要素岗位数字员工，标准：T/MIITEC 025-2024"
dim "提示：不同工具在会话中的加载方式请参考 docs/agent-development-guide.md"
