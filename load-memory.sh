#!/bin/bash
# =============================================================================
# load-memory.sh - Claude Code Session Hook
#
# 位置: ~/.claude/hooks/load-memory.sh
# 用途: 在 /clear 或啟動時顯示專案狀態
# =============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# 顏色定義
C_RESET='\033[0m'
C_DIM='\033[2m'
C_CYAN='\033[36m'
C_YELLOW='\033[33m'
C_GREEN='\033[32m'
C_RED='\033[31m'
C_BOLD='\033[1m'

# 標題
echo "Memory"
echo -e "${C_BOLD}${C_CYAN}╭───────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}│${C_RESET}  📚 ${C_BOLD}$PROJECT_NAME${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}╰───────────────────────────────────────────────╯${C_RESET}"

cd "$PROJECT_DIR" 2>/dev/null || exit 0

# ─── Git 狀態 ────────────────────────────────────────
if [ -d ".git" ]; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
    LAST_COMMIT=$(git log --oneline -1 2>/dev/null | cut -c1-50)

    echo ""
    echo -e "${C_DIM}─── Git ───${C_RESET}"
    echo -e "  ${C_BOLD}$BRANCH${C_RESET}  ${C_DIM}$LAST_COMMIT${C_RESET}"

    # 顯示最近 3 個 commits
    echo -e "${C_DIM}"
    git log --oneline -3 2>/dev/null | tail -2 | sed 's/^/  /'
    echo -e "${C_RESET}"

    if [ "$CHANGES" -gt 0 ]; then
        echo -e "  ${C_YELLOW}⚠ $CHANGES 個未提交變更${C_RESET}"
    fi
fi


# ─── 提醒 ────────────────────────────────────────────
# 優先順序: 專案 .claude/reminders.txt > 全域 ~/.claude/reminders.txt > 預設
REMINDERS_FILE=""
if [ -f ".claude/reminders.txt" ]; then
    REMINDERS_FILE=".claude/reminders.txt"
elif [ -f "$HOME/.claude/reminders.txt" ]; then
    REMINDERS_FILE="$HOME/.claude/reminders.txt"
fi

if [ -n "$REMINDERS_FILE" ]; then
    echo ""
    echo -e "${C_DIM}─── 提醒 ───${C_RESET}"
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        [[ "$line" =~ ^# ]] && continue
        echo -e "  ${C_DIM}•${C_RESET} $line"
    done < "$REMINDERS_FILE"
elif [ -f "CLAUDE.md" ] && grep -q "PDCA\|Milestone" "CLAUDE.md" 2>/dev/null; then
    # 預設提醒（當沒有自訂檔案時）
    echo ""
    echo -e "${C_DIM}─── 提醒 ───${C_RESET}"
    echo -e "  ${C_DIM}•${C_RESET} 新功能先建 specs/"
    echo -e "  ${C_DIM}•${C_RESET} Milestone 完成後 commit"
fi

echo ""

exit 0
