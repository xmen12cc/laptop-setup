# laptop-setup

One-command setup for the AlbertoAI laptop server. The repo is public on purpose:
it only contains this bootstrap script - no secrets, no data, no code.

On a fresh Windows laptop, open PowerShell and paste:

```
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/xmen12c/laptop-setup/main/bootstrap.ps1 | iex"
```

What it does: installs Git + Node.js, clones the three private repos into
`C:\Projects`, installs HomeworkSuite dependencies, downloads MongoDB 8.0.14
into TradeCopier's `tools\`, registers two scheduled tasks (full stack at logon,
code sync every 5 minutes), and sets the power plan so the laptop never sleeps
on AC. A GitHub login window opens once during the clone.

The real logic lives in `TradeCopier\scripts\laptop\` (private repo).
