# Clearing cookies, cache, and storage

Read this file before clearing any cookie, cache, or storage. These commands look interchangeable but differ in how far they reach. A task space picks a browser profile when it is created, and that profile's cookie jar and HTTP cache are shared with the user's own tabs and with every other task space on the same profile. Measured from inside an agent space on a default profile: the current page saw 1 cookie, the profile held 3478 across 1161 domains.

## What each command reaches

| Command                                           | Reaches               | Getting the state back |
| ------------------------------------------------- | --------------------- | ---------------------- |
| `Network.deleteCookies`                           | one named cookie      | sign in to that site   |
| `Storage.clearDataForOrigin`                      | one origin            | sign in to that site   |
| `Page.reload` with `ignoreCache: true`            | one Page load         | nothing was lost       |
| `Network.clearBrowserCookies`                     | **the whole profile** | **nothing you can do** |
| `Network.clearBrowserCache`                       | **the whole profile** | **nothing you can do** |
| `Storage.clearCookies` without `browserContextId` | **the whole profile** | **nothing you can do** |

The three profile-wide commands take no scope parameter. There is no narrower way to call them, so reach for a different command rather than a different argument.

Once a profile-wide clear has run you cannot undo it: the agent has no way to recover the sessions it destroyed, and every site on that profile is signed out. Do not run one intending to restore the state afterwards.

## The entry point does not limit the scope

`page.cdp()` selects which target session carries the command. It does not limit what the command touches. `Network.clearBrowserCookies` can only be sent through a Page session — the Network domain does not exist on the browser-level connection — yet it empties the profile's entire cookie jar. A command sent "through this Page" is not a command scoped to this Page.

Do not read a rejection from one entry point as permission to use another. If `task.cdp()` refuses a command, sending the same command through `page.cdp()` does not make it safer; it reaches exactly as far.

## Recipes

A session the user wants anonymous — clear that one site, not the profile. A sign-in wall alone is no reason to clear: call `task.handOff()` and let the user sign in. Before deleting a cookie, explain the exact host, cookie name, path, and partition scope and obtain confirmation when the cookie is not clearly task-local.

```js
await page.cdp("Storage.clearDataForOrigin", {
  origin: new URL(await page.url()).origin,
  storageTypes: "cookies",
});
```

A stale document or a resource that will not reload — reload past the cache instead of emptying it:

```js
await page.cdp("Page.reload", { ignoreCache: true });
```

To drop one site's Cache API entries and service workers, use `storageTypes: "cache_storage,service_workers"` with the same `Storage.clearDataForOrigin` call.

## Single-cookie and profile-wide changes

For a specific cookie, prefer user-controlled removal. Identify the exact host, name, path and partition with the user before handoff. Do not enumerate the profile or log cookie values. If the user requests a profile-wide clear, explain that it can affect unrelated tabs and sites, then hand off to the browser settings so the user controls the operation.
