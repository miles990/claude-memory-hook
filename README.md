# Claude Code Memory Hook

> 解決 Claude Code 每次 `/clear` 就失憶的問題

## 痛點

```
Session 1                    Session 2
┌─────────────────┐          ┌─────────────────┐
│ 我知道這個專案    │   /clear  │ 這是什麼專案？   │ ← 完全失憶
│ 架構用 React...  │  ───────>  │ 要做什麼？       │
│ 決定用 Zustand.. │          │ 從頭開始...      │
└─────────────────┘          └─────────────────┘
```

**每次新 session 都要：**
- 重新解釋專案背景
- 回顧上次做到哪裡
- 提醒開發規範

## 解決方案

這個 Hook 在每次 Claude Code 啟動時**自動顯示專案狀態**，讓 Claude 立即進入工作狀態。

```
╭───────────────────────────────────────────────╮
│  📚 my-project
╰───────────────────────────────────────────────╯

─── Git ───
  main  abc1234 feat: 新增功能

  def5678 fix: 修復 bug
  ghi9012 refactor: 重構模組

  ⚠ 2 個未提交變更

─── 規格 ───
  • feature-a                    ✓10 ~2 ○5
  • feature-b                    ✓3 ○8

─── Memory ───
  ● Letta Cloud
    [project] # My Project - 類型: Web application...
    [decisions] # 架構決策 - 選用 Zustand 因為輕量...
  ● CLAUDE.md

─── 提醒 ───
  • 新功能先建 specs/
  • Milestone 完成後 commit
```

符號說明：`✓` 完成 · `~` 進行中 · `○` 待處理

## 與 claude-dev-memory 的關係

這兩個工具是互補的：

| 工具 | 類型 | 職責 |
|------|------|------|
| **claude-memory-hook** | Hook | 啟動時**顯示**狀態（被動） |
| [claude-dev-memory](https://github.com/miles990/claude-dev-memory) | MCP Server | 提供**讀寫**記憶工具（主動） |

```
┌─────────────────────────────────────────────────────────────────┐
│  claude-memory-hook（本專案）                                    │
│  → Session 開始時自動執行                                        │
│  → 顯示 Git、規格進度、Letta 記憶摘要、提醒                       │
├─────────────────────────────────────────────────────────────────┤
│  claude-dev-memory                                              │
│  → 提供 MCP 工具讓 Claude 主動讀寫記憶                           │
│  → memory_recall / memory_update / memory_archive / memory_search│
└─────────────────────────────────────────────────────────────────┘
```

## 安裝

### 快速安裝（推薦）

```bash
curl -fsSL https://raw.githubusercontent.com/miles990/claude-memory-hook/main/install.sh | bash
```

### 手動安裝

1. **下載腳本**

```bash
mkdir -p ~/.claude/hooks
curl -o ~/.claude/hooks/load-memory.sh \
  https://raw.githubusercontent.com/miles990/claude-memory-hook/main/load-memory.sh
chmod +x ~/.claude/hooks/load-memory.sh
```

2. **設定 Hook**

編輯 `~/.claude/settings.json`：

```json
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
```

3. **重啟 Claude Code**

## 功能

### Git 狀態
- 當前分支和最新 commit
- 最近 3 筆 commit 記錄
- 未提交變更提醒

### 規格進度
自動掃描 `docs/specs/`、`specs/`、`.specs/` 目錄，統計 `tasks.md` 中的任務狀態：
- `[x]` 完成
- `[~]` 進行中
- `[ ]` 待處理

推薦搭配 [@pimzino/spec-workflow-mcp](https://www.npmjs.com/package/@pimzino/spec-workflow-mcp) 產生規格文件。

### Letta 記憶整合
支援 Letta Cloud 或本地 Server，顯示 Core Memory 摘要：
- project：專案概述
- learnings：學習紀錄
- decisions：架構決策

### 自訂提醒
建立提醒檔案，每次對話開始時顯示：

```
~/.claude/reminders.txt              # 全域預設
your-project/.claude/reminders.txt   # 專案覆蓋（優先）
```

範例：
```
新功能必須先建 specs/（規劃優先）
PDCA 循環：Plan→Do→Check→Act
按 Milestone 順序執行，完成後 commit
遇錯先診斷再修正，不盲目重試
完成後問：目標？方向？下一步？
```

## 設定

### 環境變數

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `LETTA_API_KEY` | - | Letta Cloud API key（優先使用）|
| `LETTA_AGENT_ID` | - | 專案專屬的 Letta Agent ID |
| `LETTA_BASE_URL` | `http://localhost:8283` | 本地 Letta server URL（fallback）|

### Letta 設定方式

**方式一：環境變數**
```bash
# 在專案 .env 中
LETTA_API_KEY=sk-let-xxxxx
LETTA_AGENT_ID=agent-xxxxx
```

**方式二：專案配置檔**
```json
// .claude/letta.json
{
  "agent_id": "agent-xxxxx"
}
```

## 範本

專案提供核心指導原則範本：

```
templates/
├── CLAUDE.md        # 核心指導原則（完整版）
└── reminders.txt    # 精簡提醒（與 CLAUDE.md 配套）
```

使用方式：
```bash
cp ~/.claude/hooks/templates/CLAUDE.md ./CLAUDE.md
mkdir -p .claude
cp ~/.claude/hooks/templates/reminders.txt ./.claude/reminders.txt
```

## 前置需求

| 工具 | 用途 | macOS/Linux | Windows |
|------|------|:-----------:|:-------:|
| `bash` | 執行腳本 | ✅ 預裝 | ⚠️ WSL/Git Bash |
| `git` | 顯示 Git 狀態 | ✅ 預裝 | ⚠️ 需安裝 |
| `curl` | 檢查 Letta server | ✅ 預裝 | ⚠️ WSL/Git Bash |
| `python3` | 解析 JSON | ✅ 預裝 | ⚠️ 需安裝 |

## 進階設定

### 專案專屬覆蓋

如果特定專案需要完全不同的 hook 行為：

```
your-project/
└── .claude/
    └── hooks/
        └── load-memory.sh  # 會覆蓋全域腳本
```

## 相關連結

- [claude-dev-memory](https://github.com/miles990/claude-dev-memory) - MCP Server，提供 memory_recall/update/archive/search 工具
- [Claude Code](https://claude.ai/code)
- [Claude Code Hooks 文件](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Letta (MemGPT)](https://docs.letta.com/)

## License

MIT
