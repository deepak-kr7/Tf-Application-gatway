import os
import subprocess
import time

ROOT = "."
REPORT_DIR = "reports"

os.makedirs(REPORT_DIR, exist_ok=True)


def run_tool(name, command, outfile=None):
    print("=" * 60)
    print(f"Running {name}")
    print("=" * 60)

    try:
        if outfile:
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
        print(f"{name} NOT Installed")


start = time.time()

# Terraform
run_tool(
    "Terraform Init",
    ["terraform", "init", "-backend=false", "-input=false"]
)

run_tool(
    "Terraform Validate",
    ["terraform", "validate"]
)

run_tool(
    "Terraform Format",
    ["terraform", "fmt", "-check", "-recursive"],
    os.path.join(REPORT_DIR, "terraform_fmt.txt")
)

# TFLint
run_tool(
    "TFLint Init",
    ["tflint", "--init"]
)

run_tool(
    "TFLint",
    ["tflint", "--format", "json"],
    os.path.join(REPORT_DIR, "tflint.json")
)

# Checkov
run_tool(
    "Checkov",
    ["checkov", "-d", ROOT, "-o", "json"],
    os.path.join(REPORT_DIR, "checkov.json")
)

# tfsec
run_tool(
    "tfsec",
    ["tfsec", ROOT, "--format", "json"],
    os.path.join(REPORT_DIR, "tfsec.json")
)

# Terrascan
run_tool(
    "Terrascan",
    ["terrascan", "scan", "-d", ROOT, "-o", "json"],
    os.path.join(REPORT_DIR, "terrascan.json")
)

# Semgrep
run_tool(
    "Semgrep",
    [
        "semgrep",
        "scan",
        "--config",
        "auto",
        ROOT,
        "--json"
    ],
    os.path.join(REPORT_DIR, "semgrep.json")
)

# Gitleaks
run_tool(
    "Gitleaks",
    [
        "gitleaks",
        "detect",
        "--source",
        ROOT,
        "--report-format",
        "json",
        "--report-path",
        os.path.join(REPORT_DIR, "gitleaks.json")
    ]
)

# TruffleHog
run_tool(
    "TruffleHog",
    [
        "trufflehog",
        "filesystem",
        ROOT,
        "--json"
    ],
    os.path.join(REPORT_DIR, "trufflehog.json")
)

# Infracost
run_tool(
    "Infracost",
    [
        "infracost",
        "scan",
        "--path",
        ROOT,
        "--format",
        "json",
        "--out-file",
        os.path.join(REPORT_DIR, "infracost.json")
    ]
)

print("\n")
print("=" * 60)
print("Terraform Security Scan Completed")
print("=" * 60)

print(f"Reports Folder : {REPORT_DIR}")
print(f"Execution Time : {round(time.time()-start,2)} Seconds")