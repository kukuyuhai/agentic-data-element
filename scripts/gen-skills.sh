#!/usr/bin/env bash
# ==============================================================================
# agentic-data-element · gen-skills.sh
#
# 从内嵌清单生成 skills/ 目录下的所有 SKILL.md 骨架文件。
#
# 输入：本脚本内嵌的 SKILLS[] 与 MOUNTS[] 清单（source of truth）
# 输出：
#   skills/<scope>/<name>/SKILL.md    · 71 个骨架文件
#   skills/manifest.json              · 扁平清单（供程序读取）
#   skills/mount-map.json             · agent-id → [skill 全名] 映射
#
# 参考规范：
#   Anthropic Agent Skills · https://agentskills.io/specification
#   OpenClaw skill format · https://docs.openclaw.ai/clawhub/skill-format
# ==============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"

SKILLS_DIR="$ROOT/skills"
mkdir -p "$SKILLS_DIR"

# ------------------------------------------------------------------------------
# 清单：scope|name|emoji|risk|description
# scope 语义：foundation / management / trading / role/<agent-id>
# ------------------------------------------------------------------------------
SKILLS=(
  # ---- foundation (10) ----
  "foundation|standard-lookup|📚|low|检索数据要素相关的团体/国家标准原文（T/MIITEC 025-2024、GB/T 40685、DCMM 等），返回带条款号的原文片段与上下文。当用户询问某项能力要求的标准依据、需要引用条款、或校验做法是否达标时使用。"
  "foundation|regulation-lookup|⚖️|low|检索数据相关法规原文（数据二十条、数据安全法、个人信息保护法、财会〔2023〕11 号等），返回带条号的原文片段。当输出涉及合规判断、合同条款、财务处理时使用。"
  "foundation|citation-attach|🔖|low|在能力性输出的每条结论末尾自动附加标准/法规溯源标注（形如 §5.X.X 或 GB/T XXX §X）。当产出报告、评审意见、方案设计需要可追溯时使用。"
  "foundation|pii-scan|🔍|medium|识别数据集/字段中的个人信息与敏感数据，按个保法与 GB/T 43697 输出敏感等级建议。当处理来源不明的数据、需要脱敏或分级前使用。"
  "foundation|data-classify|🗂️|low|按 GB/T 43697 输出数据的分级（一般/重要/核心）与分类（个人/公共/法人/衍生），并给出保护建议。当资产入库、跨境评估、共享披露前使用。"
  "foundation|metadata-extract|📋|low|从 DDL / OpenAPI / CSV 头 / Parquet 抽取结构化元数据（字段名/类型/约束/示例），符合 GB/T 40685 §6 的最小元数据集。当资产盘点、目录登记、血缘建立时使用。"
  "foundation|dq-6d-check|✅|low|按 GB/T 36344-2018 六性（完整/准确/一致/时效/唯一/合规）对数据集/表做质量画像，输出问题清单与优先级。当资产准入、上线前评审、周期性巡检时使用。"
  "foundation|sql-safe-explain|🛡️|medium|对 SQL 做静态分析：语法校验、全表扫描告警、注入风险识别、权限过大提示。当需要对模型/报表 SQL 做代码评审时使用。"
  "foundation|handoff-router|🔀|low|当当前问题跨出本岗位职责边界时，识别应转交的目标岗位并输出转交建议卡（含理由 + 目标 agent id + 上下文摘要）。所有 agent 应默认挂载。"
  "foundation|deliverable-templater|📐|low|从当前 agent 的角色 md \"交付物模板\"段落生成结构化骨架，避免手工重排。当用户请求某个可交付物但未提供模板时使用。"

  # ---- management (6) ----
  "management|asset-catalog-crud|📇|low|数据资产目录的增删改查，对齐 GB/T 40685-2021 的最小元数据集。当新增/下架/变更资产条目、批量导入台账时使用。"
  "management|dcmm-scoring|🏅|low|按 GB/T 36073-2018（DCMM）对组织在 8 大能力域上打五级分数（初始/受管理/稳健/量化/优化），并输出提升建议。当做能力评估、体系认证准备时使用。"
  "management|lineage-graph|🌳|low|查询/生成数据血缘图（表 → 表、字段 → 字段），支持影响分析与溯源分析。当质量事件根因定位、资产变更影响评估时使用。"
  "management|data-domain-mapping|🗺️|low|建立业务域 ↔ 数据域的双向映射，输出对齐表与冲突项。当组织架构调整、数据资产目录初建时使用。"
  "management|data-product-canvas|🖼️|low|数据产品画布（业务问题 → 数据组合 → 交付形态 → 定价与SLA），一屏产出。当规划新数据产品、上架前评审时使用。"
  "management|stakeholder-raci|👥|low|输出数据角色 RACI 矩阵（Responsible/Accountable/Consulted/Informed），明确权责边界。当治理体系搭建、跨部门协同前使用。"

  # ---- trading (5) ----
  "trading|listing-quality-scorer|🎯|low|挂牌数据产品的质量三维评分：完备性（元数据/样例/文档）、合规性（来源/PII/授权）、可交付性（接口/SLA/售后），输出总分与红旗项。当挂牌准入评审时使用。"
  "trading|deal-lifecycle-tracker|🔄|low|数据交易 9 步状态机（intake → matching → compliance → trial → pricing → contract → delivery → acceptance → maintenance），驱动流程推进与卡点提醒。经纪与产权类交易通用。"
  "trading|kyc-kyb-runner|🪪|medium|执行 KYC（个人）/ KYB（企业）检查清单：主体身份、证照、受益人、制裁名单、经营异常。当买卖双方入场前使用。"
  "trading|cross-border-checker|🌐|high|按数据出境安全评估办法与个保法判断数据出境是否触发申报/认证/合同标准。当涉及跨境数据流通、境外 IP 访问时使用。"
  "trading|contract-clause-library|📜|medium|三权分置合同关键条款库（持有权/加工使用权/产品经营权 × 转让/许可/入股）。当起草或审核数据类合同时使用。"

  # ---- role/dam-01 · 首席数据官 (3) ----
  "role/dam-01|data-strategy-canvas|🗺️|low|首席数据官视角的数据战略画布：愿景/北极星指标/关键结果/责任矩阵/预算/风险。当年度战略制定、董事会汇报前使用。"
  "role/dam-01|data-roi-model|💹|low|数据投入-产出 ROI 模型：投入（人/工具/合规）、产出（收入/降本/风控）、归因（因果 vs 相关）。当申请数据预算、复盘投入产出比时使用。"
  "role/dam-01|boardroom-brief|🎤|low|董事会数据议题简报（≤2 页，含形势/进展/风险/决策项）。当上会汇报前使用。"

  # ---- role/dam-02 · 数据资产规划师 (2) ----
  "role/dam-02|asset-planning-roadmap|🛣️|low|3 年数据资产建设路线图：里程碑 / 依赖关系 / 验收指标 / 资源需求。当年度规划、可研立项时使用。"
  "role/dam-02|capability-gap-analysis|📊|low|能力差距分析：当前 DCMM 等级 vs 目标等级，输出改进主题 + 优先级 + 投入估算。当规划升级路径时使用。"

  # ---- role/dam-03 · 数据资产确权师 ⭐ (3) ----
  "role/dam-03|three-rights-analyzer|⚖️|high|三权分置分析器：判定数据资源持有权 / 数据加工使用权 / 数据产品经营权的归属主体、举证要点、剥离方式。参照数据二十条。当确权咨询、合同起草前使用。"
  "role/dam-03|evidence-chain-builder|🔗|high|构建数据权属证据链：来源合法（合同/授权）+ 加工留痕（血缘/日志）+ 权属声明（登记/合同）。当申请数据资产登记、发生权属争议时使用。"
  "role/dam-03|registration-cert-drafter|📜|medium|数据资产登记证书草稿（面向地方数据交易所/知识产权中心）：主体/权能/范围/期限/附属证据。当申请登记前使用。"

  # ---- role/dam-04 · 数据资产安全合规师 (3) ----
  "role/dam-04|de-identification-toolkit|🎭|high|去标识化工具箱：k-匿名、l-多样性、差分隐私三类方案，含参数建议与效用评估。当发布/共享/交易前使用。"
  "role/dam-04|security-audit-checklist|🛡️|medium|数据安全审计检查表（分级分类/访问控制/审计日志/加密/备份/应急）。当年度审计、合规检查前使用。"
  "role/dam-04|incident-response-playbook|🚨|high|数据泄露应急响应剧本：72 小时时间线（识别/遏制/根除/恢复/告知）。当发生疑似泄露时使用。"

  # ---- role/dam-05 · 数据资产管理运营师 (3) ----
  "role/dam-05|asset-inventory-workbook|📓|low|数据资产盘点台账：域/系统/表/字段/责任人/等级/更新频率/血缘。当年度盘点、并购尽调、体系认证前使用。"
  "role/dam-05|inventory-diff|🔀|low|前后期盘点差异对比：新增/下线/变更/口径迁移，附影响面。当月度/季度对账时使用。"
  "role/dam-05|data-sharing-workflow|🤝|medium|内部数据共享工作流：申请 → 审批 → 发布 → 日志 → 审计。含分级授权与脱敏策略模板。当接入新消费方、新建共享渠道时使用。"

  # ---- role/dam-06 · 数据资产运营规划师 (3) ----
  "role/dam-06|data-product-plan|🖼️|low|数据产品季度/年度规划：商业目标 → 产品矩阵 → 路线图 → 运营投入 → KPI。当数据产品组合运营规划时使用。"
  "role/dam-06|pricing-tier-designer|💰|low|数据产品定价分层设计（订阅/按次/包月/阶梯），含毛利测算。当新品定价、老品调价时使用。"
  "role/dam-06|api-marketplace-config|🏪|low|API 集市上架配置：路径/参数/示例/限流/SLA/示例代码。当新数据产品上架、变更版本时使用。"

  # ---- role/dam-07 · 数据资产评估计价师 ⭐ (4) ----
  "role/dam-07|income-approach-calc|💵|high|数据资产收益法（DCF）估值计算：现金流预测、折现率选取、敏感性分析。参照 GB/T 42129-2022 §7.2。当估值报告需要收益法结论时使用。"
  "role/dam-07|cost-approach-calc|🧮|medium|数据资产成本法估值：历史成本 + 重置成本 + 贬值调整。当资产新建、缺乏可比市场数据时使用。"
  "role/dam-07|market-approach-lookup|📊|medium|市场法可比交易检索：从公开交易记录/交易所披露中匹配同类资产成交案例。当需要交叉验证估值结论时使用。"
  "role/dam-07|valuation-report-drafter|📄|medium|生成《数据资产评估报告》草稿：适用性说明 + 三法结果 + 敏感性 + 结论区间。当项目交付估值报告时使用。"

  # ---- role/dam-08 · 数据资产入表工程师 ⭐ (4) ----
  "role/dam-08|accounting-treatment-classifier|📚|high|数据资产会计处理判定：无形资产 / 存货 / 长期待摊费用，参照财会〔2023〕11 号。当资产入表科目落位时使用。"
  "role/dam-08|amortization-scheduler|📅|medium|数据资产摊销计划表（直线法 / 加速法），输出年度摊销与账面价值曲线。当入表后每年结账时使用。"
  "role/dam-08|measurement-model-selector|📐|high|计量模式选择器：历史成本/重置成本/公允价值/可变现净值四种模式的适用性判定。当初始确认与后续计量前使用。"
  "role/dam-08|initial-recognition-worksheet|📓|medium|初始确认工作底稿：可确认性判断 + 可靠计量 + 未来经济利益 + 成本归集明细。当新建数据资产入表时使用。"

  # ---- role/dam-09 · 数据资产入表保荐师 ⭐ (4) ----
  "role/dam-09|disclosure-note-drafter|📝|medium|财务附注中的数据资产披露段（会计政策、期初期末余额、变动原因）。当年报/半年报编制时使用。"
  "role/dam-09|audit-workpaper-builder|📋|medium|数据资产审计底稿模板（存在性/权属/计量/披露 四大认定）。当接受审计前使用。"
  "role/dam-09|sponsorship-opinion-letter|✍️|high|保荐意见书草稿：入表合规性 + 估值合理性 + 披露充分性 + 风险提示。面向监管/审计方。当入表报送前使用。"
  "role/dam-09|continuous-supervision-checklist|🔍|medium|持续督导清单（季度/年度）：使用量/收益/减值迹象/纠错事项。当入表后定期回顾时使用。"

  # ---- role/dam-10 · 数据信用管理师 (2) ----
  "role/dam-10|credit-policy-designer|⚖️|medium|数据信用体系政策设计：信用对象/信用产品/信用内容/额度/定价/风控。当搭建信用体系、发布信用产品前使用。"
  "role/dam-10|credit-red-lines|🚩|high|数据信用红线清单：造假嫌疑、来源违规、跨境未申报等一票否决项。当授信审批前使用。"

  # ---- role/dam-11 · 数据信用评价师 (3) ----
  "role/dam-11|credit-scorecard-builder|💳|medium|数据信用评分卡构建：以数据质量 + 主体信用 + 交易表现构建评分模型。当开展信用评价业务时使用。"
  "role/dam-11|credit-rating-committee|🏛️|medium|信用评级委员会流程与卡点：初评 → 复核 → 上会 → 完稿，含回避、异议处置、异议规则。当组织评级会时使用。"
  "role/dam-11|credit-report-drafter|📄|medium|信用评级报告草稿：主体画像 + 资产质量 + 评分结果 + 主要风险 + 展望。当对外输出评级结论时使用。"

  # ---- role/dat-01 · 数据交易规划师 (3) ----
  "role/dat-01|exchange-topology-designer|🏛️|low|数据交易所拓扑设计（挂牌区 / 撮合区 / 交割区 / 清算区 / 监管接入）。当交易所立项、扩展新品类时使用。"
  "role/dat-01|listing-category-designer|🗂️|low|挂牌品类设计：产品形态（数据集/API/报告/数据服务）× 领域（金融/医疗/交通……），附典型属性与上架需求。当设计挂牌目录时使用。"
  "role/dat-01|deal-mechanism-designer|⚙️|medium|交易机制设计（撮合 / 协议 / 招标 / 拍卖），含价格发现机制、担保交收、异常处置规则。当上线新交易品种时使用。"

  # ---- role/dat-02 · 数据交易安全合规师 (2) ----
  "role/dat-02|compliance-review-sheet|✅|high|合规评审意见书：主体资质 / 数据来源 / 处理链路 / 出境 / PII / 授权 一票通过。当交易上架前使用。"
  "role/dat-02|breach-response-sop|🚨|high|数据泄露应急 SOP（24h 通报 / 72h 报送 / 事后复盘 / 通知义务）。当发生疑似合规事件时使用。"

  # ---- role/dat-03 · 数据交易运营师 (3) ----
  "role/dat-03|growth-plan-quarterly|📈|low|季度平台运营计划（GMV / 供给 / 需求 / 生态活动 / 预算）。当季度启动前使用。"
  "role/dat-03|platform-metric-dashboard|📊|low|平台核心指标看板（GMV / 挂牌数 / 成交率 / 履约率 / NPS）。当日常运营监控、月度会议时使用。"
  "role/dat-03|campaign-retrospective|🎬|low|运营活动复盘模板（目标 / 执行 / 结果 / 归因 / 沉淀）。当活动结束时使用。"

  # ---- role/dat-04 · 数据交易分析师 (3) ----
  "role/dat-04|gmv-forecast-holt-winters|📈|medium|GMV 时序预测（Holt-Winters / Prophet），含季节性与置信区间。当季度目标制定、供需匹配预警时使用。"
  "role/dat-04|category-hotspot-detector|🔥|low|爆款品类识别：环比增速 + 首次上榜 + 交叉复购。当选品会、栏目运营时使用。"
  "role/dat-04|price-elasticity-model|💹|medium|价格弹性模型：估计需求对价格的敏感度，输出建议价区间。当调价决策前使用。"

  # ---- role/dat-05 · 数据交易经纪师 (3) ----
  "role/dat-05|deal-intake-form|📝|low|需求 intake 表单（业务问题 / 数据组合 / 预算 / 时限 / 授权范围）。当买方首次接触时使用。"
  "role/dat-05|matching-scorecard|🎯|low|供需匹配打分卡（覆盖度 / 时效性 / 价格 / 合规 / 售后），输出 Top-N 推荐。当为买方推送候选卖方时使用。"
  "role/dat-05|deal-9steps-checklist|✅|medium|9 步经纪流程 Checklist（intake → acceptance），每步含质量卡点与产出物。当推进单笔交易全流程时使用。"

  # ---- role/dat-06 · 数据产权交易师 ⭐ (3) ----
  "role/dat-06|three-rights-due-diligence|🔎|high|数据产权尽调：三权归属核查 + 权利瑕疵扫描 + 证据链完整性。当产权类交易立项时使用。"
  "role/dat-06|deal-structuring-3paths|🏗️|high|三条路径结构方案：全部转让 / 独家许可 / 作价入股，含税务与治理影响对比。当产权交易方案设计时使用。"
  "role/dat-06|contract-key-clauses|📜|high|产权交易合同关键条款清单：标的界定 / 权利范围 / 对价 / 陈述保证 / 违约救济 / 争议解决。当合同起草与审核时使用。"
)

