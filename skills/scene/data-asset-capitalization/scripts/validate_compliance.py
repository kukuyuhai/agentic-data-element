#!/usr/bin/env python3
"""
数据资产入表合规前置条件验证脚本

根据《企业数据资源相关会计处理暂行规定》（财会〔2023〕11号）和相关会计准则，
对企业数据资产入表的前提条件进行自动化检查。

用法:
    python validate_compliance.py                          # 交互式问卷
    python validate_compliance.py --json input.json        # 从JSON文件读取
    python validate_compliance.py --output report.md       # 输出报告到文件
"""

import json
import sys
from pathlib import Path

# 合规检查项定义
CHECKS = {
    "legality": {
        "name": "数据来源合法性",
        "weight": "critical",
        "questions": [
            {
                "id": "L1",
                "question": "数据采集是否获得合法授权？（用户同意/合同/法律依据）",
                "pass_condition": "yes",
                "fail_message": "数据来源缺乏合法授权，不符合入表前提条件。建议：先完成授权文件的整理和审查。"
            },
            {
                "id": "L2",
                "question": "是否涉及个人敏感信息？",
                "pass_condition": "no_or_consent",
                "fail_message": "涉及个人敏感信息但未取得单独明示同意。建议：取得用户明示同意，或对数据进行脱敏处理。"
            },
            {
                "id": "L3",
                "question": "数据采集是否符合'最小必要'原则？",
                "pass_condition": "yes",
                "fail_message": "采集范围超出必要限度，存在合规风险。建议：重新评估采集范围。"
            },
            {
                "id": "L4",
                "question": "是否涉及国家秘密或核心数据？",
                "pass_condition": "no",
                "fail_message": "涉及国家秘密或核心数据，不可入表。此类数据不满足资产确认条件。"
            },
            {
                "id": "L5",
                "question": "跨境数据传输是否已完成合规程序？（安全评估/标准合同/认证）",
                "pass_condition": "yes_or_not_applicable",
                "fail_message": "跨境数据传输未完成合规程序。建议：完成数据出境安全评估或标准合同备案。"
            },
        ]
    },
    "ownership": {
        "name": "数据权属",
        "weight": "critical",
        "questions": [
            {
                "id": "O1",
                "question": "企业是否对该数据资源拥有合法权利？（持有权/使用权/经营权至少一项）",
                "pass_condition": "yes",
                "fail_message": "企业对该数据资源缺乏合法权利，不满足资产确认的'拥有或控制'条件。"
            },
            {
                "id": "O2",
                "question": "是否存在数据权属争议或潜在纠纷？",
                "pass_condition": "no",
                "fail_message": "存在权属争议，资产确认存在重大不确定性。建议：先解决权属纠纷。"
            },
            {
                "id": "O3",
                "question": "合作/委托开发数据的权属约定是否明确（有书面合同）？",
                "pass_condition": "yes_or_not_applicable",
                "fail_message": "合作数据权属约定不明确，可能导致未来纠纷。建议：补充签订权属协议。"
            },
        ]
    },
    "asset_recognition": {
        "name": "资产确认条件",
        "weight": "critical",
        "questions": [
            {
                "id": "A1",
                "question": "该数据资源预期是否能为企业带来未来经济利益？",
                "pass_condition": "yes",
                "fail_message": "无法证明能为企业带来未来经济利益，不满足资产确认条件。"
            },
            {
                "id": "A2",
                "question": "该数据资源的取得/形成成本是否能够可靠计量？",
                "pass_condition": "yes",
                "fail_message": "成本无法可靠计量，不满足资产确认条件。建议：建立成本核算体系。"
            },
            {
                "id": "A3",
                "question": "该数据资源是否可与企业其他资产明确区分？",
                "pass_condition": "yes",
                "fail_message": "无法单独识别和管理，不符合资产的可辨认性要求。"
            },
        ]
    },
    "cost_accounting": {
        "name": "成本核算",
        "weight": "important",
        "questions": [
            {
                "id": "C1",
                "question": "是否建立了资本化与费用化的划分标准？",
                "pass_condition": "yes",
                "fail_message": "缺乏资本化/费用化标准，容易导致账务处理混乱。建议：参照暂行规定建立内部标准。"
            },
            {
                "id": "C2",
                "question": "成本归集是否有原始凭证支撑？（合同/发票/工时记录等）",
                "pass_condition": "yes",
                "fail_message": "缺乏原始凭证，成本数据缺乏可靠性。建议：补全相关凭证。"
            },
            {
                "id": "C3",
                "question": "共同成本的分摊方法是否合理且有依据？",
                "pass_condition": "yes_or_not_applicable",
                "fail_message": "共同成本分摊缺乏合理依据。建议：按实际使用量、工时等标准建立分摊方法。"
            },
        ]
    },
    "accounting_treatment": {
        "name": "会计处理准备",
        "weight": "important",
        "questions": [
            {
                "id": "T1",
                "question": "是否确定了资产的分类？（无形资产/存货）",
                "pass_condition": "yes",
                "fail_message": "未确定资产分类，无法进行后续会计处理。建议：根据数据用途确定分类。"
            },
            {
                "id": "T2",
                "question": "是否确定了合理的摊销年限和摊销方法？",
                "pass_condition": "yes",
                "fail_message": "未确定摊销政策。建议：根据数据时效性和业务周期确定。"
            },
            {
                "id": "T3",
                "question": "是否建立了减值测试的机制和频率？",
                "pass_condition": "yes",
                "fail_message": "缺乏减值测试机制。建议：建立至少每年一次的减值测试制度。"
            },
        ]
    },
}


