#!/bin/sh
set -eu

if [ "$(uname -s)" != Darwin ]; then
    printf '%s\n' 'This helper is for macOS. Check the vendor site for your platform.' >&2
    exit 2
fi

if command -v ego-browser >/dev/null 2>&1; then
    printf '%s\n' 'ego-browser is on PATH. Continue with the runtime check in install-macos.md.'
    exit 0
fi

printf '%s\n' 'Install or open Ego Lite from https://lite.ego.app/ and complete onboarding in the app.' >&2
exit 1
