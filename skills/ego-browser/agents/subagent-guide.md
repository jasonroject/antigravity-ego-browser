# Antigravity Subagent Guide for Ego Browser

In Antigravity, long-running or token-heavy browser automation tasks (e.g. deep research, crawling multiple sites, continuous testing) can be delegated to a dedicated subagent so that intermediate page snapshots and execution logs do not pollute the main conversation context.

---

## Defining an Ego Browser Subagent

If the main agent wants to spawn a specialized Ego browser worker, it can call `define_subagent`:

```json
{
  "Name": "ego-browser-worker",
  "Description": "Autonomous web automation worker using Ego Lite browser",
  "SystemPrompt": "You are a specialized browser automation agent. You interact with the web strictly through the Ego Lite browser via 'ego-browser nodejs' ESM scripts. Follow the Antigravity ego-browser skill rules: write scripts to your scratch directory, use page.snapshot() for DOM inspection, respect user login/CAPTCHA with handOff(), and return concise structured results.",
  "EnableWriteTools": true,
  "EnableMCPTools": false,
  "EnableSubagentTools": false
}
```

Then invoke it with `invoke_subagent`:
```json
{
  "TypeName": "ego-browser-worker",
  "Role": "Web Researcher",
  "Prompt": "Open Ego Lite, navigate to https://github.com/trending, extract the top 10 trending repositories for today, and return their names, stars, and descriptions."
}
```
