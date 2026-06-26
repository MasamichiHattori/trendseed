# TrendSeed UI Mock

海外のトレンド動画分析を閲覧する iPhone 向けアプリの SwiftUI モックです。  
今回は UI 専用で、API 通信、認証、課金、永続化は含みません。

## 1. 推奨フォルダ構成

```text
TrendSeedMock/
├─ App/
│  ├─ TrendSeedMockApp.swift
│  └─ RootTabView.swift
├─ Models/
│  ├─ TrendVideo.swift
│  └─ PlanFeature.swift
├─ Features/
│  ├─ Home/
│  │  ├─ HomeView.swift
│  │  ├─ VideoCardView.swift
│  │  └─ FilterChipRow.swift
│  ├─ Detail/
│  │  └─ VideoDetailView.swift
│  ├─ Favorites/
│  │  └─ FavoritesView.swift
│  └─ Plan/
│     └─ PlanView.swift
├─ Shared/
│  ├─ Mock/
│  │  └─ MockData.swift
│  ├─ Components/
│  │  ├─ StatBadge.swift
│  │  ├─ InsightSection.swift
│  │  └─ PromptBlockView.swift
│  └─ Theme/
│     └─ AppTheme.swift
```

## 2. 画面構成図

```text
RootTabView
├─ ホーム
│  ├─ 検索バー
│  ├─ フィルターチップ
│  ├─ ソートメニュー
│  └─ 動画2列グリッド
│     └─ 動画詳細
│        ├─ サムネイル/基本情報
│        ├─ フック分析
│        ├─ ギャップ分析
│        ├─ 報酬分析
│        ├─ 期待変化分析
│        ├─ 日本向け変換案
│        ├─ 言語依存度
│        └─ 制作プロンプト
├─ お気に入り
│  ├─ 保存済み一覧
│  └─ 空状態モック
└─ プラン
   ├─ 無料プラン
   ├─ プレミアムプラン
   └─ CTA
```

## 3. 画面遷移図

```text
アプリ起動
  ↓
TabView
  ├─ ホーム
  │   └─ 動画カードをタップ
  │        ↓
  │      動画詳細
  ├─ お気に入り
  │   └─ 保存済みカードをタップ
  │        ↓
  │      動画詳細
  └─ プラン
      └─ プレミアムを始める
           ↓
         ダミーアクション
```

## 4. 実装方針

- `SwiftUI`
- `NavigationStack`
- `TabView`
- モックデータのみ
- iPhone 向けのネイティブアプリ風 UI

## 5. 使い方

1. ルートで `xcodegen generate` を実行
2. `TrendSeedMock.xcodeproj` を Xcode で開く
3. `iPhone` シミュレータを選んで実行

`Assets.xcassets` は不要で、サムネイルはグラデーションのダミー表示にしています。