def run_interactive():
    """交互式问卷模式"""
    print("=" * 60)
    print("  数据资产入表合规前置条件验证")
    print("  依据：《企业数据资源相关会计处理暂行规定》（财会〔2023〕11号）")
    print("=" * 60)
    print()
    print("请逐项回答以下问题（输入 y=是 / n=否 / na=不适用）：")
    print()

    results = {}
    total_checks = 0
    passed = 0
    critical_fails = []

    for section_key, section in CHECKS.items():
        print(f"\n{'─' * 50}")
        print(f"【{section['name']}】（重要度：{section['weight']}）")
        print(f"{'─' * 50}")
        section_passed = 0

        for q in section["questions"]:
            total_checks += 1
            while True:
                answer = input(f"  {q['question']}\n  [y/n/na]: ").strip().lower()
                if answer in ('y', 'n', 'na'):
                    break
                print("  请输入 y（是）、n（否）或 na（不适用）")

            condition = q["pass_condition"]
            is_pass = False
            if condition == "yes":
                is_pass = answer == 'y'
            elif condition == "no":
                is_pass = answer == 'n'
            elif condition == "no_or_consent":
                is_pass = answer in ('n', 'na')
            elif condition == "yes_or_not_applicable":
                is_pass = answer in ('y', 'na')

            results[q["id"]] = {
                "question": q["question"],
                "answer": answer,
                "passed": is_pass,
                "section": section["name"],
                "weight": section["weight"],
                "fail_message": q["fail_message"] if not is_pass else None,
            }

            if is_pass:
                section_passed += 1
                print(f"    ✅ 通过")
            else:
                print(f"    ❌ 未通过 - {q['fail_message']}")
                if section["weight"] == "critical":
                    critical_fails.append(q["id"])

        passed += section_passed

    # 生成报告
    print_report(results, total_checks, passed, critical_fails)
    return results


