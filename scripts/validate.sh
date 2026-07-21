#!/usr/bin/env bash
# ==============================================================================
# agentic-data-element · validate.sh
#
# 校验所有 agent 文件的完整性：
#   1) YAML front-matter 必填字段齐全
#   2) 必须包含全部 H2 段落
#   3) 每条能力条目末尾标注了标准章节号（§5.X.X x)）
#   4) roster.json 里的 file 全部存在
# ==============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"

REQUIRED_FRONTMATTER=(id name en_name direction level description standard standard_section)
REQUIRED_H2=(
  "岗位身份"
  "核心使命"
  "专业知识"
  "技术技能"
  "工程实践"
  "关键规则"
  "交付物模板"
  "工作流程"
  "沟通风格"
  "成功指标"
  "协作对象"
)

errors=0

check_file() {
  local f="$1"
  local rel="${f#"$ROOT/"}"

  # front-matter
  for key in "${REQUIRED_FRONTMATTER[@]}"; do
    local v
    v="$(get_frontmatter "$f" "$key" || true)"
    if [[ -z "$v" ]]; then
      err "$rel 缺少 front-matter 字段：$key"
      errors=$((errors+1))
    fi
  done

  # H2 sections
  for sec in "${REQUIRED_H2[@]}"; do
    if ! grep -q "^## .*${sec}" "$f"; then
      err "$rel 缺少段落：## ${sec}"
      errors=$((errors+1))
    fi
  done

  # 标准章节引用
  if ! grep -q '§5\.[0-9]\+\.[0-9]\+' "$f"; then
    err "$rel 未标注任何标准章节引用 (§5.X.X)"
    errors=$((errors+1))
  fi
}

log "校验 $AGENTS_DIR"
count=0
while IFS= read -r f; do
  check_file "$f"
  count=$((count+1))
done < <(list_agent_files)

log "校验 roster.json 引用"
if command -v python3 >/dev/null 2>&1; then
  ROOT="$ROOT" python3 - <<PY
import json, os, sys
root = os.environ.get("ROOT", ".")
data = json.load(open(os.path.join(root, "roster.json"), encoding="utf-8"))
missing = []
for d in data["directions"]:
    for a in d["agents"]:
        p = os.path.join(root, a["file"])
        if not os.path.exists(p):
            missing.append(a["file"])
if missing:
    for m in missing:
        print("MISSING:", m)
    sys.exit(1)
PY
fi

log "校验 skills/ 与 mount-map.json 一致性"
if [[ -d "$ROOT/skills" && -f "$ROOT/skills/mount-map.json" && -f "$ROOT/skills/manifest.json" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    ROOT="$ROOT" python3 - <<'PY' || errors=$((errors+1))
import json, os, re, sys, pathlib
root = pathlib.Path(os.environ.get("ROOT", "."))
manifest = json.loads((root/"skills/manifest.json").read_text())
files = list(root.glob("skills/**/SKILL.md"))
if len(manifest) != len(files):
    print(f"[skills] manifest 条目 ({len(manifest)}) ≠ SKILL.md 数 ({len(files)})")
    sys.exit(1)
for f in files:
    txt = f.read_text(encoding="utf-8")
    m = re.search(r"^name:\s*(\S+)\s*$", txt, re.M)
    if not m or m.group(1) != f.parent.name:
        print(f"[skills] {f}: front-matter name 与目录名不匹配")
        sys.exit(1)
mmap = json.loads((root/"skills/mount-map.json").read_text())
names = {m["scope"]+"/"+m["name"] for m in manifest}
for aid, sks in mmap.items():
    for s in sks:
        if s not in names:
            print(f"[skills] {aid} 引用不存在的 skill: {s}")
            sys.exit(1)
print(f"[skills] OK: {len(manifest)} skills, {len(mmap)} agents mount-map 均一致")
PY
  fi
else
  dim "未发现 skills/mount-map.json，跳过 skills 校验（可先跑 scripts/gen-skills.sh）"
fi

echo
if [[ $errors -gt 0 ]]; then
  err "校验失败：共发现 $errors 处问题"
  exit 1
fi
ok "所有 $count 个 agent 文件通过校验"
