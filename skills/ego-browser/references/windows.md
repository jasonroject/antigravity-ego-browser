# Windows PowerShell Execution Guide for Antigravity

In Antigravity on Windows, commands run in a `powershell.exe` session. To avoid common pitfalls (such as quote stripping, character encoding corruption, and syntax errors), follow these rules:

---

## 1. The Script File Pattern (Standard)

Because PowerShell does not support Bash heredocs (`<<'EOF'`) and Windows PowerShell 5.1 strips double quotes from native arguments, **never pass multi-line or inline scripts directly to `-e`**.

Always use the **Two-Step Pattern**:

### Step 1: Write the `.mjs` file using Antigravity's `write_file` tool
Save your automation script in the Antigravity conversation scratch directory:
- Path: `C:/Users/Administrator/.gemini/antigravity/brain/<conversation-id>/scratch/ego/round-01.mjs`
- Using `write_file` guarantees UTF-8 encoding and avoids PowerShell string escaping or truncation issues.

### Step 2: Execute with a clean one-line import
Run via `run_command`:

```powershell
ego-browser nodejs -e "await import('file:///C:/Users/Administrator/.gemini/antigravity/brain/<conversation-id>/scratch/ego/round-01.mjs')"
```

> [!IMPORTANT]
> 1. Use **forward slashes** (`/`) in the `file:///` URL (e.g. `file:///C:/path/to/script.mjs`). Backslashes will cause ESM import syntax errors.
> 2. Ensure the file extension is `.mjs` so Node.js treats the script as an ES Module with top-level `await`.
> 3. Never use PowerShell's `Get-Content task.mjs | ego-browser nodejs`: PowerShell 5.1 truncates lines and corrupts non-ASCII (Chinese) text.

---

## 2. Directory & Path Conventions

| Resource Type | Path Pattern | Purpose |
| :--- | :--- | :--- |
| **Automation Scripts** | `<appDataDir>/brain/<conversation-id>/scratch/ego/round-XX.mjs` | Multi-round automation logic. |
| **Screenshots** | `<appDataDir>/brain/<conversation-id>/scratch/ego/screenshot-XX.png` | Visual observation and inspection. |
| **Downloaded Files** | `<appDataDir>/brain/<conversation-id>/scratch/ego/downloads/<filename>` | Browser downloads captured via `saveAs`. |
| **Permanent Reports** | `<appDataDir>/brain/<conversation-id>/<report-name>.md` | Artifact documents for the user. |

---

## 3. Handling Multi-Round Tasks

1. **State Persistence**:
   - Each `ego-browser nodejs` run starts a new Node.js process.
   - Task spaces, open tabs, and page labels (`p1`, `p2`) persist in the running Ego Lite browser.
   - JavaScript in-memory variables do **not** persist between rounds.
   - Print the `task.spaceId` in your first script, and pass `const SPACE_ID = <id>;` into subsequent round scripts (`round-02.mjs`, `round-03.mjs`).

2. **File Versioning**:
   - Write a new file per round (`round-01.mjs`, `round-02.mjs`).
   - Do not overwrite previous round scripts while executing, as keeping history helps debugging and step tracking.

---

## 4. Common Troubleshooting on Windows

| Error / Symptom | Root Cause | Fix |
| :--- | :--- | :--- |
| `SyntaxError: await is only valid in async functions...` | Shell argument stripping corrupted inline code passed to `-e`. | Write the script to a `.mjs` file and execute via `await import('file:///...')`. |
| Chinese characters / non-ASCII garbled in page input | Script was created or piped via PowerShell `Set-Content` or `>`. | Write the `.mjs` file using Antigravity's `write_file` tool directly. |
| `ERR_INVALID_URL` on `import()` | Backslashes used in `file:///` path. | Convert Windows backslashes `\` to forward slashes `/`. |
| `EGO_PAGE_UNRESPONSIVE` during screenshot | Page is busy executing long JavaScript loops or rendering large canvases. | Retry with `waitForLoadState()` first, or use `page.evaluate()` to extract canvas data. |
| Tab not closing after `finish({ keep: [] })` | Tab was opened by the user or has unknown origin. | User-owned tabs are protected by Ego Lite and will not be force-closed. |
