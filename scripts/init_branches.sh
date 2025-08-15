#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
FINAL_DIR="$REPO_ROOT/final_builds"
SECRETS_FILE="$REPO_ROOT/scripts/.secrets"
if [[ -f "$SECRETS_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$SECRETS_FILE"
fi

push_main() {
  cd "$REPO_ROOT"
  git checkout -B main >/dev/null 2>&1 || true
  git add -A
  if git diff --cached --quiet; then
    echo "No changes to push on main"
  else
    git commit -m "chore(main): update scripts and working_directory"
    git push -u origin main || git push -u origin main -f
  fi
}

BRANCHES=(android-arm64-v8a android-armeabi-v7a android-x86_64)

remote_url() {
  local user="${GITHUB_USER:-}" token="${GITHUB_TOKEN:-}" repo="${GITHUB_REPO:-dpi-warrior-native-tun2socks-binaries}"
  if [[ -n "$user" && -n "$token" ]]; then
    echo "https://$user:$token@github.com/$user/$repo.git"
  elif [[ -n "$user" ]]; then
    echo "https://github.com/$user/$repo.git"
  else
    echo "https://github.com/${GITHUB_USER:-origin}/$repo.git"
  fi
}

has_artifacts() {
  local dir="$1"
  [[ -f "$dir/libtun2socks.so" ]] && return 0 || return 1
}

push_main

for b in "${BRANCHES[@]}"; do
  case "$b" in
    android-*) dir="$FINAL_DIR/android/${b#android-}" ;;
  esac
  mkdir -p "$dir"
  if ! has_artifacts "$dir"; then
    echo "Skipping $b (no artifacts)"
    continue
  fi
  (
    cd "$dir"
    git init >/dev/null 2>&1 || true
    git checkout -B "$b" >/dev/null 2>&1 || true
    git add -A || true
    git commit -m "build: $b artifacts" >/dev/null 2>&1 || true
    git remote remove origin >/dev/null 2>&1 || true
    git remote add origin "$(remote_url)"
    git push -u origin "$b" -f || true
  )
 done 