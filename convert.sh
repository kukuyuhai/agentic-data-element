#!/usr/bin/env bash
# ==============================================================================
# data-element-agents · convert.sh
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

TARGET="${1:-all}"
case "$TARGET" in
  index)   gen_index ;;
  roster)  gen_roster_md ;;
  dist)    gen_dist_targets ;;
  all)     gen_index; gen_roster_md; gen_dist_targets ;;
  *) err "未知目标：$TARGET"; exit 1 ;;
esac
