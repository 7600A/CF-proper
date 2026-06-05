# git_sync.ps1
# 功能：将当前目录下的 ip.txt 文件强制推送到 GitHub 仓库的指定分支
# 使用场景：配合 Cloudflare IP 优选工具，自动同步优选结果到远程仓库
#
# 安全提醒：请通过环境变量 GITHUB_TOKEN 提供 Personal Access Token，
# 不要把真实令牌写入本文件并提交到仓库。

# ==================== GitHub 认证信息 ====================
$github_token = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } else { "your_github_personal_access_token_here" }
$github_username = if ($env:GITHUB_USERNAME) { $env:GITHUB_USERNAME } else { "7600A" }
$repo_name = if ($env:GITHUB_REPO_NAME) { $env:GITHUB_REPO_NAME } else { "CF-proper" }
$branch = if ($env:GITHUB_BRANCH) { $env:GITHUB_BRANCH } elseif ($env:GITHUB_REF_NAME) { $env:GITHUB_REF_NAME } else { "main" }

if ($env:GITHUB_REPOSITORY -and -not $env:GITHUB_REPO_NAME) {
    $repoParts = $env:GITHUB_REPOSITORY -split "/", 2
    if ($repoParts.Count -eq 2) {
        $github_username = $repoParts[0]
        $repo_name = $repoParts[1]
    }
}

if ($github_token -eq "your_github_personal_access_token_here") {
    Write-Error "请先设置 GITHUB_TOKEN 环境变量。"
    exit 1
}

# ==================== 切换到脚本所在目录 ====================
Set-Location $PSScriptRoot

# ==================== 拉取远程最新更新 ====================
git pull origin $branch

# ==================== 暂存并提交 ip.txt ====================
git add ip.txt
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "ip.txt 无变化，跳过推送"
    exit 0
}

$commit_msg = "Update ip.txt on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commit_msg

# ==================== 强制推送到 GitHub ====================
git push https://${github_token}@github.com/${github_username}/${repo_name}.git $branch --force

Write-Host "✅ ip.txt 已推送到 GitHub"
