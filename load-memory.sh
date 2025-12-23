#!/bin/bash
# =============================================================================
# load-memory.sh - 專案記憶載入腳本
#
# 位置: ~/.claude/hooks/load-memory.sh
# 用途: 在 /clear 或啟動時自動載入專案記憶
# =============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
LETTA_BASE_URL="${LETTA_BASE_URL:-http://localhost:8283}"

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

# ─── 規格進度 ────────────────────────────────────────
SPECS_DIR=""
for dir in "docs/specs" "specs" ".specs"; do
    [ -d "$dir" ] && SPECS_DIR="$dir" && break
done

if [ -n "$SPECS_DIR" ]; then
    TASKS_FILES=$(find "$SPECS_DIR" -name "tasks.md" -mtime -14 2>/dev/null | head -5)

    if [ -n "$TASKS_FILES" ]; then
        echo ""
        echo -e "${C_DIM}─── 規格 ───${C_RESET}"

        echo "$TASKS_FILES" | while read -r task_file; do
            [ -z "$task_file" ] && continue
            spec_name=$(dirname "$task_file" | xargs basename)

            # 計算任務數
            in_prog=$(grep -c '\[~\]' "$task_file" 2>/dev/null)
            in_prog=${in_prog:-0}
            pending=$(grep -c '\[ \]' "$task_file" 2>/dev/null)
            pending=${pending:-0}
            completed=$(grep -c '\[x\]' "$task_file" 2>/dev/null)
            completed=${completed:-0}

            total=$((in_prog + pending + completed))
            [ "$total" -eq 0 ] && continue

            # 簡潔顯示: spec_name: ✓10 ~2 ○5
            status=""
            [ "$completed" -gt 0 ] && status="${status}\033[32m✓${completed}\033[0m "
            [ "$in_prog" -gt 0 ] && status="${status}\033[33m~${in_prog}\033[0m "
            [ "$pending" -gt 0 ] && status="${status}\033[2m○${pending}\033[0m"

            printf "  • %-28s %b\n" "$spec_name" "$status"
        done
    fi
fi

# ─── Letta 狀態 ──────────────────────────────────────
LETTA_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 1 "$LETTA_BASE_URL/health" 2>/dev/null)

echo ""
echo -e "${C_DIM}─── Memory ───${C_RESET}"

if [ "$LETTA_HEALTH" = "200" ]; then
    echo -e "  ${C_GREEN}●${C_RESET} Letta  ${C_DIM}${LETTA_BASE_URL}${C_RESET}"

    # 查詢 agents
    AGENTS_RESPONSE=$(curl -s --connect-timeout 1 "$LETTA_BASE_URL/v1/agents" 2>/dev/null)

    if [ -n "$AGENTS_RESPONSE" ] && [ "$AGENTS_RESPONSE" != "[]" ] && [ "$AGENTS_RESPONSE" != "null" ]; then
        echo "$AGENTS_RESPONSE" | python3 -c "
import json, sys
try:
    agents = json.load(sys.stdin)
    if isinstance(agents, list) and len(agents) > 0:
        print('  Agents:')
        for agent in agents[:3]:
            name = agent.get('name', 'unnamed')
            agent_id = agent.get('id', '')[:8]
            print(f'    • {name}')
        if len(agents) > 3:
            print(f'    ... +{len(agents) - 3} more')
except:
    pass
" 2>/dev/null
    fi
else
    echo -e "  ${C_DIM}○ Letta offline${C_RESET}"
fi

# CLAUDE.md 狀態
if [ -f "CLAUDE.md" ]; then
    echo -e "  ${C_GREEN}●${C_RESET} CLAUDE.md"
else
    echo -e "  ${C_DIM}○ CLAUDE.md (建議建立)${C_RESET}"
fi

# ─── 提醒 ────────────────────────────────────────────
if [ -f "CLAUDE.md" ] && grep -q "PDCA\|Milestone" "CLAUDE.md" 2>/dev/null; then
    echo ""
    echo -e "${C_DIM}─── 提醒 ───${C_RESET}"
    echo -e "  ${C_DIM}•${C_RESET} 新功能先建 specs/"
    echo -e "  ${C_DIM}•${C_RESET} Milestone 完成後 commit"
    if [ "$LETTA_HEALTH" = "200" ]; then
        echo -e "  ${C_DIM}•${C_RESET} 🧠 可查詢 Letta 歷史決策"
    fi
fi

echo ""

exit 0
