#!/usr/bin/env bash
# ==============================================================================
# data-element-agents · workflow.sh
#
# 按预置工作流串联多个岗位数字员工，输出可打印的"团队作业单"。
# 工作流定义在 workflows/*.yaml，索引在 roster.json。
#
# 用法：
#   ./workflow.sh list                              # 列出所有工作流
#   ./workflow.sh run data-asset-onboarding         # 运行指定工作流（生成作业单）
#   ./workflow.sh info data-trading-listing         # 查看工作流详情
# ==============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

WORKFLOWS_DIR="$ROOT/workflows"

list_workflows() {
  log "已定义的工作流："
  for f in "$WORKFLOWS_DIR"/*.yaml; do
    [[ -e "$f" ]] || continue
    local id name
    id=$(basename "$f" .yaml)
    name=$(awk -F': ' '/^name:/ { $1=""; sub(/^ /, ""); print; exit }' "$f")
    printf "  %-30s %s\n" "$id" "$name"
  done
}

info_workflow() {
  local id="$1"
  local f="$WORKFLOWS_DIR/${id}.yaml"
  [[ -f "$f" ]] || { err "未找到工作流：$id"; exit 1; }
  cat "$f"
}

run_workflow() {
  local id="$1"
  local f="$WORKFLOWS_DIR/${id}.yaml"
  [[ -f "$f" ]] || { err "未找到工作流：$id"; exit 1; }

  local name
  name=$(awk -F': ' '/^name:/ { $1=""; sub(/^ /, ""); print; exit }' "$f")

  echo "═══════════════════════════════════════════════════════"
  echo "  工作流：$name"
  echo "  ID：$id"
  echo "  标准：T/MIITEC 025-2024"
  echo "═══════════════════════════════════════════════════════"
  echo
  # 提取 steps
  awk '
    /^steps:/ { in_steps=1; next }
    in_steps==1 && /^[a-zA-Z]/ { in_steps=0 }
    in_steps==1 && $0 ~ /^  - / {
      sub(/^  - /, "")
      print "· " $0
    }
    in_steps==1 && $0 ~ /^    / {
      sub(/^    /, "    ")
      print
    }
  ' "$f"
  echo
  ok "作业单生成完毕。请依次调用对应数字员工执行。"
}

CMD="${1:-list}"
case "$CMD" in
  list)  list_workflows ;;
  info)  shift; info_workflow "${1:-}" ;;
  run)   shift; run_workflow "${1:-}" ;;
  *) err "未知命令：$CMD (可用 list|info|run)"; exit 1 ;;
esac
