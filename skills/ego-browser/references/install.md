# Install or upgrade ego lite

Read this file only when `ego-browser` is not found, when `ego-browser skill` reports an unknown command, or when the user asks to install ego lite. Use the checked-in skill for routine tasks. Consult the installed CLI guide when an operation is unsupported or the runtime has changed.

The ego-browser skill depends on the ego lite browser: the `ego-browser` command is provided by the ego lite app. Once ego lite is installed and you've completed onboarding, no additional setup is normally needed.

ego lite website: https://lite.ego.app/

## Upgrade an older ego lite

If `ego-browser` exists but `ego-browser skill` reports `Unknown command: skill`, the installed ego lite is older than this skill. Ask the user for approval, then run:

```powershell
ego-browser upgrade
```

If `upgrade` is also an unknown command, follow the Windows installation steps. Then continue with "After installing: confirm `ego-browser` is available" in that file.

## Install

Use the [Windows install and PowerShell verification guide](install-windows.md).

## Onboarding

Onboarding is a step the user completes in the Ego Lite Windows app:

- Choose to import data from Chrome or another browser as needed.
- Onboarding registers the `ego-browser` command on the PATH.

After the app opens, wait for the user to confirm they've finished onboarding before continuing. The Windows guide explains how to confirm the command is available afterwards.

## After that, return to the original task

Once the environment is ready, return to the user's original task using the checked-in skill.
