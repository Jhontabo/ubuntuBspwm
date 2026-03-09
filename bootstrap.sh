#!/usr/bin/env bash

set -euo pipefail

REPO_OWNER="Jhontabo"
REPO_NAME="ubuntuBspwm"
BRANCH="${BRANCH:-main}"
ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz"

log() { printf '[+] %s\n' "$*"; }
err() { printf '[!] %s\n' "$*" >&2; }

if ! command -v tar >/dev/null 2>&1; then
  err "tar is required. Install it and retry."
  exit 1
fi

TMP_DIR="$(mktemp -d)"
ARCHIVE_PATH="${TMP_DIR}/${REPO_NAME}.tar.gz"
EXTRACT_DIR="${TMP_DIR}/${REPO_NAME}"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$EXTRACT_DIR"

log "Downloading ${REPO_NAME} (${BRANCH})..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$ARCHIVE_PATH" "$ARCHIVE_URL"
else
  err "curl or wget is required."
  exit 1
fi

log "Extracting files..."
tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_DIR" --strip-components=1

if [[ ! -f "${EXTRACT_DIR}/install.sh" ]]; then
  err "install.sh not found in downloaded archive."
  exit 1
fi

log "Running install.sh..."
chmod +x "${EXTRACT_DIR}/install.sh"
"${EXTRACT_DIR}/install.sh" "$@"
