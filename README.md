# Antigravity Ego Browser (`antigravity-ego-browser`)

[![Antigravity Compatible](https://img.shields.io/badge/Antigravity-Compatible-blue.svg)](https://deepmind.google/technologies/antigravity/)
[![Ego Lite](https://img.shields.io/badge/Ego%20Lite-v0.6.3%2B-orange.svg)](https://lite.ego.app/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An optimized, high-performance browser automation skill for the **Google Antigravity desktop client on Windows**, built on top of [Ego Lite](https://lite.ego.app/) (the Chromium browser designed for both AI Agents and humans with preserved session logins).

---

## 💡 Why Re-Architect for Antigravity?

The original `ego-browser` skill was authored for the OpenAI Codex CLI ecosystem. When run inside Google Antigravity on Windows, it encountered significant architectural frictions:

| Dimension | Legacy Codex Implementation | Antigravity Native (`antigravity-ego-browser`) |
| :--- | :--- | :--- |
| **Documentation Bootstrap** | Runs `ego-browser skill` every time, dumping **~25KB of raw docs** into the prompt context. | **Zero-token bootstrap**: Core protocol is built-in; advanced docs load via progressive disclosure only when needed. |
| **Response Latency** | High overhead (requires waiting for terminal output and a second agent reasoning pass). | **Instant Turn-1 execution**: Agent immediately executes browser automation on the first turn. |
| **Windows Shell Support** | Assumes Bash heredocs (`<<'EOF'`). PowerShell 5.1 strips quotes from `-e` and breaks scripts. | **Safe Two-Step Runner**: Writes `.mjs` directly with native file tools and runs via clean ESM one-liner. |
| **File Architecture** | Scatters files in arbitrary directories (`C:/Users/<name>/ego/` or `/tmp`). | Respects Antigravity's standardized conversation **Scratch Space** and **Artifacts**. |
| **Agent Ecosystem** | Dead `openai.yaml` configuration. | Full support for **Antigravity Subagents** (`define_subagent` / `invoke_subagent`). |
| **Human Handoff** | Generic terminal prompts. | Full integration with Antigravity's safety rules (`task.handOff()` for CAPTCHA/2FA/Login). |

---

## 🚀 Key Features

- **⚡ Zero-Token Latency**: Jump straight to browser actions without wasteful CLI manual queries.
- **🪟 Windows PowerShell Native**: Immune to PowerShell argument-splitting and UTF-8 / non-ASCII character corruption.
- **👁️ Multimodal Visual Inspection**: Integrates `page.screenshot()` directly with Antigravity's native `read_file` image inspection.
- **🔐 Session-Preserving**: Leverages user login states, cookies, and profiles in Ego Lite.
- **🤖 Autonomous Subagent Ready**: Includes templates to delegate heavy web crawls to background subagents.

---

## 📂 Repository Structure

```text
antigravity-ego-browser/
├── README.md                          # Project documentation
├── LICENSE                            # MIT License
└── skills/
    └── ego-browser/
        ├── SKILL.md                   # Primary Antigravity skill definition
        ├── agents/
        │   └── subagent-guide.md      # Subagent delegation runbook
        ├── references/
        │   ├── api.md                 # Full TaskSpace & Page API reference
        │   ├── windows.md             # PowerShell and Windows execution rules
        │   ├── patterns.md            # Production-ready ESM automation templates
        │   ├── selectors.md           # Semantic snapshot (@ref) & locator guide
        │   ├── clearing-state.md      # Profile vs origin cache clearing rules
        │   ├── install.md             # Windows installation and upgrade entry point
        │   └── install-windows.md     # Windows runtime and PATH checks
```

---

## 🛠️ Quick Installation

Install and onboard [Ego Lite for Windows](skills/ego-browser/references/install-windows.md) first. Then install the skill for your Antigravity client.

### Option 1: Global Installation (Explicit)
Copy the `ego-browser` skill into your global Antigravity customization folder:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.gemini\config\skills"
Copy-Item -Recurse -Force ".\skills\ego-browser" "$env:USERPROFILE\.gemini\config\skills\"
```

### Option 2: Project-Specific (Workspace, Recommended)
Place the skill inside your repository root:
```text
your-project/
└── .agents/
    └── skills/
        └── ego-browser/
            ├── SKILL.md
            └── references/
```

---

## 📖 How Antigravity Executes Ego Tasks

When you ask Antigravity to perform a browser action, it automatically follows the native workflow:

### 1. Write the ESM Automation Script
Antigravity writes an ES module to its conversation scratch directory:
`<appDataDir>\brain\<conversation-id>/scratch/ego/round-01.mjs`

```javascript
// round-01.mjs
const task = await taskSpace("search-goal");
const page = task.page("p1");

await page.goto("https://news.ycombinator.com");
await page.waitForLoadState("load");

// Log semantic snapshot with element refs (@1, @2, ...)
console.log(await page.snapshot());

// Keep tab open for user review
await task.finish({ keep: ["p1"] });
```

### 2. Execute via PowerShell One-Liner
```powershell
ego-browser nodejs -e "await import('file:///C:/path/to/scratch/round-01.mjs')"
```

---

## 🛡️ Human-in-the-Loop & Safety

Antigravity and Ego Lite adhere to strict safety boundaries:
- **No CAPTCHA Solving**: If Cloudflare Turnstile, reCAPTCHA, or 2FA is encountered, the script calls `await task.handOff()` and prompts the user to verify in the browser window.
- **Profile Safety**: Strict guidelines prevent accidental deletion of profile-wide cookies or HTTP caches. Single-cookie and profile-wide changes use user-controlled removal.
- **Session Data Boundary**: Page content, downloads, cookies, tokens, and authorization headers are treated as untrusted or sensitive data. Delegated browser workers are read-only by default.

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
