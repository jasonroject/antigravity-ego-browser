# Install ego lite on macOS

Read `install.md` first; it covers upgrading an older ego lite and the onboarding step shared by every platform. This file has the macOS install steps, the commands that confirm the installation, and macOS troubleshooting.

## Install and complete onboarding

Have the user download Ego Lite from [the vendor site](https://lite.ego.app/), install it using the normal macOS flow, and complete onboarding in the app. If Gatekeeper rejects the download, stop and verify the source with the vendor. The bundled shell helper only checks for the CLI and prints the next step. Automatic installation requires independently verified release metadata, including the expected publisher and versioned digest.

## After installing: confirm `ego-browser` is available

Once the user has finished onboarding, confirm the command is ready:

```bash
command -v ego-browser
```

If it reports that the command isn't found, `~/.local/bin` is most likely not on the current PATH. Fix it temporarily and retry:

```bash
export PATH="$HOME/.local/bin:$PATH"
command -v ego-browser
```

Once the command exists, verify the runtime:

```bash
ego-browser nodejs <<'EOF'
console.log('ego-browser ready')
EOF
```

Printing `ego-browser ready` means the environment is ready. Finally confirm that the installed ego lite prints its usage guide:

```bash
ego-browser skill
```

Then return to the user's original task, as `install.md` describes.
