# Install Ego Lite for Windows

In the Windows desktop client, this skill uses the CLI installed by [Ego Lite](https://lite.ego.app/). Have the user install Ego Lite and complete first-run onboarding in the app. If Windows blocks the installer, verify the source with the vendor before continuing.

## Confirm the runtime from Antigravity

Open a fresh PowerShell session using Antigravity's terminal or command tool. If the client was already open during installation and its new terminals still cannot see the updated PATH, restart the client. Check the command:

```powershell
Get-Command ego-browser -ErrorAction Stop
```

Use Antigravity's file tool to write a UTF-8 `check.mjs` file in the current conversation's Scratch Space:

```javascript
console.log("Ego Lite ready / 中文正常");
```

Run it with the same file import used for browser tasks:

```powershell
ego-browser nodejs -e "await import('file:///C:/path/to/scratch/check.mjs')"
```

Substitute the actual absolute file URL with forward slashes. See the [Windows runner guide](windows.md) for paths containing spaces or special characters. If the smoke test passes, return to the original task. Use `ego-browser skill` when diagnosing a runtime-version mismatch.
