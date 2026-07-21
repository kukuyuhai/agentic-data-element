#!/usr/bin/env bash
# ==============================================================================
# data-element-agents - lib/common.sh
# 公共函数库：日志、路径、YAML front-matter 解析
# ==============================================================================

set -euo pipefail

# ----- 颜色 -----
if [[ -t 1 ]]; then
  C_RESET='\033[0m'
  C_RED='\033[31m'
  C_GRN='\033[32m'
  C_YLW='\033[33m'
  C_BLU='\033[34m'
  C_DIM='\033[2m'
else
  C_RESET='' C_RED='' C_GRN='' C_YLW='' C_BLU='' C_DIM=''
fi

log()   { printf "%b[data-element-agents]%b %s\n" "$C_BLU" "$C_RESET" "$*"; }
ok()    { printf "%b✓%b %s\n" "$C_GRN" "$C_RESET" "$*"; }
warn()  { printf "%b⚠%b %s\n" "$C_YLW" "$C_RESET" "$*" >&2; }
err()   { printf "%b✗%b %s\n" "$C_RED" "$C_RESET" "$*" >&2; }
dim()   { printf "%b%s%b\n" "$C_DIM" "$*" "$C_RESET"; }

# ----- 路径 -----
# ROOT 由调用方设置
: "${ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

AGENTS_DIR="$ROOT/agents"
ROSTER_JSON="$ROOT/roster.json"

# ----- 依赖检查 -----
need() {
  command -v "$1" >/dev/null 2>&1 || {
    err "缺少依赖：$1，请先安装后再试。"
    exit 1
  }
}

# ----- 遍历所有 agent 文件 -----
list_agent_files() {
  find "$AGENTS_DIR" -type f -name '*.md' | sort
}

# ----- 从 front-matter 读取字段（简易版）-----
# 用法：get_frontmatter <file> <key>
get_frontmatter() {
  local file="$1"
  local key="$2"
  awk -v k="$key" '
    /^---$/ { fm++; next }
    fm==1 && $0 ~ "^"k":" {
      sub("^"k":[[:space:]]*", "", $0)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
      print; exit
    }
    fm>=2 { exit }
  ' "$file"
}

# ----- 拷贝目录（幂等）-----
copy_agents_to() {
  local dst="$1"
  local mode="${2:-md}"   # md | prompt | copilot | aider
  local converter="${3:-}"

  mkdir -p "$dst"
  local count=0
  while IFS= read -r f; do
    local base
    base="$(basename "$f")"
    case "$mode" in
      md)      cp "$f" "$dst/$base" ;;
      prompt)  cp "$f" "$dst/${base%.md}.prompt.md" ;;
      *)       if [[ -n "$converter" ]]; then
                 "$converter" "$f" "$dst/$base"
               else
                 cp "$f" "$dst/$base"
               fi ;;
    esac
    count=$((count+1))
  done < <(list_agent_files)
  ok "已同步 $count 个数字员工到 $dst"
}
