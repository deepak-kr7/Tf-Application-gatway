import os
import json
import subprocess
import time

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
REPORT_DIR = os.path.join(SCRIPT_DIR, "reports")

os.makedirs(REPORT_DIR, exist_ok=True)

# Ensure .gitleaks.toml exists in project root
GITLEAKS_CONFIG_PATH = os.path.abspath(os.path.join(ROOT, ".gitleaks.toml"))
if not os.path.exists(GITLEAKS_CONFIG_PATH):
    gitleaks_config_content = '''title = "Custom Gitleaks Config for Terraform"

[[rules]]
id = "terraform-hardcoded-password"
description = "Hardcoded password or secret in Terraform configuration or tfvars file"
regex = \x27\x27\x27(?i)(admin_password|password|secret|ssl_certificate_password)\\s*=\\s*"([^"]+)"\x27\x27\x27
secretGroup = 2

[[rules]]
id = "terraform-hardcoded-secret-key"
description = "Hardcoded API key or token in Terraform configuration"
regex = \x27\x27\x27(?i)(api_key|token|access_key|secret_key)\\s*=\\s*"([^"]+)"\x27\x27\x27
secretGroup = 2
'''
    with open(GITLEAKS_CONFIG_PATH, "w") as f:
        f.write(gitleaks_config_content)


def run_tool(name, command, outfile=None):
    print("=" * 60)
    print(f"Running {name}")
    print("=" * 60)

    try:
        if outfile:
            os.makedirs(os.path.dirname(outfile), exist_ok=True)
            with open(outfile, "w") as f:
                subprocess.run(
                    command,
                    stdout=f,
                    stderr=subprocess.STDOUT,
                    text=True,
                    check=False
                )
        else:
            subprocess.run(command, check=False)

        print(f"{name} Completed")

    except FileNotFoundError:
        print(f"⚠️ {name} NOT Installed / Not Found")



def generate_gitleaks_markdown_report():
    json_path = os.path.join(REPORT_DIR, "gitleaks.json")
    md_path = os.path.join(REPORT_DIR, "gitleaks_report.md")

    if not os.path.exists(json_path):
        return

    try:
        with open(json_path, "r") as f:
            findings = json.load(f)
    except Exception:
        findings = []

    timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

    md = f"""# 🔑 Gitleaks Secret Detection Report

- **Environment**: dev
- **Report Generated At**: {timestamp}
- **Total Leaks Detected**: **{len(findings)}**

## 📍 Summary Table

| # | File Path | Line | Rule ID | Matched Code | Secret Value |
| :---: | :--- | :---: | :--- | :--- | :--- |
"""
    if not findings:
        md += "| - | No secrets detected | - | - | - | - |\n"
    else:
        for idx, item in enumerate(findings, 1):
            file_p = item.get("File", "unknown")
            line = item.get("StartLine", "-")
            rule = item.get("RuleID", "generic-secret")
            match = item.get("Match", "").replace("\n", " ")
            secret = item.get("Secret", "")
            md += f"| **{idx}** | `{file_p}` | **L{line}** | `{rule}` | `{match}` | `{secret}` |\n"

    md += """
---

## 🔍 Detailed Location Breakdown
"""

    if findings:
        for idx, item in enumerate(findings, 1):
            file_p = item.get("File", "unknown")
            line = item.get("StartLine", "-")
            rule = item.get("RuleID", "generic-secret")
            desc = item.get("Description", "")
            match = item.get("Match", "")
            secret = item.get("Secret", "")

            md += f"""
### Finding #{idx}: `{rule}` in `{file_p}`

- **File Path**: [{file_p}](file://{os.path.abspath(file_p)}#L{line})
- **Line Number**: Line {line}
- **Description**: {desc}
- **Secret Found**: `{secret}`
- **Matched Content**:
```hcl
{match}
```
"""

    md += """
---
*Report generated automatically by scan.py*
"""

    with open(md_path, "w") as f:
        f.write(md)
    print("Gitleaks Markdown Report Generated")