# ------------------------------------------------------------------------------
# 挂载映射：agent-id → skill 全名（scope/name）
# 未在此列出但存在于 role/<agent-id>/ 下的 skill 自动挂载给该 agent
# 注意：macOS 默认 bash 3.2 不支持关联数组，改用 case 查表
# ------------------------------------------------------------------------------
# 所有 agent 默认挂载全部 foundation
ALL_AGENTS=(dam-01 dam-02 dam-03 dam-04 dam-05 dam-06 dam-07 dam-08 dam-09 dam-10 dam-11 dat-01 dat-02 dat-03 dat-04 dat-05 dat-06)

# ------------------------------------------------------------------------------
# 角色 slug：agent-id → 英文 slug（与 agents/**/*.md 命名一致）
# 目录不再使用 id，而使用可读的英文 slug
# ------------------------------------------------------------------------------
slug_for() {
  case "$1" in
    dam-01) echo "chief-data-officer" ;;
    dam-02) echo "data-asset-planner" ;;
    dam-03) echo "data-asset-registration-specialist" ;;
    dam-04) echo "data-asset-security-compliance" ;;
    dam-05) echo "data-asset-operations" ;;
    dam-06) echo "data-asset-operations-planner" ;;
    dam-07) echo "data-asset-appraiser" ;;
    dam-08) echo "data-asset-accounting-engineer" ;;
    dam-09) echo "data-asset-sponsor" ;;
    dam-10) echo "data-credit-manager" ;;
    dam-11) echo "data-credit-appraiser" ;;
    dat-01) echo "data-trading-planner" ;;
    dat-02) echo "data-trading-compliance" ;;
    dat-03) echo "data-trading-operator" ;;
    dat-04) echo "data-trading-analyst" ;;
    dat-05) echo "data-trading-broker" ;;
    dat-06) echo "data-property-broker" ;;
    *) echo "$1" ;;
  esac
}

