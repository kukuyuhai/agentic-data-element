#!/usr/bin/env bash
# ==============================================================================
# agentic-data-element · convert.sh
#
# 将标准 agent markdown 文件转换为不同 AI 工具专属格式（不做安装动作）。
# 主要用途：
#   1) 生成 dist/ 目录中的多目标格式，供下游 CI/CD 打包分发
#   2) 生成 roster.md（人可读的岗位一览表）
#   3) 生成 agents.index.json（扁平索引，供程序读取）
#
# 用法：
#   ./convert.sh                # 生成全部
#   ./convert.sh index          # 只生成 agents.index.json
#   ./convert.sh roster         # 只生成 dist/roster.md
#   ./convert.sh dist           # 只生成 dist/{claude,cursor,copilot,aider}
#   ./convert.sh openclaw       # 只生成 dist/openclaw/{config.json5,workspaces/*}
# ==============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

DIST="$ROOT/dist"
mkdir -p "$DIST"

gen_index() {
  log "生成 dist/agents.index.json"
  local out="$DIST/agents.index.json"
  {
    echo "["
    local first=1
    while IFS= read -r f; do
      local id name en dir section
      id=$(get_frontmatter "$f" id)
      name=$(get_frontmatter "$f" name)
      en=$(get_frontmatter "$f" en_name)
      dir=$(get_frontmatter "$f" direction)
      section=$(get_frontmatter "$f" standard_section)
      [[ $first -eq 0 ]] && echo "  ,"
      first=0
      local rel="${f#"$ROOT/"}"
      cat <<EOF
  {
    "id": "$id",
    "name": "$name",
    "en_name": "$en",
    "direction": "$dir",
    "standard_section": "$section",
    "file": "$rel"
  }
EOF
    done < <(list_agent_files)
    echo "]"
  } > "$out"
  ok "已生成 $out"
}

gen_roster_md() {
  log "生成 dist/roster.md"
  local out="$DIST/roster.md"
  {
    echo "# 数据要素岗位数字员工 · 岗位一览"
    echo
    echo "> 标准：T/MIITEC 025-2024《数据要素产业人才岗位能力要求》"
    echo
    echo "| 编号 | 岗位 | 英文 | 方向 | 标准章节 | 文件 |"
    echo "|---|---|---|---|---|---|"
    while IFS= read -r f; do
      local id name en dir section rel
      id=$(get_frontmatter "$f" id)
      name=$(get_frontmatter "$f" name)
      en=$(get_frontmatter "$f" en_name)
      dir=$(get_frontmatter "$f" direction)
      section=$(get_frontmatter "$f" standard_section)
      rel="${f#"$ROOT/"}"
      echo "| $id | $name | $en | $dir | §$section | [md]($rel) |"
    done < <(list_agent_files)
  } > "$out"
  ok "已生成 $out"
}

gen_dist_targets() {
  log "生成 dist/{claude,cursor,copilot,aider}"
  copy_agents_to "$DIST/claude"  md
  copy_agents_to "$DIST/copilot" prompt

  # cursor .mdc
  mkdir -p "$DIST/cursor"
  local n=0
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
    } > "$DIST/cursor/${base}.mdc"
    n=$((n+1))
  done < <(list_agent_files)
  ok "已生成 dist/cursor（$n 个 .mdc）"

  copy_agents_to "$DIST/aider" md
}

# ------------------------------------------------------------------------------
# OpenClaw 目标
# ------------------------------------------------------------------------------
# OpenClaw 使用 "每个 agent 一个 workspace 目录 + 若干 bootstrap Markdown" 的模型：
#   AGENTS.md    必填  行为准则 / 系统提示主体
#   IDENTITY.md  可选  角色身份（谁 · 定位 · vibe）
#   BOOTSTRAP.md 必填  会话启动上下文（标准、方向、关键交付物）
#   TOOLS.md     必填  可用工具（此处保留为占位，由 host 侧接入）
# 生成物：
#   dist/openclaw/config.json5              可合并进 ~/.openclaw/config.json5 的片段
#   dist/openclaw/workspaces/<agent-id>/    每个岗位一个 workspace
# 参考：https://docs.openclaw.ai/gateway/config-agents

