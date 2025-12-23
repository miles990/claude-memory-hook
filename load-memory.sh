#!/bin/bash
# =============================================================================
# load-memory.sh - 通用自動載入記憶腳本
#
# 位置: ~/.claude/hooks/load-memory.sh
# 用途: 在 /clear 或啟動時自動載入專案記憶
#
# 功能:
# 1. 載入本地專案狀態 (Git, specs/)
# 2. 查詢 Letta 長期記憶 (如果 server 運行中)
# 3. 顯示開發提醒
# =============================================================================

# 專案目錄 (Claude Code 會設定 CLAUDE_PROJECT_DIR)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Letta 設定 (可透過環境變數覆蓋)
LETTA_BASE_URL="${LETTA_BASE_URL:-http://localhost:8283}"

# 顏色 (如果終端支援)
if [ -t 1 ]; then
    BOLD='\033[1m'
    RESET='\033[0m'
else
    BOLD=''
    RESET=''
fi

echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║  📚 自動載入專案記憶 - $PROJECT_NAME"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""

# -----------------------------------------------------------------------------
# Part 1: 本地專案狀態
# -----------------------------------------------------------------------------
echo "┌─────────────────────────────────────────────────────────────────────┐"
echo "│  🔍 本地專案狀態                                                    │"
echo "└─────────────────────────────────────────────────────────────────────┘"

cd "$PROJECT_DIR" 2>/dev/null || {
    echo "⚠️  無法進入專案目錄: $PROJECT_DIR"
    exit 0
}

# 檢查是否為 Git 專案
if [ -d ".git" ]; then
    echo ""
    echo "📊 Git 狀態:"
    BRANCH=$(git branch --show-current 2>/dev/null)
    echo "   分支: ${BRANCH:-'(detached)'}"
    echo "   最近 commit:"
    git log --oneline -3 2>/dev/null | sed 's/^/   /' || echo "   (無 commit)"

    # 未提交的變更
    CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CHANGES" -gt 0 ]; then
        echo ""
        echo "   ⚠️  有 $CHANGES 個未提交的變更"
    fi
else
    echo ""
    echo "📊 專案狀態: (非 Git 專案)"
fi

# 檢查規格文件 (支援多種目錄結構)
echo ""
echo "📋 進行中的規格:"
SPECS_DIR=""
for dir in "docs/specs" "specs" ".specs" "documentation/specs"; do
    if [ -d "$dir" ]; then
        SPECS_DIR="$dir"
        break
    fi
done

if [ -n "$SPECS_DIR" ]; then
    FOUND_TASKS=0
    find "$SPECS_DIR" -name "tasks.md" -mtime -14 2>/dev/null | head -5 | while read -r task_file; do
        if [ -n "$task_file" ]; then
            spec_name=$(dirname "$task_file" | xargs basename)
            in_progress=$(grep -c '\[~\]' "$task_file" 2>/dev/null)
            in_progress=${in_progress:-0}
            pending=$(grep -c '\[ \]' "$task_file" 2>/dev/null)
            pending=${pending:-0}
            completed=$(grep -c '\[x\]' "$task_file" 2>/dev/null)
            completed=${completed:-0}
            total=$((in_progress + pending + completed))
            if [ "$total" -gt 0 ]; then
                printf "   • %s: %d 進行中, %d 待處理, %d 完成\n" "$spec_name" "$in_progress" "$pending" "$completed"
                FOUND_TASKS=1
            fi
        fi
    done
    if [ "$(find "$SPECS_DIR" -name 'tasks.md' -mtime -14 2>/dev/null | wc -l)" -eq 0 ]; then
        echo "   (無最近 14 天內修改的規格)"
    fi
else
    echo "   (無規格目錄)"
fi

# 檢查 CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    echo ""
    echo "📄 CLAUDE.md: ✅ 存在"
else
    echo ""
    echo "📄 CLAUDE.md: ❌ 不存在 (建議建立)"
fi

