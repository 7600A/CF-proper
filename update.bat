@echo off
chcp 65001 >nul
setlocal

rem ============================================================
rem  CF-proper 一键更新脚本
rem  1. 本地测速生成 ip.txt
rem  2. 若 ip.txt 有变化，自动提交并推送到 GitHub main 分支
rem  双击即可运行。
rem ============================================================

cd /d "%~dp0"

echo ============================================================
echo   CF-proper 节点优选 - 一键更新
echo ============================================================
echo.

rem ---------- 查找可用的 Python ----------
set "PY="
py --version >nul 2>&1 && set "PY=py"
if not defined PY (
    if exist "C:\Program Files\Python312\python.exe" set "PY=C:\Program Files\Python312\python.exe"
)
if not defined PY (
    where python >nul 2>&1 && set "PY=python"
)
if not defined PY (
    echo [错误] 找不到可用的 Python，请先安装 Python 3.x。
    goto :end
)
echo 使用 Python: %PY%
echo.

rem ---------- 运行测速 ----------
echo [1/3] 开始本地测速，请耐心等待（约 5-10 分钟）...
echo.
%PY% main.py
if errorlevel 1 (
    echo.
    echo [错误] 测速脚本运行失败，已中止，未做任何提交。
    goto :end
)

echo.
echo [2/3] 检查 ip.txt 是否有变化...

rem ---------- 判断是否有改动 ----------
git diff --quiet -- ip.txt
if not errorlevel 1 (
    echo ip.txt 无变化，跳过提交。
    goto :done
)

echo ip.txt 已更新，准备提交并推送...
echo.
echo [3/3] 提交并推送到 GitHub...

git add ip.txt
for /f "tokens=1-3 delims=/: " %%a in ("%date% %time%") do set "STAMP=%date% %time%"
git commit -m "更新 ip.txt (%date% %time%)"
if errorlevel 1 (
    echo [错误] 提交失败。
    goto :end
)

git push origin main
if errorlevel 1 (
    echo.
    echo [错误] 推送失败。可能是网络问题或需要重新登录 GitHub。
    echo 稍后可手动运行: git push origin main
    goto :end
)

echo.
echo ============================================================
echo   完成！新的 ip.txt 已推送到 GitHub。
echo ============================================================
goto :done

:done
echo.
echo 当前 ip.txt 内容:
echo ------------------------------------------------------------
type ip.txt
echo ------------------------------------------------------------

:end
echo.
pause
endlocal