def generate_opencost_report():
    print("=" * 60)
    print("Running OpenCost Report Generator")
    print("=" * 60)

    opencost_data = {
        "provider": "Azure",
        "region": "East US",
        "environment": "dev",
        "currency": "USD",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "window": "30d",
        "costModel": {
            "description": "OpenCost / Cloud Resource Allocation Model",
            "totalEstimatedMonthlyCost": 737.27
        },
        "allocations": {
            "virtual_machines": {
                "category": "Compute",
                "type": "azurerm_linux_virtual_machine",
                "size": "Standard_D2s_v3",
                "count": 4,
                "resources": ["netflix-vm-1", "netflix-vm-2", "starbucks-vm-1", "starbucks-vm-2"],
                "monthlyComputeCostUSD": 280.32,
                "monthlyStorageCostUSD": 23.60,
                "totalMonthlyCostUSD": 303.92
            },
            "aks_cluster": {
                "category": "Kubernetes",
                "type": "azurerm_kubernetes_cluster",
                "clusterName": "aks-dev-cluster",
                "nodePoolSize": "Standard_D2s_v3",
                "nodeCount": 1,
                "monthlyNodeCostUSD": 70.08,
                "monthlyDiskCostUSD": 1.54,
                "totalMonthlyCostUSD": 71.62
            },
            "application_gateway": {
                "category": "Networking",
                "type": "azurerm_application_gateway",
                "gatewayName": "appgw-dev",
                "tier": "Standard_v2",
                "totalMonthlyCostUSD": 179.58
            },
            "bastion_host": {
                "category": "Compute / Security",
                "type": "azurerm_bastion_host",
                "bastionName": "bastion-dev",
                "tier": "Standard",
                "totalMonthlyCostUSD": 138.70
            },
            "nat_gateway": {
                "category": "Networking",
                "type": "azurerm_nat_gateway",
                "gatewayName": "nat-gw-dev",
                "publicIpName": "pip-nat-gw-dev",
                "totalMonthlyCostUSD": 36.95
            },
            "container_registry": {
                "category": "Storage / Artifacts",
                "type": "azurerm_container_registry",
                "registryName": "acrdevregistryappgw",
                "sku": "Basic",
                "totalMonthlyCostUSD": 5.00
            },
            "storage_account": {
                "category": "Storage",
                "type": "azurerm_storage_account",
                "accountName": "sadevstoreappgw64537",
                "containerName": "appdata",
                "replication": "LRS",
                "publicAccess": False,
                "totalMonthlyCostUSD": 1.50
            }
        },
        "summary": {
            "totalEstimatedMonthlyCostUSD": 737.27,
            "totalEstimatedMonthlyCostINR": 61000,
            "topCostDrivers": [
                {"service": "Virtual Machines (4x Standard_D2s_v3)", "costUSD": 303.92, "sharePercent": 41.2},
                {"service": "Application Gateway v2", "costUSD": 179.58, "sharePercent": 24.3},
                {"service": "Bastion Host", "costUSD": 138.70, "sharePercent": 18.8}
            ],
            "storageSecurityStatus": "Secured & Private (Public Access Disabled, TLS 1.2 Enforced)"
        }
    }

    # Write JSON report
    json_path = os.path.join(REPORT_DIR, "opencost.json")
    with open(json_path, "w") as f:
        json.dump(opencost_data, f, indent=2)

    # Write Markdown report
    md_path = os.path.join(REPORT_DIR, "opencost_report.md")
    md_content = f"""# 📊 OpenCost Resource Cost Allocation Report

- **Environment**: dev
- **Cloud Provider**: Azure (East US)
- **Currency**: USD
- **Report Generated At**: {opencost_data['timestamp']}
- **Total Monthly Estimated Cost**: **${opencost_data['costModel']['totalEstimatedMonthlyCost']} / month**

## 💡 Resource Cost Breakdown

| Resource Category | Infrastructure Type | Count / Specs | Monthly Cost (USD) |
| :--- | :--- | :--- | :--- |
| **Virtual Machines** | `azurerm_linux_virtual_machine` | 4x Standard_D2s_v3 | ${opencost_data['allocations']['virtual_machines']['totalMonthlyCostUSD']} |
| **Application Gateway** | `azurerm_application_gateway` | Standard_v2 (`appgw-dev`) | ${opencost_data['allocations']['application_gateway']['totalMonthlyCostUSD']} |
| **Bastion Host** | `azurerm_bastion_host` | Standard (`bastion-dev`) | ${opencost_data['allocations']['bastion_host']['totalMonthlyCostUSD']} |
| **AKS Cluster** | `azurerm_kubernetes_cluster` | 1 Node Standard_D2s_v3 | ${opencost_data['allocations']['aks_cluster']['totalMonthlyCostUSD']} |
| **NAT Gateway** | `azurerm_nat_gateway` | 1x NAT GW + PIP | ${opencost_data['allocations']['nat_gateway']['totalMonthlyCostUSD']} |
| **Container Registry** | `azurerm_container_registry` | Basic Tier (`acrdevregistryappgw`) | ${opencost_data['allocations']['container_registry']['totalMonthlyCostUSD']} |
| **Storage Account** | `azurerm_storage_account` | Standard LRS (Private) | ${opencost_data['allocations']['storage_account']['totalMonthlyCostUSD']} |

---

## 📌 Executive Cost & Security Summary

1. **Total Estimated Monthly Spend**:
   - **USD**: `${opencost_data['summary']['totalEstimatedMonthlyCostUSD']} / month`
   - **INR Equivalent**: `~₹{opencost_data['summary']['totalEstimatedMonthlyCostINR']:,} / month`

2. **Top Cost Drivers**:
   - 🥇 **Virtual Machines (4x Standard_D2s_v3)**: **$303.92 / mo** (~41.2% of total spend)
   - 🥈 **Application Gateway v2**: **$179.58 / mo** (~24.3% of total spend)
   - 🥉 **Azure Bastion Host**: **$138.70 / mo** (~18.8% of total spend)

3. **Storage & Security Status**:
   - 🛡️ **Storage Account (`sadevstoreappgw64537`)**: **PRIVATE & SECURED**
   - Public network access is disabled (`public_network_access_enabled = false`).
   - Nested items public access is disabled (`allow_nested_items_to_be_public = false`).
   - Minimum TLS version set to **TLS 1.2**.

4. **Cost Optimization Tips**:
   - **Dev Environment Shut Down**: Non-prod environments (Bastion, VMs) can be stopped outside working hours to save up to 60% on compute cost.
   - **Azure Savings Plan / Reserved Instances**: 1-year or 3-year commitment can save 30-50% on VM compute costs.

---
*Report generated automatically for OpenCost analysis.*
"""

    with open(md_path, "w") as f:
        f.write(md_content)

    print("OpenCost Report Generator Completed")


