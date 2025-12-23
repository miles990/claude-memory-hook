# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 核心指導原則 (MANDATORY)

> **以下原則必須在任何時候、任何對話中強制遵守，包括 `/clear` 後的新對話**

### 1. 先規劃、再逐步執行 (Plan First, Execute Incrementally)

> **任何任務開始前，都必須先完成規劃，再按照規劃逐步執行**

```
Phase 1: 規劃階段
├── 需求分析 → 理解目標和約束
├── 架構設計 → 評估現有結構、規劃新增內容
├── 任務分解 → 拆分為可驗證的 Milestones
└── 輸出文件 → requirements.md, design.md, tasks.md

Phase 2: 執行階段
├── 按 Milestone 順序執行
├── 每個任務遵循 PDCA 循環
├── 即時更新 tasks.md 狀態
└── 每個 Milestone 完成後 commit & push
```

**規劃文件結構：**
```
docs/specs/{feature-name}/
├── requirements.md   # 需求規格 (目標、功能需求、驗收標準)
├── design.md         # 設計文件 (架構、組件、資料流)
└── tasks.md          # 任務清單 (Milestones、任務、狀態追蹤)
```

**何時需要規劃？**
| 情況 | 是否需要規劃文件 |
|------|-----------------|
| 新功能開發 | ✅ 必須 |
| 跨多檔案修改 | ✅ 必須 |
| Bug 修復 (簡單) | ❌ 直接修 |
| Bug 修復 (複雜/多處) | ✅ 建議 |
| 重構 | ✅ 必須 |
| 單檔案小修改 | ❌ 直接修 |

---

### 2. PDCA 循環 (Plan-Do-Check-Act)

每個功能模組的開發都必須遵循：

```
Plan   → 說明目標、預期結果、實作方式
Do     → 執行實作（寫程式碼）
Check  → 立即驗證（編譯、測試）
Act    → 根據結果：通過→下一步 / 失敗→診斷修正
```

**強制規則：**
- ❌ 禁止：連續寫多個檔案不驗證
- ❌ 禁止：跳過 Check 直接進入下一個任務
- ✅ 必須：每完成一個檔案/功能就編譯驗證
- ✅ 必須：驗證失敗時先診斷再修正（不盲目重試）

---

### 3. Milestone 導向

實作必須按照 tasks.md 定義的順序進行：
- 按 M1 → M2 → M3 → ... 順序執行
- 每個 Milestone 內的任務按編號順序執行
- 前置 Milestone 未完成不得跳到下一個

---

### 4. 有方向的修正

遇到錯誤時的處理流程：
```
錯誤發生 → 診斷原因 → 分析影響 → 確定修正方向 → 執行修正 → 驗證
```
- 不盲目重試相同的方法
- 記錄錯誤原因和修正方式

---

### 5. 任務追蹤與記錄

**即時更新 tasks.md：**
- 任務開始：標記為 `[~]` in_progress
- 任務完成：標記為 `[x]` completed
- 任務阻擋：標記為 `[!]` blocked 並說明原因

**Git 提交規則：**
- 每個 Milestone 完成後必須 commit & push
- Commit message 格式：`feat(M#): 完成描述`

---

### 6. 目標確認與方向校準

> **功能完成後、繼續下一步前，必須停下來確認目標和方向**

完成功能/Milestone 後必須問：

1. **現在的目標是什麼？** → 重新確認當前要達成的目標
2. **方向有沒有偏離目標？** → 檢視已完成的工作是否朝向目標前進
3. **下一步是什麼？** → 明確下一個行動，而非盲目繼續

**檢查點 (Checkpoint):**
- 每個 Milestone 完成後
- 實作過程中感覺複雜度增加時
- 用戶說「繼續」但沒有明確指示時
- 發現需要額外工作（非原計劃）時

---

## 專案資訊

<!-- 以下請根據你的專案自訂 -->

### 技術棧
- Frontend:
- Backend:
- Database:

### 開發指令
```bash
# 安裝依賴
npm install

# 開發模式
npm run dev

# 建置
npm run build

# 測試
npm test
```

### 目錄結構
```
src/
├── components/    # UI 元件
├── pages/         # 頁面
├── services/      # API 服務
└── utils/         # 工具函數
```
