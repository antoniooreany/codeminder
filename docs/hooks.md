# Hooks

Codeminder stores versioned hook logic in the repository.

Files:
- hooks/pre-commit
- hooks/pre-push
- hooks/pre-commit.ps1
- hooks/pre-push.ps1
- hooks/shared.ps1

Recommended install mode:
- hookspath

Install:
```powershell
.\scripts\Install-CodeminderHooks.ps1 -Mode hookspath
```