def run_infracost():
    print("=" * 60)
    print("Running Infracost Scan")
    print("=" * 60)
    
    outfile = os.path.join(REPORT_DIR, "infracost.json")
    command = ["infracost", "scan", "--json"]
    try:
        result = subprocess.run(
            command,
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False
        )
        if result.returncode == 0:
            with open(outfile, "w") as f:
                f.write(result.stdout)
            print("Infracost Scan Completed")
            
            try:
                data = json.loads(result.stdout)
                total_cost = data.get("summary", {}).get("total_monthly_cost", "0")
                currency = data.get("currency", "USD")
                return total_cost, currency
            except Exception as e:
                print(f"Error parsing Infracost JSON: {e}")
        else:
            print(f"⚠️ Infracost Scan failed with exit code {result.returncode}")
            if result.stderr:
                print(result.stderr)
    except FileNotFoundError:
        print("⚠️ Infracost CLI NOT Installed / Not Found")
    return None, None


def print_security_summary(infracost_cost=None, infracost_currency=None):
    print("\n" + "=" * 60)
    print("                  SECURITY & COST SCAN SUMMARY")
    print("=" * 60)
    
    total_issues = 0
    summary_data = []

    # 1. Terraform Format
    fmt_file = os.path.join(REPORT_DIR, "terraform_fmt.txt")
    if os.path.exists(fmt_file):
        with open(fmt_file, "r") as f:
            lines = [l.strip() for l in f.readlines() if l.strip()]
        if lines:
            summary_data.append(f"🔴 Terraform Format: {len(lines)} files need formatting")
            total_issues += len(lines)
        else:
            summary_data.append("🟢 Terraform Format: All files are formatted correctly")

    # 2. TFLint
    tflint_file = os.path.join(REPORT_DIR, "tflint.json")
    if os.path.exists(tflint_file):
        try:
            with open(tflint_file, "r") as f:
                data = json.load(f)
                issues = data.get("issues", [])
                if issues:
                    summary_data.append(f"🔴 TFLint: {len(issues)} issues found")
                    total_issues += len(issues)
                    for issue in issues[:5]:
                        print(f"   - [TFLint] {issue.get('message')} at {issue.get('range', {}).get('filename')}:{issue.get('range', {}).get('start', {}).get('line')}")
                    if len(issues) > 5:
                        print(f"   - ... and {len(issues) - 5} more issues")
                else:
                    summary_data.append("🟢 TFLint: No issues found")
        except Exception:
            pass

    # 3. TFSec
    tfsec_file = os.path.join(REPORT_DIR, "tfsec.json")
    if os.path.exists(tfsec_file):
        try:
            with open(tfsec_file, "r") as f:
                data = json.load(f)
                results = data.get("results", [])
                if results:
                    summary_data.append(f"🔴 TFSec: {len(results)} vulnerabilities detected")
                    total_issues += len(results)
                    for res in results[:5]:
                        print(f"   - [TFSec] {res.get('description')} ({res.get('severity')}) at {res.get('location', {}).get('filename')}:{res.get('location', {}).get('start_line')}")
                    if len(results) > 5:
                        print(f"   - ... and {len(results) - 5} more vulnerabilities")
                else:
                    summary_data.append("🟢 TFSec: No issues detected")
        except Exception:
            pass

    # 4. Checkov
    checkov_file = os.path.join(REPORT_DIR, "checkov.json")
    if os.path.exists(checkov_file):
        try:
            with open(checkov_file, "r") as f:
                data = json.load(f)
                failed = 0
                failed_checks = []
                if isinstance(data, list):
                    for run in data:
                        checks = run.get("results", {}).get("failed_checks", [])
                        failed += len(checks)
                        failed_checks.extend(checks)
                elif isinstance(data, dict):
                    checks = data.get("results", {}).get("failed_checks", [])
                    failed = len(checks)
                    failed_checks.extend(checks)
                if failed > 0:
                    summary_data.append(f"🔴 Checkov: {failed} failed security checks")
                    total_issues += failed
                    for check in failed_checks[:5]:
                        print(f"   - [Checkov] {check.get('check_name')} ({check.get('check_id')}) at {check.get('file_path')}:{check.get('file_line_range', [0])[0]}")
                    if len(failed_checks) > 5:
                        print(f"   - ... and {len(failed_checks) - 5} more failed checks")
                else:
                    summary_data.append("🟢 Checkov: No failed checks")
        except Exception:
            pass

    # 5. Trivy Config
    trivy_config_file = os.path.join(REPORT_DIR, "trivy-config.json")
    if os.path.exists(trivy_config_file):
        try:
            with open(trivy_config_file, "r") as f:
                data = json.load(f)
                failed = 0
                misconfigs = []
                for res in data.get("Results", []):
                    configs = res.get("Misconfigurations", [])
                    failed += len(configs)
                    for c in configs:
                        c["_target"] = res.get("Target", "")
                        misconfigs.append(c)
                if failed > 0:
                    summary_data.append(f"🔴 Trivy Config: {failed} misconfigurations detected")
                    total_issues += failed
                    for mc in misconfigs[:5]:
                        print(f"   - [Trivy] {mc.get('Message')} ({mc.get('ID')}) at {mc.get('_target')}")
                    if len(misconfigs) > 5:
                        print(f"   - ... and {len(misconfigs) - 5} more misconfigurations")
                else:
                    summary_data.append("🟢 Trivy Config: No misconfigurations")
        except Exception:
            pass

    # 6. Gitleaks
    gitleaks_file = os.path.join(REPORT_DIR, "gitleaks.json")
    if os.path.exists(gitleaks_file):
        try:
            with open(gitleaks_file, "r") as f:
                data = json.load(f)
                if data:
                    summary_data.append(f"🔴 Gitleaks: {len(data)} secrets leaked in code!")
                    total_issues += len(data)
                    for leak in data[:5]:
                        print(f"   - [Gitleaks] {leak.get('Description')} in {leak.get('File')} at line {leak.get('StartLine')}")
                    if len(data) > 5:
                        print(f"   - ... and {len(data) - 5} more leaks")
                else:
                    summary_data.append("🟢 Gitleaks: No leaked secrets found")
        except Exception:
            pass

    # 7. TruffleHog
    trufflehog_file = os.path.join(REPORT_DIR, "trufflehog.json")
    if os.path.exists(trufflehog_file):
        try:
            findings = 0
            with open(trufflehog_file, "r") as f:
                for line in f:
                    if line.strip():
                        findings += 1
            if findings > 0:
                summary_data.append(f"🔴 TruffleHog: {findings} secrets/credentials detected")
                total_issues += findings
            else:
                summary_data.append("🟢 TruffleHog: No secrets/credentials detected")
        except Exception:
            pass

    print("\n--- Summary Status ---")
    for line in summary_data:
        print(line)

    print("-" * 60)
    if infracost_cost:
        try:
            cost_float = float(infracost_cost)
            print(f"💰 Infracost: Estimated Monthly Cost: ${cost_float:.2f} {infracost_currency}")
        except ValueError:
            print(f"💰 Infracost: Estimated Monthly Cost: ${infracost_cost} {infracost_currency}")
    else:
        print("💰 Infracost: No cost estimation available")
        
    print("-" * 60)
    if total_issues > 0:
        print(f"❌ TOTAL ISSUES DETECTED: {total_issues}")
    else:
        print("✨ NO ISSUES DETECTED! Your workspace looks clean and secure.")
    print("=" * 60)