# -----------------------------------------------------------------------------
# Part 2: Letta 長期記憶
# -----------------------------------------------------------------------------
echo ""
echo "┌─────────────────────────────────────────────────────────────────────┐"
echo "│  🧠 長期記憶 (Letta)                                                │"
echo "└─────────────────────────────────────────────────────────────────────┘"

# 檢查 Letta server
LETTA_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "$LETTA_BASE_URL/health" 2>/dev/null)

if [ "$LETTA_HEALTH" = "200" ]; then
    echo ""
    echo "✅ Letta Server 連線正常 ($LETTA_BASE_URL)"
    echo ""

    # 查詢 agents
    AGENTS_RESPONSE=$(curl -s --connect-timeout 2 "$LETTA_BASE_URL/v1/agents" 2>/dev/null)

    if [ -n "$AGENTS_RESPONSE" ] && [ "$AGENTS_RESPONSE" != "[]" ] && [ "$AGENTS_RESPONSE" != "null" ]; then
        echo "📁 可用的 Agents:"
        echo "$AGENTS_RESPONSE" | python3 -c "
import json, sys
try:
    agents = json.load(sys.stdin)
    if isinstance(agents, list):
        for agent in agents[:5]:
            name = agent.get('name', 'unnamed')
            agent_id = agent.get('id', '')[:8]
            print(f'   • {name} ({agent_id}...)')
        if len(agents) > 5:
            print(f'   ... 還有 {len(agents) - 5} 個')
except Exception as e:
    print(f'   (解析錯誤: {e})')
" 2>/dev/null || echo "   (無法解析 agents)"

        # 查詢與專案相關的 agent
        PROJECT_AGENT=$(echo "$AGENTS_RESPONSE" | python3 -c "
import json, sys
project = '$PROJECT_NAME'.lower()
try:
    agents = json.load(sys.stdin)
    for agent in agents:
        name = agent.get('name', '').lower()
        if project in name or 'memory' in name:
            print(agent.get('name'))
            break
except:
    pass
" 2>/dev/null)

        if [ -n "$PROJECT_AGENT" ]; then
            echo ""
            echo "🎯 專案相關 Agent: $PROJECT_AGENT"
        fi

        echo ""
        echo "💡 查詢歷史記憶: 「查詢 Letta 中關於 [主題] 的記錄」"
    else
        echo "📁 尚無 Agents"
        echo ""
        echo "💡 建議建立專案記憶 Agent:"
        echo "   名稱: $PROJECT_NAME-memory"
    fi
else
    echo ""
    echo "⚠️  Letta Server 未運行"
    echo "   URL: $LETTA_BASE_URL"
    echo "   啟動: letta server"
    echo ""
    echo "💡 目前只使用本地記憶 (CLAUDE.md, specs/)"
fi

# -----------------------------------------------------------------------------
# Part 3: 開發提醒 (讀取 CLAUDE.md 關鍵規則)
# -----------------------------------------------------------------------------
echo ""
echo "┌─────────────────────────────────────────────────────────────────────┐"
echo "│  💡 開發提醒                                                        │"
echo "└─────────────────────────────────────────────────────────────────────┘"
echo ""

# 檢查 CLAUDE.md 是否有 PDCA 相關內容
if [ -f "CLAUDE.md" ] && grep -q "PDCA\|Milestone\|規劃" "CLAUDE.md" 2>/dev/null; then
    echo "• 遵循 CLAUDE.md 中定義的開發原則"
    echo "• 新功能: 先建立 specs/ 規格文件"
    echo "• 每個 Milestone 完成後: commit & push"
else
    echo "• 新功能開始前: 先確認需求和方向"
    echo "• 遇到問題時: 查詢是否有相關歷史"
    echo "• 完成功能後: 記得測試和提交"
fi

# 如果有 Letta 連線，加入提醒
if [ "$LETTA_HEALTH" = "200" ]; then
    echo "• 🧠 長期記憶可用: 可查詢歷史決策"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════"

exit 0
