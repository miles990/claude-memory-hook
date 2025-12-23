#!/bin/bash
# =============================================================================
# Claude Memory Hook 安裝腳本
# =============================================================================

set -e

REPO_URL="https://raw.githubusercontent.com/miles990/claude-memory-hook/main"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║  📦 安裝 Claude Memory Hook                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""

# 建立目錄
echo "📁 建立目錄..."
mkdir -p "$HOOKS_DIR"

# 下載腳本
echo "⬇️  下載 load-memory.sh..."
curl -fsSL "$REPO_URL/load-memory.sh" -o "$HOOKS_DIR/load-memory.sh"
chmod +x "$HOOKS_DIR/load-memory.sh"
echo "   ✅ 已安裝到 $HOOKS_DIR/load-memory.sh"

# 下載範本
echo ""
echo "📄 下載範本..."
mkdir -p "$HOOKS_DIR/templates"
curl -fsSL "$REPO_URL/templates/CLAUDE.md" -o "$HOOKS_DIR/templates/CLAUDE.md"
curl -fsSL "$REPO_URL/templates/reminders.txt" -o "$HOOKS_DIR/templates/reminders.txt"
echo "   ✅ 已安裝到 $HOOKS_DIR/templates/"

# 設定 hook
echo ""
echo "⚙️  設定 SessionStart hook..."

if [ -f "$SETTINGS_FILE" ]; then
    # 檢查是否已有 hooks 設定
    if grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
        echo "   ⚠️  settings.json 已有 hooks 設定"
        echo "   請手動加入以下設定:"
        echo ""
        echo '   "SessionStart": ['
        echo '     {'
        echo '       "matcher": "",'
        echo '       "hooks": ['
        echo '         {'
        echo '           "type": "command",'
        echo '           "command": "$HOME/.claude/hooks/load-memory.sh"'
        echo '         }'
        echo '       ]'
        echo '     }'
        echo '   ]'
    else
        # 用 python 更新 JSON
        python3 << 'PYTHON_SCRIPT'
import json
import os

settings_file = os.path.expanduser("~/.claude/settings.json")

with open(settings_file, 'r') as f:
    settings = json.load(f)

settings['hooks'] = {
    "SessionStart": [
        {
            "matcher": "",
            "hooks": [
                {
                    "type": "command",
                    "command": "$HOME/.claude/hooks/load-memory.sh"
                }
            ]
        }
    ]
}

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("   ✅ 已更新 settings.json")
PYTHON_SCRIPT
    fi
else
    # 建立新的 settings.json
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/load-memory.sh"
          }
        ]
      }
    ]
  }
}
EOF
    echo "   ✅ 已建立 settings.json"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║  ✅ 安裝完成！                                                        ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 下一步:"
echo "   1. 重啟 Claude Code"
echo "   2. 輸入 /clear 測試效果"
echo ""
echo "📄 可選: 複製範本到專案"
echo "   cp ~/.claude/hooks/templates/CLAUDE.md ./CLAUDE.md"
echo "   mkdir -p .claude && cp ~/.claude/hooks/templates/reminders.txt ./.claude/"
echo ""
echo "🔧 可選: 設置 Letta 長期記憶"
echo "   pip install letta"
echo "   letta server"
echo ""