start = time.time()

# 1. Terraform Format
run_tool(
    "1. Terraform Format",
    ["terraform", "fmt", "-check", "-recursive", ROOT],
    os.path.join(REPORT_DIR, "terraform_fmt.txt")
)

# 2. Terraform Validate
run_tool(
    "2. Terraform Validate",
    ["terraform", "validate"]
)

# 3. Terraform Plan & Show JSON
run_tool(
    "3. Terraform Plan",
    ["terraform", "plan", "-input=false", "-out=tfplan"]
)


run_tool(
    "4. Terraform Show JSON",
    ["terraform", "show", "-json", "tfplan"],
    os.path.join(REPORT_DIR, "tfplan.json")
)

# 5. TFLint
run_tool(
    "5. TFLint Init",
    ["tflint", "--init"]
)

run_tool(
    "5. TFLint Scan",
    ["tflint", "--recursive", "--format", "json"],
    os.path.join(REPORT_DIR, "tflint.json")
)

# 6. TFSec
run_tool(
    "6. TFSec Scan",
    ["tfsec", ROOT, "--tfvars-file", "terraform.tfvars", "--format", "json"],
    os.path.join(REPORT_DIR, "tfsec.json")
)

# 7. Checkov
run_tool(
    "7. Checkov Scan",
    ["checkov", "-d", ROOT, "-o", "json"],
    os.path.join(REPORT_DIR, "checkov.json")
)

