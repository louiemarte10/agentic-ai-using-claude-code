@echo off
SET CLAUDECODE=1
cd /d C:\Users\Callbox\louieDevAgent
"C:\Program Files\nodejs\node.exe" dist\index.js >> C:\Users\Callbox\louieDevAgent\store\bot.log 2>&1
