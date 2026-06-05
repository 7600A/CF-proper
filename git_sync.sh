#!/bin/bash
# git_sync.sh
# 功能：将当前目录下的 ip.txt 文件强制推送到 GitHub 仓库的指定分支
# 使用场景：配合 Cloudflare IP 优选工具，自动同步优选结果到远程仓库
#
# 安全提醒：请通过环境变量 GITHUB_TOKEN 提供 Personal Access Token，
# 不要把真实令牌写入本文件并提交到仓库。

# ==================== GitHub 认证信息 ====================
github_token="${GITHUB_TOKEN:-your_github_personal_access_token_here}"
github_username="${GITHUB_USERNAME:-7600A}"
repo_name="${GITHUB_REPO_NAME:-CF-proper}"
branch="${GITHUB_BRANCH:-${GITHUB_REF_NAME:-main}}"

if [ -n "${GITHUB_REPOSITORY:-}" ] && [ -z "${GITHUB_REPO_NAME:-}" ]; then
    github_username="${GITHUB_REPOSITORY%%/*}"
    repo_name="${GITHUB_REPOSITORY#*/}"
fi

if [ "$github_token" = "your_github_personal_access_token_here" ]; then
    echo "请先设置 GITHUB_TOKEN 环境变量。" >&2
    exit 1
fi

# ==================== 切换到脚本所在目录 ====================
cd "$(dirname "$0")" || exit 1

# ==================== 拉取远程最新更新 ====================
git pull origin "$branch"

# ==================== 暂存并提交 ip.txt ====================
git add ip.txt
if git diff --cached --quiet; then
    echo "ip.txt 无变化，跳过推送"
    exit 0
fi

commit_msg="Update ip.txt on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_msg"

# ==================== 强制推送到 GitHub ====================
git push "https://${github_token}@github.com/${github_username}/${repo_name}.git" "$branch" --force

echo "✅ ip.txt 已推送到 GitHub"
