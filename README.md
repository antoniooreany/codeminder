# Codeminder

Codeminder is a policy-driven developer automation toolkit for hooks, checks, fixes, and reminders.

## CLI

The local launcher is:

```powershell
.\bin\cm.cmd
```

## First commands

```powershell
.\bin\cm.cmd --help
.\bin\cm.cmd dashboard
.\bin\cm.cmd discover
.\bin\cm.cmd doctor
```

## Hooks

Install versioned repository hooks:

```powershell
.\scripts\Install-CodeminderHooks.ps1 -Mode hookspath
```

Fallback mode:

```powershell
.\scripts\Install-CodeminderHooks.ps1 -Mode dotgit
```

## Git Flow

Codeminder uses `main` and `develop`. Feature branches should start from `develop`.

## Repository name

Recommended repository name: codeminder