# 将逻辑 scope（如 role/dam-01）转为物理 scope（如 role/chief-data-officer）
# 非 role/* 直接原样返回
physical_scope() {
  local s="$1"
  if [[ "$s" == role/* ]]; then
    local aid="${s#role/}"
    echo "role/$(slug_for "$aid")"
  else
    echo "$s"
  fi
}

# 方向共用 skill 的挂载表：输入 "scope/name"，返回空格分隔的 agent id
# 已根据实际 roster调整：
#   dam-03 确权师 / dam-04 安合师 / dam-05 管理运营 / dam-06 运营规划
#   dam-07 评估师 / dam-08 入表工程 / dam-09 入表保荐 / dam-10 信用管理 / dam-11 信用评价
#   dat-01 交易规划
extra_mounts_for() {
  case "$1" in
    "management/asset-catalog-crud")     echo "dam-02 dam-05 dam-06" ;;
    "management/dcmm-scoring")           echo "dam-01 dam-02" ;;
    "management/lineage-graph")          echo "dam-03 dam-05 dam-08" ;;
    "management/data-domain-mapping")    echo "dam-02 dam-05" ;;
    "management/data-product-canvas")    echo "dam-02 dam-06" ;;
    "management/stakeholder-raci")       echo "dam-01 dam-02" ;;
    "trading/listing-quality-scorer")    echo "dat-01 dat-03 dat-05" ;;
    "trading/deal-lifecycle-tracker")    echo "dat-05 dat-06" ;;
    "trading/kyc-kyb-runner")            echo "dat-02 dat-05" ;;
    "trading/cross-border-checker")      echo "dat-02 dam-04" ;;
    "trading/contract-clause-library")   echo "dat-02 dat-05 dat-06" ;;
    *) echo "" ;;
  esac
}

# ------------------------------------------------------------------------------
# 生成 SKILL.md 骨架
# ------------------------------------------------------------------------------
gen_skill_md() {
  local scope="$1" name="$2" emoji="$3" risk="$4" desc="$5"
  local pscope
  pscope="$(physical_scope "$scope")"
  local skill_dir="$SKILLS_DIR/$pscope/$name"
  mkdir -p "$skill_dir"

  local mounted_by="[]"
  if [[ "$scope" == "foundation" ]]; then
    mounted_by="[$(printf '"%s", ' "${ALL_AGENTS[@]}" | sed 's/, $//')]"
  elif [[ "$scope" == role/* ]]; then
    local aid="${scope#role/}"
    mounted_by="[\"$aid\"]"
  else
    local mv
    mv="$(extra_mounts_for "$scope/$name")"
    if [[ -n "$mv" ]]; then
      mounted_by="[$(printf '"%s", ' $mv | sed 's/, $//')]"
    fi
  fi

  cat > "$skill_dir/SKILL.md" <<EOF
---
name: ${name}
description: >-
  ${desc}
license: Apache-2.0
metadata:
  scope: ${pscope}
  mounted_by: ${mounted_by}
  standard_ref: []
  risk: ${risk}
  openclaw:
    emoji: "${emoji}"
    homepage: https://github.com/kukuyuhai/agentic-data-element
---

# ${emoji} ${name}

<!-- TODO: 完善正文；参考规范 https://agentskills.io/specification -->

## When to Use

${desc}

## Inputs

- \`todo\`: TODO 待补充输入契约（字段/类型/示例）

## Outputs

- \`todo\`: TODO 待补充输出契约（字段/类型/示例）

## Steps

1. TODO 待补充执行步骤
2. 每条能力性判断末尾附标准溯源标注（形如 \`§5.X.X\`）
3. 命中他岗职责时调用 \`foundation/handoff-router\` 转交

## References

- 项目内：[skills-catalog.md](../../../docs/skills-catalog.md)
- 规范：[Anthropic Agent Skills](https://agentskills.io/specification) · [OpenClaw](https://docs.openclaw.ai/clawhub/skill-format)
EOF
}

log "生成 skills/ 骨架（${#SKILLS[@]} 个 skill）"

for entry in "${SKILLS[@]}"; do
  IFS='|' read -r scope name emoji risk desc <<< "$entry"
  gen_skill_md "$scope" "$name" "$emoji" "$risk" "$desc"
done

# ------------------------------------------------------------------------------
# 输出 manifest.json（扁平）与 mount-map.json（agent → skills[]）
# ------------------------------------------------------------------------------
gen_manifest() {
  local out="$SKILLS_DIR/manifest.json"
  {
    echo "["
    local first=1
    for entry in "${SKILLS[@]}"; do
      IFS='|' read -r scope name emoji risk desc <<< "$entry"
      [[ $first -eq 0 ]] && echo "  ,"
      first=0
      local pscope
      pscope="$(physical_scope "$scope")"
      # 转义 JSON 中的双引号
      local desc_esc="${desc//\"/\\\"}"
      cat <<EOF
  {
    "name": "$name",
    "scope": "$pscope",
    "path": "skills/$pscope/$name/SKILL.md",
    "emoji": "$emoji",
    "risk": "$risk",
    "description": "$desc_esc"
  }
EOF
    done
    echo "]"
  } > "$out"
  ok "已生成 ${out}（${#SKILLS[@]} 条）"
}

gen_mount_map() {
  local out="$SKILLS_DIR/mount-map.json"
  # bash 3.2 无关联数组：用临时文件累积 <agent>\t<skill-full-name> 行
  local pairs
  pairs="$SKILLS_DIR/.mount-pairs.tmp"
  : > "$pairs"
  trap 'rm -f "$pairs"' RETURN

  for entry in "${SKILLS[@]}"; do
    IFS='|' read -r scope name emoji risk desc <<< "$entry"
    local pscope
    pscope="$(physical_scope "$scope")"
    local full="$pscope/$name"
    if [[ "$scope" == "foundation" ]]; then
      for a in "${ALL_AGENTS[@]}"; do printf "%s\t%s\n" "$a" "$full" >> "$pairs"; done
    elif [[ "$scope" == role/* ]]; then
      # 从逻辑 scope 提取 aid（而非 slug）作为 mount-map key
      local aid="${scope#role/}"
      printf "%s\t%s\n" "$aid" "$full" >> "$pairs"
    else
      local mv
      mv="$(extra_mounts_for "$scope/$name")"
      for a in $mv; do printf "%s\t%s\n" "$a" "$full" >> "$pairs"; done
    fi
  done

  {
    echo "{"
    local first=1
    for a in "${ALL_AGENTS[@]}"; do
      [[ $first -eq 0 ]] && echo "  ,"
      first=0
      # 取属于 agent $a 的所有 skill
      local skills_for_a
      skills_for_a="$(awk -v A="$a" -F'\t' '$1==A {print $2}' "$pairs" | tr '\n' ' ')"
      local arr=""
      if [[ -n "$skills_for_a" ]]; then
        arr=$(printf '"%s", ' $skills_for_a | sed 's/, $//')
      fi
      cat <<EOF
  "$a": [$arr]
EOF
    done
    echo "}"
  } > "$out"
  ok "已生成 ${out}（${#ALL_AGENTS[@]} 个 agent 的挂载表）"
}

gen_manifest
gen_mount_map

ok "完成：共 ${#SKILLS[@]} 个 SKILL.md 骨架已写入 $SKILLS_DIR"
dim "下一步：./install.sh openclaw 会自动读取 mount-map.json 并注入 skills 字段"