# 将 DAM-01 / DAT-03 归一为 openclaw 侧的 agent id：小写 kebab-case
openclaw_id() { printf "%s" "$1" | tr '[:upper:]' '[:lower:]'; }

gen_openclaw() {
  log "生成 dist/openclaw/{config.json5,workspaces/*}"
  local root="$DIST/openclaw"
  local ws_root="$root/workspaces"
  rm -rf "$ws_root"
  mkdir -p "$ws_root"

  local cfg="$root/config.json5"
  {
    cat <<'HDR'
// ============================================================================
// agentic-data-element · OpenClaw config snippet（自动生成）
// 标准：T/MIITEC 025-2024《数据要素产业人才岗位能力要求》
//
// 用法（二选一）：
//   1) 全局：将本文件合并到 ~/.openclaw/config.json5 的 agents.list 中
//      同时把 dist/openclaw/workspaces 拷到 ~/.openclaw/workspaces-data-element
//   2) 项目内：./install.sh openclaw 会一键完成拷贝 + 打印合并方法
//
// 注意：workspace 路径中的 ${DE_WORKSPACES} 需被替换为真实绝对路径。
// 参考：https://docs.openclaw.ai/gateway/config-agents
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
        workspace: "\${DE_WORKSPACES}/${oid}",
      },
EOF
    done < <(list_agent_files)
    cat <<'FTR'
    ],
  },
}
FTR
  } > "$cfg"

  # 为每个 agent 生成 workspace bootstrap 文件
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

    # AGENTS.md —— 行为准则主体，直接沿用角色 md 全文
    cp "$f" "$ws/AGENTS.md"

    # IDENTITY.md —— 身份卡
    cat > "$ws/IDENTITY.md" <<EOF
# IDENTITY

你是 **${emoji} ${name}（${en}，${id}）**，来自 T/MIITEC 025-2024《数据要素产业人才岗位能力要求》§${section}。

- 所属方向：${dir}
- 岗位色号：${color}
- 岗位气质：${vibe}

始终以该岗位视角回应；跨界问题按 AGENTS.md "边界与协作" 段落转交对应岗位。
EOF

    # BOOTSTRAP.md —— 会话启动上下文
    cat > "$ws/BOOTSTRAP.md" <<EOF
# BOOTSTRAP · ${id}

## 标准依据
- 团体标准：T/MIITEC 025-2024《数据要素产业人才岗位能力要求》
- 所属章节：§${section}
- 岗位方向：${dir}

## 会话启动检查表
1. 明确用户所在场景（确权 / 评估 / 入表 / 交易 / 合规 / 运营 / …）。
2. 定位当前诉求是否落在本岗位职责边界内；若跨界，先给出转交建议。
3. 输出前对齐 AGENTS.md 中的"关键规则"与"交付物模板"章节。
4. 每条能力性判断末尾保留标准溯源标注（形如 §5.X.X）。
EOF

    # TOOLS.md —— 工具占位（host 侧接入）
    cat > "$ws/TOOLS.md" <<EOF
# TOOLS · ${id}

本岗位数字员工不预置工具执行权限。请在 host（OpenClaw Gateway）侧为其绑定：

- \`memory_*\`：读取/写入长期记忆，用于跨会话保留项目上下文。
- \`file_read\` / \`file_write\`：仅在得到用户明确授权的目录内进行。
- \`http.fetch\`：仅用于查询公开标准/法规原文。
- 领域工具（如数据资产估值计算器、DCMM 打分器）：按需在 skills 层挂载。

未列出的高危工具（shell 执行、删除、跨账号访问）默认拒绝。
EOF
    n=$((n+1))
  done < <(list_agent_files)

  ok "已生成 $cfg"
  ok "已生成 $n 个 workspace 于 $ws_root"
}

TARGET="${1:-all}"
case "$TARGET" in
  index)    gen_index ;;
  roster)   gen_roster_md ;;
  dist)     gen_dist_targets ;;
  openclaw) gen_openclaw ;;
  all)      gen_index; gen_roster_md; gen_dist_targets; gen_openclaw ;;
  *) err "未知目标：$TARGET"; exit 1 ;;
esac
