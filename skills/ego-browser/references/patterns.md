# Common Automation Patterns for Ego Browser

This document provides production-ready code snippets and templates for common automation scenarios in Antigravity.

---

## 1. TaskSpace Initialization & Lifecycle Template

Every task should start with this standardized structure. It handles creating a new space or seamlessly resuming an existing space across conversation turns.

```javascript
// round-01.mjs
// Set SPACE_ID to null for the first round; set to the numeric ID (e.g. 12) in subsequent rounds.
const SPACE_ID = null; 

let task;
if (SPACE_ID === null) {
  task = await taskSpace("search-and-extract-data");
} else {
  const spaces = await listTaskSpaces();
  const entry = spaces.find((s) => s.id === SPACE_ID);
  if (!entry) {
    task = await taskSpace("search-and-extract-data");
  } else if (entry.ownership === "user") {
    task = await claimTaskSpace(SPACE_ID);
  } else if (entry.ownership === "agentDelegatedToUser") {
    task = await takeOverTaskSpace(SPACE_ID);
  } else {
    task = await taskSpace(SPACE_ID);
  }
}

// Retrieve or initialize the main page
const pages = await task.pages();
const page = pages.length > 0 ? pages[0] : (await task.adopt((await task.tabs())[0].page));

console.log({
  taskSpaceId: task.spaceId,
  pageLabel: page.label,
});

// Navigate to target
await page.goto("https://news.ycombinator.com");
await page.waitForLoadState("load");

// Take snapshot for next round
console.log(await page.snapshot());
```

---

## 2. Interactive Form Filling & Click Sequence

When performing multiple sequential steps on a single page, batch them in one round script to save time and token context.

```javascript
// round-02.mjs
const SPACE_ID = 12; // From round-01 output
const task = await taskSpace(SPACE_ID);
const page = task.page("p1");

// Fill search box (using ref or selector)
await page.fill("input[name='q']", "Antigravity AI");
await page.press("input[name='q']", "Enter");

// Wait for results container to appear
await page.waitForSelector(".search-results", { state: "visible", timeout: 10000 });

// Capture updated snapshot
console.log(await page.snapshot());
```

---

## 3. User Handoff Pattern (CAPTCHA, Login, 2FA)

When hitting a login gate or CAPTCHA, **never attempt to solve it or bypass it**. Delegate to the user cleanly:

```javascript
// round-login-check.mjs
const SPACE_ID = 12;
const task = await taskSpace(SPACE_ID);
const page = task.page("p1");

const isCaptchaPresent = await page.evaluate(() => {
  return !!document.querySelector("iframe[src*='recaptcha'], iframe[src*='turnstile'], .captcha-container");
});

if (isCaptchaPresent) {
  console.log("[STATUS] CAPTCHA detected. Handing off control to user...");
  await task.handOff();
  // Script exits here. Report in chat asking the user to complete verification in their Ego Lite browser.
}
```

Once the user confirms completion in chat, resume the space with:

```javascript
// round-after-login.mjs
const SPACE_ID = 12;
const task = await takeOverTaskSpace(SPACE_ID);
const page = (await task.pages())[0] ?? task.page("p1");

console.log({ status: "Resumed control after user verification", url: await page.url() });
console.log(await page.snapshot());
```

---

## 4. Visual Inspection & Screenshot Pattern

When DOM semantics are insufficient (e.g. Canvas, Figma, WebGL, custom graphs) or when visual proof is needed:

```javascript
// round-screenshot.mjs
const SPACE_ID = 12;
const task = await taskSpace(SPACE_ID);
const page = task.page("p1");

// Save screenshot to Antigravity scratch directory
const shotPath = "C:/Users/Administrator/.gemini/antigravity/brain/ebdf3c2c-8aa6-4aef-9d11-0acec489a3ff/scratch/ego/view.png";
await page.screenshot({ path: shotPath });

console.log({ screenshot: shotPath });
```
In Antigravity, you can immediately inspect `view.png` using the `read_file` tool to visually verify the rendered output.

---

## 5. Bulk Structured Data Extraction

Use `page.evaluate()` to extract structured data in one single round without repeatedly querying selectors:

```javascript
// round-extract.mjs
const SPACE_ID = 12;
const task = await taskSpace(SPACE_ID);
const page = task.page("p1");

const results = await page.evaluate(() => {
  const items = document.querySelectorAll("tr.athing");
  return Array.from(items).slice(0, 15).map((row) => {
    const titleLink = row.querySelector(".titleline > a");
    const subtext = row.nextElementSibling?.querySelector(".subtext");
    const score = subtext?.querySelector(".score")?.textContent?.trim();
    return {
      title: titleLink?.textContent?.trim(),
      url: titleLink?.href,
      score: score || "0 points",
    };
  });
});

console.log(JSON.stringify(results, null, 2));
```

---

## 6. File Upload and Download

### File Upload
```javascript
// Using existing file input
await page.setInputFiles("input[type=file]", "C:/path/to/upload.pdf");

// Or arm file chooser before clicking upload button
const chooserPromise = page.waitForFileChooser({ timeout: 10000 });
await page.click("button.upload-trigger", { label: "Trigger upload" });
const chooser = await chooserPromise;
await chooser.setFiles("C:/path/to/upload.pdf");
```

### File Download
```javascript
// Arm download listener before triggering download
const downloadPromise = page.waitForEvent("download", { timeout: 30000 });
await page.click("a.download-btn", { label: "Download report" });
const download = await downloadPromise;

const saveTarget = "C:/Users/Administrator/.gemini/antigravity/brain/ebdf3c2c-8aa6-4aef-9d11-0acec489a3ff/scratch/ego/downloads/report.csv";
await download.saveAs(saveTarget);
console.log({ downloaded: saveTarget });
```

---

## 7. Clean Teardown (`finish()`)

When the user's objective is completed:

```javascript
// round-finish.mjs
const SPACE_ID = 12;
const task = await taskSpace(SPACE_ID);

// 1. Close all tabs and cleanup (Default)
await task.finish({ keep: [] });

// OR 2. Leave specific tab open for user to view:
// await task.finish({ keep: ["p1"] });

console.log("[STATUS] Task space finished cleanly.");
```
