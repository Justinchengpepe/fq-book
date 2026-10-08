#!/usr/bin/env bash

set -euo pipefail

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "检测到未提交改动。请先检查并提交，再运行此脚本。" >&2
  exit 1
fi

branch="$(git branch --show-current)"
remote="$(git remote get-url origin)"

echo "即将推送 ${branch} 到 ${remote}"
git push --set-upstream origin "$branch"