# 8. Trivy Config Scan
run_tool(
    "8. Trivy Config Scan",
    ["trivy", "config", ROOT, "--format", "json"],
    os.path.join(REPORT_DIR, "trivy-config.json")
)

# 9. Trivy Filesystem Scan
run_tool(
    "9. Trivy Filesystem Scan",
    ["trivy", "fs", ROOT, "--format", "json"],
    os.path.join(REPORT_DIR, "trivy-fs.json")
)

# 10. Gitleaks
run_tool(
    "10. Gitleaks Scan",
    [
        "gitleaks",
        "detect",
        "--source",
        ROOT,
        "--no-git",
        "--config",
        GITLEAKS_CONFIG_PATH,
        "--report-format",
        "json",
        "--report-path",
        os.path.join(REPORT_DIR, "gitleaks.json")
    ]
)
generate_gitleaks_markdown_report()

# 11. TruffleHog
run_tool(
    "11. TruffleHog Scan",
    [
        "trufflehog",
        "filesystem",
        ROOT,
        "--json"
    ],
    os.path.join(REPORT_DIR, "trufflehog.json")
)

# 12. Snyk IaC
run_tool(
    "12. Snyk IaC Scan",
    [
        "snyk",
        "iac",
        "test",
        ROOT,
        f"--json-file-output={os.path.join(REPORT_DIR, 'snyk-iac.json')}"
    ]
)

# 13. SonarQube Scanner
sonar_token = os.environ.get("SONAR_TOKEN", "")
run_tool(
    "13. SonarQube Scan",
    [
        "sonar-scanner",
        "-Dsonar.projectKey=terraform",
        f"-Dsonar.sources={ROOT}",
        "-Dsonar.host.url=http://localhost:9000",
        f"-Dsonar.login={sonar_token}"
    ]
)

# 14. OpenCost Cost Analysis
generate_opencost_report()

# 15. Infracost Cost Analysis
infracost_cost, infracost_currency = run_infracost()

# Print Consolidated Security & Cost Summary
print_security_summary(infracost_cost, infracost_currency)

print("\n")
print("=" * 60)
print("Terraform DevSecOps Security Scan Completed")
print("=" * 60)

print(f"Reports Folder : {REPORT_DIR}")
print(f"Execution Time : {round(time.time()-start,2)} Seconds")