# Ego Browser (Ego Lite) API Reference

This reference documents the Node.js ESM APIs exposed by the `ego-browser` runtime.

---

## 1. Top-Level Global Functions

These functions are available in the top-level scope of any script executed with `ego-browser nodejs`.

| Function | Signature | Description |
| :--- | :--- | :--- |
| `taskSpace(nameOrId, options?)` | `Promise<TaskSpace>` | Opens an existing TaskSpace by ID or creates a new one with a descriptive string name. |
| `listTaskSpaces()` | `Promise<Array<TaskSpaceSummary>>` | Returns an array of existing task spaces: `{ id, name, ownership, pages }`. |
| `claimTaskSpace(spaceId)` | `Promise<TaskSpace>` | Claims ownership of a space currently owned by the user (e.g. after finishing with kept pages). |
| `takeOverTaskSpace(spaceId)` | `Promise<TaskSpace>` | Resumes control of a task space previously delegated to the user via `task.handOff()`. |
| `help(topic?)` | `void` | Prints signature and details for APIs (e.g., `help("page.click")`, `help("profiles")`). Prints directly; do not wrap in `console.log`. |

---

## 2. TaskSpace API

A `TaskSpace` manages the browser lifecycle, tabs, and permissions for a user goal.

### Properties
- `task.spaceId`: (number) Unique numeric ID of the task space.
- `task.name`: (string) Descriptive name given to the space.
- `task.ownership`: (`"agent"` | `"user"` | `"agentDelegatedToUser"`) Current ownership state.

### Methods

#### `task.page(label: string): Page`
Retrieves a handle to an already existing managed page by label (e.g., `"p1"`).
> [!NOTE]
> `task.page(label)` does NOT create a page. Its handle is always truthy, so `task.page("p2") || await task.newPage()` will not detect a missing page. Use `await task.pages()` to check existing pages.

#### `task.pages(): Promise<Page[]>`
Returns an array of all currently managed `Page` objects.

#### `task.tabs(): Promise<TabSummary[]>`
Returns an array of all tabs in the task space, both managed and unmanaged:
`{ label?: string, page: PageHandle, targetId: string, title: string, url: string, active: boolean, openedBy: "agent" | "user" | "unknown" }`

#### `task.newPage(): Promise<Page>`
Opens a new blank managed page in the task space and assigns it the next label (e.g. `p2`).

#### `task.adopt(pageHandle, options?: { as?: string }): Promise<Page>`
Adopts an unmanaged tab into the task space and returns its `Page` handle.

#### `task.release(label: string): Promise<void>`
Releases an unknown-origin page back to the user without closing its tab.

#### `task.handOff(): Promise<void>`
Transfers control of the space to the user. Use this when the user needs to perform manual actions (login, 2FA, CAPTCHA, payment).

#### `task.waitForControl(options?: { timeout?: number }): Promise<void>`
Waits in place until control returns to the agent.

#### `task.finish(options: { keep?: string[] }): Promise<void>`
Ends the browser session for this goal.
- `keep: []`: Closes all agent-created pages and cleans up the space. (Default)
- `keep: ["p1"]`: Leaves specified pages open in Ego Lite for the user to review.
> [!WARNING]
> After calling `finish()`, do not operate any page in the same script.

#### `task.cdp(method: string, params?: object, options?: object): Promise<any>`
Dispatches raw Chrome DevTools Protocol commands at the browser or target level.

---

## 3. Page API

A `Page` represents a single browser tab.

### State & Observation
- `page.label`: (string) Permanent label (e.g., `"p1"`, `"p2"`).
- `page.spaceId`: (number) TaskSpace ID to which this page belongs.
- `page.url(): Promise<string>`: Returns current URL.
- `page.title(): Promise<string>`: Returns document title.
- `page.info(): Promise<PageInfo>`: Returns state info including dialogs, active navigation, etc.
- `page.snapshot(options?): Promise<string>`:
  Captures semantic accessibility DOM snapshot.
  - `options.scope`: `"viewport"` (default), `"full_page"`, or `"subtree"`.
  - `options.root`: snapshot ref (e.g., `"@12"`) when inspecting an iframe subtree.
