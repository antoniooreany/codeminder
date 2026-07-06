#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

HELP = """Codeminder (cm) - policy-driven developer automation

USAGE:
  cm <command> [options]

COMMANDS:
  dashboard          Show recent commands, suggestions, and reminders
  discover           Find available automations
  explain            Explain a command, rule, or status
  check              Run non-mutating checks
  fix                Run safe automatic fixes
  hooks doctor       Diagnose repository hooks
  bootstrap status   Show bootstrap/project state
  bootstrap repair   Run local repair script
  remind             Manage reminders
  doctor             Validate setup, config, and environment
  release            Run release preparation steps
"""

def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]

def run_powershell_file(script_path: Path, extra_args: list[str]) -> int:
    if not script_path.exists():
        print(f"Script not found: {script_path}", file=sys.stderr)
        return 1
    cmd = [
        "pwsh",
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", str(script_path),
        *extra_args,
    ]
    return subprocess.call(cmd, cwd=repo_root())

def run_git(args: list[str]) -> tuple[int, str]:
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=repo_root(),
            capture_output=True,
            text=True
        )
        return result.returncode, (result.stdout or result.stderr).strip()
    except Exception as exc:
        return 1, str(exc)

def cmd_dashboard() -> int:
    print("CM DASHBOARD")
    print("Project: codeminder   Policy: automation-policy.yaml   Reminders: ON\n")
    print("Suggested now")
    print("  1. cm hooks doctor")
    print("  2. cm bootstrap status")
    print("  3. cm bootstrap repair")
    return 0

def cmd_discover() -> int:
    print("Available areas: docs, tests, logging, exceptions, hooks, reminders, bootstrap")
    return 0

def cmd_doctor() -> int:
    root = repo_root()
    issues = []

    if not (root / "automation-policy.yaml").exists():
        issues.append("automation-policy.yaml is missing")
    if not (root / "bin" / "cm.cmd").exists():
        issues.append("bin/cm.cmd is missing")
    if not (root / "hooks" / "pre-commit.ps1").exists():
        issues.append("hooks/pre-commit.ps1 is missing")

    if issues:
        print("Doctor: WARN")
        for issue in issues:
            print(f" - {issue}")
        return 1

    print("Doctor: OK")
    return 0

def cmd_hooks_doctor() -> int:
    root = repo_root()
    print("HOOKS DOCTOR")
    print(f"Repo root: {root}")

    code, hooks_path = run_git(["config", "--get", "core.hooksPath"])
    if code == 0 and hooks_path:
        print(f"core.hooksPath: {hooks_path}")
    else:
        print("core.hooksPath: <not set>")

    required = [
        root / "hooks" / "pre-commit",
        root / "hooks" / "pre-commit.ps1",
        root / "hooks" / "pre-push",
        root / "hooks" / "pre-push.ps1",
        root / "hooks" / "shared.ps1",
    ]

    missing = [str(p.relative_to(root)) for p in required if not p.exists()]
    if missing:
        print("Missing hook files:")
        for item in missing:
            print(f" - {item}")
        return 1

    print("Hooks layout: OK")
    return 0

def cmd_bootstrap_status() -> int:
    root = repo_root()
    print("BOOTSTRAP STATUS")
    print(f"Project root: {root}")

    checks = {
        "README.md": (root / "README.md").exists(),
        "automation-policy.yaml": (root / "automation-policy.yaml").exists(),
        "scripts/Install-CodeminderHooks.ps1": (root / "scripts" / "Install-CodeminderHooks.ps1").exists(),
        ".github/workflows/python-ci.yml": (root / ".github" / "workflows" / "python-ci.yml").exists(),
    }

    failed = False
    for name, ok in checks.items():
        print(f"{name}: {'OK' if ok else 'MISSING'}")
        if not ok:
            failed = True

    code, branch = run_git(["branch", "--show-current"])
    if code == 0:
        print(f"Current branch: {branch}")

    code, origin = run_git(["remote", "get-url", "origin"])
    if code == 0:
        print(f"Origin: {origin}")
    else:
        print("Origin: <missing>")

    return 1 if failed else 0

def cmd_bootstrap_repair(extra: list[str]) -> int:
    root = repo_root()
    script_path = root / "scripts" / "Repair-CodeminderProject.ps1"
    return run_powershell_file(script_path, extra)

def main() -> int:
    args = sys.argv[1:]

    if not args or args[0] in {"-h", "--help", "help"}:
        print(HELP)
        return 0

    if args[0] == "dashboard":
        return cmd_dashboard()

    if args[0] == "discover":
        return cmd_discover()

    if args[0] == "doctor":
        return cmd_doctor()

    if args[0] == "hooks" and len(args) > 1 and args[1] == "doctor":
        return cmd_hooks_doctor()

    if args[0] == "bootstrap" and len(args) > 1 and args[1] == "status":
        return cmd_bootstrap_status()

    if args[0] == "bootstrap" and len(args) > 1 and args[1] == "repair":
        return cmd_bootstrap_repair(args[2:])

    print(f"Command not implemented yet: {' '.join(args)}", file=sys.stderr)
    return 1

if __name__ == "__main__":
    raise SystemExit(main())