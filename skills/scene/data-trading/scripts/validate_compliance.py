#!/usr/bin/env python3
"""
数据产品挂牌合规前置验证脚本

验证五大硬性条件和其他合规要素，输出通过/不通过结论和整改建议。
"""

import json
import sys
from typing import Dict, List, Tuple


# 五大硬性条件定义
HARD_CONDITIONS = {
    "C1": {
        "name": "来源合法",
        "question": "数据是否为企业自身经营产生或通过合法渠道获取？（非爬虫窃取/黑市/侵权）",
        "critical": True,
    },
    "C2": {
        "name": "深度脱敏",
        "question": "是否已完成深度脱敏，剔除所有个人敏感信息和商业秘密？（不可反向定位）",
        "critical": True,
    },
    "C3": {
        "name": "权属清晰",
        "question": "数据权属是否清晰？是否完成确权登记？个人数据是否有用户授权？",
        "critical": True,
    },
    "C4": {
        "name": "质量达标",
        "question": "数据质量是否达标？（完整性、准确性、时效性、一致性）",
        "critical": False,
    },
    "C5": {
        "name": "明确场景",
        "question": "是否有明确的应用场景、使用范围和使用期限？",
        "critical": False,
    },
}

# 附加检查项
ADDITIONAL_CHECKS = {
    "A1": {
        "name": "重要数据识别",
        "question": "是否涉及重要数据？若涉及，是否已完成主管部门审批？",
        "action": "涉及重要数据需完成识别备案和主管部门审批。",
    },
    "A2": {
        "name": "跨境审查",
        "question": "是否涉及数据出境？若涉及，是否已完成安全评估或标准合同备案？",
        "action": "涉及出境的需完成安全评估或标准合同备案。",
    },
    "A3": {
        "name": "个人信息合规",
        "question": "若涉及个人信息，是否已取得用户授权并完成PIA？",
        "action": "涉及个人信息的需取得用户明确同意，完成个人信息保护影响评估。",
    },
    "A4": {
        "name": "AI训练合规",
        "question": "若用于AI训练，是否完成标注合规审查和版权审查？",
        "action": "用于AI训练的数据需确保标注规范性并审查版权合规性。",
    },
}


def validate(response: Dict[str, str]) -> Tuple[bool, List[dict]]:
    """验证合规性，返回 (通过/不通过, 结果列表)"""

    results = []
    all_pass = True

    # 检查五大硬性条件
    for key, cond in HARD_CONDITIONS.items():
        answer = response.get(key, "").lower()
        passed = answer in ("y", "yes", "是", "true", "pass", "通过")

        if cond["critical"]:
            # Critical: 不通过则直接终止
            if not passed:
                all_pass = False
                results.append({
                    "code": key,
                    "name": cond["name"],
                    "level": "CRITICAL",
                    "passed": False,
                    "question": cond["question"],
                    "suggestion": f"❌ 「{cond['name']}」不满足。此项为一票否决条件，必须通过才能继续。",
                })
            else:
                results.append({
                    "code": key,
                    "name": cond["name"],
                    "level": "CRITICAL",
                    "passed": True,
                    "question": cond["question"],
                    "suggestion": "",
                })
        else:
            # Non-critical: 不通过则要求整改
            if not passed:
                results.append({
                    "code": key,
                    "name": cond["name"],
                    "level": "IMPORTANT",
                    "passed": False,
                    "question": cond["question"],
                    "suggestion": f"⚠️ 「{cond['name']}」不满足。此项需整改后才能挂牌。",
                })
            else:
                results.append({
                    "code": key,
                    "name": cond["name"],
                    "level": "IMPORTANT",
                    "passed": True,
                    "question": cond["question"],
                    "suggestion": "",
                })

    # 检查附加项
    for key, check in ADDITIONAL_CHECKS.items():
        answer = response.get(key, "").lower()
        needs_attention = answer in ("y", "yes", "是", "true")

        if needs_attention:
            results.append({
                "code": key,
                "name": check["name"],
                "level": "SUPPLEMENTARY",
                "passed": False if response.get(f"{key}_compliant", "").lower() not in ("y", "yes", "是", "true") else True,
                "question": check["question"],
                "suggestion": f"📌 「{check['name']}」需要特别关注。{check['action']}",
            })

    return all_pass, results


def print_results(all_pass: bool, results: List[dict]):
    """打印验证结果"""

    print("\n" + "=" * 60)
    print("  数据产品挂牌前置合规验证结果")
    print("=" * 60)

    critical_count = sum(1 for r in results if r["level"] == "CRITICAL" and not r["passed"])
    important_count = sum(1 for r in results if r["level"] == "IMPORTANT" and not r["passed"])

    if all_pass and important_count == 0:
        print("\n✅ 全部硬性条件通过！可以推进交易准备。\n")
    else:
        print(f"\n❌ 存在 {critical_count} 项严重问题和 {important_count} 项待整改事项。")

    print("-" * 60)
    for r in results:
        status = "✅ PASS" if r["passed"] else "❌ FAIL"
        print(f"  [{r['level']:>12}] {r['code']} {r['name']:　<6}  {status}")
        if r["suggestion"]:
            print(f"                    {r['suggestion']}")
    print("-" * 60)

    if critical_count > 0:
        print("\n🔴 结论：存在严重不合规项，暂不具备挂牌条件。请先解决上述 CRITICAL 级别问题。\n")
    elif important_count > 0:
        print("\n🟡 结论：基本条件满足，但存在待整改事项。建议整改后再推进挂牌。\n")
    else:
        print("\n🟢 结论：合规前置审查通过。可进入下一步（选择交易所、准备挂牌材料）。\n")


def interactive():
    """交互式验证"""

    print("\n📋 数据产品挂牌前置合规验证")
    print("   请回答以下问题（y/n/是/否）:\n")

    responses = {}

    print("--- 五大硬性条件 ---")
    for key, cond in HARD_CONDITIONS.items():
        answer = input(f"  [{key}] {cond['name']}: {cond['question']} ").strip()
        responses[key] = answer

    print("\n--- 附加检查 ---")
    for key, check in ADDITIONAL_CHECKS.items():
        answer = input(f"  [{key}] {check['name']}: {check['question']} ").strip()
        responses[key] = answer
        if answer.lower() in ("y", "yes", "是", "true"):
            compliant = input(f"         → 相关合规要求是否已完成？(y/n) ").strip()
            responses[f"{key}_compliant"] = compliant

    all_pass, results = validate(responses)
    print_results(all_pass, results)


def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "--json":
            # JSON 批量模式
            data = json.load(sys.stdin)
            responses = data if isinstance(data, dict) else {}
            all_pass, results = validate(responses)
            print_results(all_pass, results)
        elif sys.argv[1] == "--help":
            print("使用方法：")
            print("  交互模式:  python validate_compliance.py")
            print("  JSON模式:  echo '{...}' | python validate_compliance.py --json")
            print()
            print("JSON 支持的字段：")
            print("  C1-C5: y/n    五大硬性条件")
            print("  A1-A4: y/n    附加检查项")
            print("  A1_compliant-A4_compliant: y/n    附加项合规完成情况")
        else:
            interactive()
    else:
        interactive()


if __name__ == "__main__":
    main()