- `page.screenshot(options?): Promise<string>`:
  Saves a screenshot.
  - `options.path`: Absolute path to write the PNG file (must use forward slashes in Windows URLs).
  - Returns the resolved absolute file path.

### Navigation & Synchronization
- `page.goto(url: string, options?: { timeout?: number, waitUntil?: string })`
- `page.reload(options?: { timeout?: number, ignoreCache?: boolean })`
- `page.waitForURL(urlPattern: string | RegExp, options?: { timeout?: number })`
- `page.waitForSelector(selector: string, options?: { state?: "visible" | "attached" | "detached" | "hidden", timeout?: number })`
- `page.waitForLoadState(state?: "load" | "domcontentloaded" | "networkidle")`: Defaults to `"load"`.
- `page.waitForFunction(fn: Function | string, arg?: any, options?: { timeout?: number })`
- `page.waitForEvent(event: "popup" | "download", options?: { timeout?: number })`
- `page.waitForTimeout(ms: number)`

### Element Interaction
All element selectors accept: snapshot refs (`@21` or `ref=21`), text locators (`text=...`), `loc=css:`, `loc=role:`, `loc=href:`, `xpath=...`, or standard CSS selectors.

- `page.click(selector: string, options?: { label?: string, timeout?: number })`
- `page.dblclick(selector: string, options?: { label?: string, timeout?: number })`
- `page.hover(selector: string, options?: { label?: string, timeout?: number })`
- `page.dragAndDrop(source: string, target: string, options?: { label?: string })`
- `page.fill(selector: string, value: string, options?: { timeout?: number })`
- `page.selectOption(selector: string, option: { label?: string, value?: string, index?: number } | string | null)`
- `page.focus(selector: string)`
- `page.press(selector: string, key: string)`
- `page.setInputFiles(selector: string, files: string | string[])`
- `page.waitForFileChooser(options?: { timeout?: number })`
- `page.close()`

> [!NOTE]
> The optional `{ label: "3-6 words" }` parameter displays intent text beside the visible agent cursor in Ego Lite. It is supported **only** on pointer actions (`click`, `dblclick`, `hover`, `dragAndDrop`, `mouse.*`). Do NOT pass `label` to `fill`, `press`, or other methods.

### Dialogs
- `page.acceptDialog(promptText?: string): Promise<void>`
- `page.dismissDialog(): Promise<void>`

### Low-Level Mouse & Keyboard
- `page.mouse.click(x: number, y: number, options?: { label?: string, button?: "left" | "right" | "middle" })`
- `page.mouse.move(x: number, y: number, options?: { label?: string })`
- `page.mouse.down(options?: { button?: string })`
- `page.mouse.up(options?: { button?: string })`
- `page.mouse.wheel(deltaX: number, deltaY: number, options?: { label?: string })`
- `page.keyboard.down(key: string)`
- `page.keyboard.up(key: string)`
- `page.keyboard.press(key: string)`
- `page.keyboard.type(text: string, options?: { delay?: number })`
- `page.keyboard.insertText(text: string)`
- `page.keyboard.paste(payload: string | { text: string, html?: string })`

### In-Page JavaScript & CDP
- `page.evaluate(fnOrString: Function | string, argument?: any): Promise<any>`: Runs code in the browser page context. Must return a JSON-serializable value.
- `page.fetch(url: string, options?: FetchOptions)`: Executes `window.fetch()` inside the page (inherits cookies and origin context).
  - Can take `{ method, headers, body, saveAs: "/path/to/file" }`.
- `page.cdp(method: string, params?: object, options?: object)`: Page-level Chrome DevTools Protocol call.