def run_from_json(filepath):
    """从JSON文件读取答案"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    results = {}
    total_checks = 0
    passed = 0
    critical_fails = []

    for section_key, section in CHECKS.items():
        for q in section["questions"]:
            total_checks += 1
            answer = data.get(q["id"], "n").lower()

            if answer not in ('y', 'n', 'na'):
                answer = 'n'

            condition = q["pass_condition"]
            is_pass = False
            if condition == "yes":
                is_pass = answer == 'y'
            elif condition == "no":
                is_pass = answer == 'n'
            elif condition == "no_or_consent":
                is_pass = answer in ('n', 'na')
            elif condition == "yes_or_not_applicable":
                is_pass = answer in ('y', 'na')

            results[q["id"]] = {
                "question": q["question"],
                "answer": answer,
                "passed": is_pass,
                "section": section["name"],
                "weight": section["weight"],
                "fail_message": q["fail_message"] if not is_pass else None,
            }

            if is_pass:
                passed += 1
            elif section["weight"] == "critical":
                critical_fails.append(q["id"])

    print_report(results, total_checks, passed, critical_fails)
    return results


def print_report(results, total_checks, passed, critical_fails, output_file=None):
    """生成并输出合规验证报告"""
    overall_grade = "PASS" if len(critical_fails) == 0 else "FAIL"
    pass_rate = (passed / total_checks * 100) if total_checks > 0 else 0

    lines = []
    lines.append("")
    lines.append("=" * 60)
    lines.append("  数据资产入表合规前置条件验证报告")
    lines.append("=" * 60)
    lines.append("")
    lines.append(f"  总体结论：{'✅ 通过' if overall_grade == 'PASS' else '❌ 未通过'}")
    lines.append(f"  通过率：{passed}/{total_checks}（{pass_rate:.0f}%）")
    lines.append(f"  关键失败项：{len(critical_fails)} 项")
    lines.append("")

    # 按类别汇总
    lines.append("─" * 50)
    lines.append("  分类汇总")
    lines.append("─" * 50)
    for section_key, section in CHECKS.items():
        section_results = [r for rid, r in results.items()
                           if r["section"] == section["name"]]
        section_passed = sum(1 for r in section_results if r["passed"])
        status = "✅" if section_passed == len(section_results) else "⚠️" if section_passed > 0 else "❌"
        lines.append(f"  {status} {section['name']}：{section_passed}/{len(section_results)} 通过")

    # 未通过项目详情
    failed_items = [(rid, r) for rid, r in results.items() if not r["passed"]]
    if failed_items:
        lines.append("")
        lines.append("─" * 50)
        lines.append("  需整改项目")
        lines.append("─" * 50)
        for idx, (rid, r) in enumerate(failed_items, 1):
            lines.append(f"  {idx}. [{r['weight']}] {r['question']}")
            lines.append(f"     建议：{r['fail_message']}")
            lines.append("")

    if overall_grade == "PASS":
        lines.append("")
        lines.append("  ✅ 所有关键条件已满足，可以启动数据资产入表工作。")
        lines.append("  建议继续完成《成本归集与计量工作底稿》和《合规审核清单》。")
    else:
        lines.append("")
        lines.append("  ❌ 存在关键条件未满足，建议暂缓入表，先解决上述问题。")
        lines.append("  完成整改后可重新运行本验证脚本。")

    report = "\n".join(lines)
    print(report)

    if output_file:
        Path(output_file).write_text(report, encoding='utf-8')
        print(f"\n报告已保存至：{output_file}")

    return report


if __name__ == "__main__":
    output_file = None

    # 解析命令行参数
    args = sys.argv[1:]
    if "--help" in args:
        print(__doc__)
        sys.exit(0)

    if "--json" in args:
        idx = args.index("--json")
        if idx + 1 < len(args):
            json_file = args[idx + 1]
            if "--output" in args:
                out_idx = args.index("--output")
                if out_idx + 1 < len(args):
                    output_file = args[out_idx + 1]
            run_from_json(json_file)
            sys.exit(0)

    if "--output" in args:
        idx = args.index("--output")
        if idx + 1 < len(args):
            output_file = args[idx + 1]

    run_interactive()

    if output_file:
        print(f"\n报告已保存至：{output_file}")
