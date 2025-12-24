# Claude Code Memory Hook

自動載入專案記憶的 Claude Code Hook，讓你在 `/clear` 或啟動時自動恢復專案上下文。

## 功能

- **自動載入專案狀態** - Git 分支、最近 commits、未提交變更
- **規格追蹤** - 顯示進行中的 `tasks.md` 狀態
- **Letta 整合** - 支援 Letta Cloud 或本地 Server，自動載入長期記憶
- **通用設計** - 一次設定，所有專案都能用

## 截圖

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
    [project] # My Project - 類型: Web application with React...
    [decisions] # 架構決策 - 選用 Zustand 因為輕量...
  ● CLAUDE.md

─── 提醒 ───
  • 新功能先建 specs/
  • Milestone 完成後 commit
```

符號說明：`✓` 完成 · `~` 進行中 · `○` 待處理

## 範本 (Templates)

專案提供核心指導原則範本，幫助你快速建立 Claude Code 開發規範：

```
templates/
├── CLAUDE.md        # 核心指導原則（完整版）
└── reminders.txt    # 精簡提醒（與 CLAUDE.md 配套）
```

### 使用方式

```bash
# 複製範本到你的專案
cp ~/.claude/hooks/templates/CLAUDE.md ./CLAUDE.md
mkdir -p .claude
cp ~/.claude/hooks/templates/reminders.txt ./.claude/reminders.txt

# 根據專案需求修改
```

### 核心指導原則包含

| 原則 | 說明 |
|------|------|
| 先規劃再執行 | 新功能必須先建 specs/ |
| PDCA 循環 | Plan→Do→Check→Act |
| Milestone 導向 | 按順序執行，完成後 commit |
| 有方向的修正 | 遇錯先診斷，不盲目重試 |
| 目標確認 | 完成後問：目標？方向？下一步？ |

> 💡 這套原則經過實戰驗證，能有效提升 Claude Code 的開發品質和一致性。

## 前置需求

| 工具 | 用途 | macOS | Linux | Windows |
|------|------|:-----:|:-----:|:-------:|
| `bash` | 執行腳本 | ✅ 預裝 | ✅ 預裝 | ⚠️ WSL/Git Bash |
| `git` | 顯示 Git 狀態 | ✅ 預裝 | ✅ 預裝 | ⚠️ 需安裝 |
| `curl` | 檢查 Letta server | ✅ 預裝 | ✅ 預裝 | ⚠️ WSL/Git Bash |
| `python3` | 解析 JSON | ✅ 預裝 | ✅ 預裝 | ⚠️ 需安裝 |
| `find`, `grep` | 檔案搜尋 | ✅ 預裝 | ✅ 預裝 | ⚠️ WSL/Git Bash |

> **macOS / Linux**：所有依賴預裝，無需額外安裝。
>
> **Windows**：需使用 [WSL](https://docs.microsoft.com/windows/wsl/) 或 [Git Bash](https://gitforwindows.org/)。

## 安裝

### 快速安裝 (推薦)

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

編輯 `~/.claude/settings.json`，加入：

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

## 設定

### 環境變數

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `LETTA_API_KEY` | - | Letta Cloud API key（優先使用）|
| `LETTA_AGENT_ID` | - | 專案專屬的 Letta Agent ID |
| `LETTA_BASE_URL` | `http://localhost:8283` | 本地 Letta server URL（fallback）|

> 💡 設定 `LETTA_API_KEY` 後會優先使用 Letta Cloud，否則 fallback 到本地 Server。

### tasks.md 產生方式

推薦使用 [@pimzino/spec-workflow-mcp](https://www.npmjs.com/package/@pimzino/spec-workflow-mcp) 自動產生：

```bash
# 安裝
claude mcp add spec-workflow -s user -- npx -y @pimzino/spec-workflow-mcp@latest

# 啟動 Dashboard（可選）
npx -y @pimzino/spec-workflow-mcp@latest --dashboard
```

特色：實時 Web Dashboard、VSCode 擴展、審批工作流、11 種語言支援

產生的結構：
```
docs/specs/{feature}/
├── requirements.md   # 需求規格
├── design.md         # 設計文件
└── tasks.md          # 任務清單 ← 本 hook 讀取此檔
```

tasks.md 使用標準 markdown checkbox：
- `[x]` 完成的任務
- `[~]` 進行中的任務
- `[ ]` 待處理的任務

### 支援的目錄結構

腳本會自動偵測以下規格目錄：
- `docs/specs/`
- `specs/`
- `.specs/`

### 自訂提醒

可建立提醒檔案，每次對話開始時顯示：

```
~/.claude/reminders.txt              # 全域預設
your-project/.claude/reminders.txt   # 專案覆蓋（優先）
```

範例 `.claude/reminders.txt`：
```
# 核心指導原則 (MUST FOLLOW)
新功能必須先建 specs/（規劃優先）
PDCA 循環：Plan→Do→Check→Act
按 Milestone 順序執行，完成後 commit
遇錯先診斷再修正，不盲目重試
完成後問：目標？方向？下一步？
```

> 💡 **雙重強化**：提醒內容建議與 `CLAUDE.md` 核心規則同步，這樣 Claude 會在 CLAUDE.md（基礎層）和 Hook 提醒（強化層）雙重注意這些原則。

### 專案專屬覆蓋

如果特定專案需要完全不同的 hook 行為，可在專案目錄建立：

```
your-project/
└── .claude/
    └── hooks/
        └── load-memory.sh  # 會覆蓋全域腳本
```

## 搭配 Letta 使用

這個 hook 設計用來搭配 [Letta](https://docs.letta.com/) 作為長期記憶後端，支援 **Letta Cloud** 或**本地 Server**。

### 方式一：Letta Cloud（推薦）

1. 註冊 [Letta Cloud](https://app.letta.com) 取得 API key
2. 建立 Agent 並取得 Agent ID
3. 在專案 `.env` 加入：

```bash
LETTA_API_KEY=sk-let-xxxxx
LETTA_AGENT_ID=agent-xxxxx
```

或在 `.claude/letta.json` 設定專案專屬 Agent：

```json
{
  "agent_id": "agent-xxxxx"
}
```

### 方式二：本地 Server

```bash
# Docker 方式啟動
docker run -p 8283:8283 letta/letta:latest

# 或 pip 安裝
pip install letta
letta server
```

### 分層記憶架構

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 1: 即時記憶 (Claude Code 本地)                           │
│  ├── CLAUDE.md      → 專案規則                                  │
│  ├── specs/         → 當前功能規格                              │
│  └── TodoWrite      → 當前任務                                  │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2: 長期記憶 (Letta)                                      │
│  ├── Core Memory    → 專案架構理解                              │
│  └── Archival       → 歷史決策記錄                              │
└─────────────────────────────────────────────────────────────────┘
```

## License

MIT

## 相關連結

- [letta-memory-mcp](https://github.com/miles990/letta-memory-mcp) - MCP Server for Letta memory tools (memory_recall, memory_update, memory_archive)
- [Claude Code](https://claude.ai/code)
- [Claude Code Hooks 文件](https://code.claude.com/docs/en/hooks)
- [Letta (MemGPT)](https://docs.letta.com/)
