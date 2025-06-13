# UI/UXデザイン仕様書
Blog Learning System - Notion風エディタ型デザイン（Tailwind CSS）

## デザインコンセプト

### 基本方針
- **執筆に集中**: 記事作成を妨げない最小限のUI
- **学習の可視化**: AI学習状況を直感的に表示
- **シンプル & モダン**: Notion風のクリーンなデザイン
- **Tailwind CSS活用**: ユーティリティファーストでの効率的な実装

### ターゲットユーザー
- ブログ執筆者（個人利用）
- 週2-3回の投稿を継続したい人
- 記事品質向上を目指す人
- AIツールを活用したい人

## Tailwind CSS カラーパレット

### 主要カラー設定
```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        // プライマリブルー（既存のblue-500など使用）
        primary: {
          50: '#eff6ff',   // bg-blue-50
          100: '#dbeafe',  // bg-blue-100
          500: '#3b82f6',  // bg-blue-500
          600: '#2563eb',  // bg-blue-600
          700: '#1d4ed8',  // bg-blue-700
          900: '#1e3a8a',  // bg-blue-900
        },
        // アクセントカラー
        accent: {
          yellow: '#fbbf24',  // bg-amber-400
          green: '#10b981',   // bg-emerald-500
          red: '#ef4444',     // bg-red-500
        }
      }
    }
  }
}
```

### カラー使用ルール
- **背景**: `bg-white`
- **テキスト**: `text-gray-700`, `text-gray-900`
- **アクション**: `bg-blue-500`, `text-blue-600`
- **警告・注意**: `bg-amber-50`, `border-amber-400`
- **成功・完了**: `bg-emerald-50`, `text-emerald-600`
- **エラー**: `bg-red-50`, `text-red-600`

## Tailwind Typography システム

### フォントサイズ階層
```css
/* 見出し */
text-4xl    /* 36px - メインタイトル */
text-3xl    /* 30px - セクションタイトル */
text-2xl    /* 24px - サブセクション */
text-xl     /* 20px - 小見出し */
text-lg     /* 18px - 強調テキスト */

/* 本文 */
text-base   /* 16px - 標準本文 */
text-sm     /* 14px - 小さい本文 */
text-xs     /* 12px - キャプション */

/* フォントウェイト */
font-normal    /* 400 */
font-medium    /* 500 */
font-semibold  /* 600 */
font-bold      /* 700 */

/* 行間 */
leading-tight   /* 1.25 */
leading-normal  /* 1.5 */
leading-relaxed /* 1.625 */
```

## レイアウト設計（Tailwind）

### コンテナ設計
```html
<!-- メインコンテナ -->
<div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
  <!-- コンテンツ -->
</div>

<!-- セクション間隔 -->
<div class="space-y-6 sm:space-y-8">
  <!-- セクション1 -->
  <!-- セクション2 -->
</div>
```

### レスポンシブ対応
```html
<!-- モバイルファースト -->
<div class="p-4 sm:p-6 lg:p-8">
  <h1 class="text-2xl sm:text-3xl lg:text-4xl">
    <!-- タイトル -->
  </h1>
</div>

<!-- グリッドレイアウト -->
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
  <!-- グリッドアイテム -->
</div>
```

## コンポーネント設計（Tailwind Classes）

### 1. ヘッダーコンポーネント
```html
<header class="sticky top-0 z-10 bg-white/95 backdrop-blur-sm border-b border-gray-200">
  <div class="max-w-4xl mx-auto px-6 py-4">
    <div class="flex items-center justify-between">
      <!-- ロゴ -->
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 bg-gray-900 rounded-md flex items-center justify-center">
          <span class="text-white font-bold text-sm">BL</span>
        </div>
        <h1 class="text-lg font-medium text-gray-900">Blog Learning</h1>
      </div>
      
      <!-- 右側 -->
      <div class="flex items-center space-x-4">
        <div class="flex items-center text-sm text-gray-500 bg-gray-100 px-3 py-1 rounded-full">
          <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
          AI学習済み
        </div>
        <button class="bg-blue-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-blue-700 transition-colors">
          公開
        </button>
      </div>
    </div>
  </div>
</header>
```

### 2. タイトル入力エリア
```html
<div class="mb-8">
  <input 
    type="text" 
    placeholder="無題"
    class="w-full text-4xl font-bold text-gray-900 placeholder-gray-400 border-none outline-none bg-transparent resize-none"
  />
  <div class="flex items-center mt-4 space-x-4 text-sm text-gray-500">
    <div class="flex items-center">
      <span class="mr-1">📅</span>
      <span>2024年1月15日</span>
    </div>
    <div class="flex items-center">
      <span class="mr-1">🏷️</span>
      <span class="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-xs">コーチング</span>
    </div>
    <div class="flex items-center">
      <span class="mr-1">🎯</span>
      <span>推奨体験比率: 45%</span>
    </div>
  </div>
</div>
```

### 3. 気づきメモセクション
```html
<div class="mb-8 bg-gray-50 rounded-lg p-6 border-l-4 border-amber-400">
  <div class="flex items-center mb-3">
    <span class="text-amber-600 mr-2 text-lg">💭</span>
    <h3 class="font-medium text-gray-900">気づきメモ</h3>
  </div>
  <textarea 
    class="w-full bg-transparent border-none outline-none resize-none text-gray-700 placeholder-gray-500 focus:ring-0"
    rows="4"
    placeholder="今日感じたこと、気づいたことを自由に書いてください..."
  ></textarea>
</div>
```

### 4. AI生成記事セクション
```html
<div class="mb-12">
  <!-- AIヘッダー -->
  <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
    <div class="flex items-center justify-between mb-2">
      <div class="flex items-center">
        <span class="text-blue-600 mr-2">🤖</span>
        <span class="font-medium text-blue-900">AI生成記事</span>
      </div>
      <div class="flex items-center space-x-2">
        <button class="text-blue-600 hover:text-blue-800 text-sm underline">編集</button>
        <button class="text-blue-600 hover:text-blue-800 text-sm underline">再生成</button>
      </div>
    </div>
    <p class="text-sm text-blue-800">学習済みパターンに基づいて最適化されています</p>
  </div>

  <!-- 記事コンテンツ -->
  <div class="prose max-w-none">
    <div class="space-y-6 text-gray-800 leading-relaxed">
      <p class="text-lg">
        <!-- 記事内容 -->
      </p>
    </div>
  </div>
</div>
```

### 5. フィードバックエリア
```html
<div class="mt-12 border-t border-gray-200 pt-8">
  <div class="bg-gray-50 rounded-lg p-6">
    <h3 class="font-medium text-gray-900 mb-4">この記事を評価</h3>
    <div class="space-y-4">
      <!-- 評価ボタン -->
      <div>
        <label class="block text-sm text-gray-700 mb-2">品質評価（1-5）</label>
        <div class="flex space-x-2">
          <button class="w-8 h-8 rounded-full border-2 border-gray-300 hover:border-blue-500 flex items-center justify-center text-sm font-medium transition-colors">1</button>
          <button class="w-8 h-8 rounded-full border-2 border-gray-300 hover:border-blue-500 flex items-center justify-center text-sm font-medium transition-colors">2</button>
          <button class="w-8 h-8 rounded-full border-2 border-gray-300 hover:border-blue-500 flex items-center justify-center text-sm font-medium transition-colors">3</button>
          <button class="w-8 h-8 rounded-full border-2 border-blue-500 bg-blue-500 text-white flex items-center justify-center text-sm font-medium">4</button>
          <button class="w-8 h-8 rounded-full border-2 border-gray-300 hover:border-blue-500 flex items-center justify-center text-sm font-medium transition-colors">5</button>
        </div>
      </div>
      
      <!-- コメント入力 -->
      <div>
        <label class="block text-sm text-gray-700 mb-2">改善点・良かった点</label>
        <textarea 
          class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          rows="3"
          placeholder="例: 体験描写がもう少し具体的だと良い、感情表現が自然で良かった等"
        ></textarea>
      </div>
      
      <div class="flex justify-end">
        <button class="bg-gray-800 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-gray-900 transition-colors">
          フィードバックを保存
        </button>
      </div>
    </div>
  </div>
</div>
```

### 6. フローティング学習情報
```html
<div class="fixed bottom-6 right-6 bg-white rounded-lg shadow-lg border border-gray-200 p-4 w-72">
  <div class="flex items-center justify-between mb-2">
    <h4 class="font-medium text-gray-900">学習状況</h4>
    <button class="text-gray-400 hover:text-gray-600">×</button>
  </div>
  <div class="space-y-2 text-sm">
    <div class="flex justify-between">
      <span class="text-gray-600">今月の記事数</span>
      <span class="font-medium">12</span>
    </div>
    <div class="flex justify-between">
      <span class="text-gray-600">平均品質スコア</span>
      <span class="font-medium text-green-600">4.3</span>
    </div>
    <div class="pt-2 border-t border-gray-100 text-xs text-gray-500">
      最近の改善: 体験描写が20%向上
    </div>
  </div>
</div>
```

## Tailwind ボタンシステム

### プライマリボタン
```html
<button class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
  ボタンテキスト
</button>
```

### セカンダリボタン
```html
<button class="bg-white hover:bg-gray-50 text-gray-700 border border-gray-300 px-4 py-2 rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
  ボタンテキスト
</button>
```

### ダークボタン
```html
<button class="bg-gray-800 hover:bg-gray-900 text-white px-4 py-2 rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
  ボタンテキスト
</button>
```

### 小さなボタン
```html
<button class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 text-sm rounded font-medium transition-colors">
  小ボタン
</button>
```

## Tailwind フォームシステム

### 基本入力フィールド
```html
<input 
  type="text" 
  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent placeholder-gray-400"
  placeholder="プレースホルダー"
/>
```

### テキストエリア
```html
<textarea 
  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent placeholder-gray-400 resize-none"
  rows="4"
  placeholder="プレースホルダー"
></textarea>
```

### セレクトボックス
```html
<select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
  <option>選択肢1</option>
  <option>選択肢2</option>
</select>
```

### ラベル
```html
<label class="block text-sm font-medium text-gray-700 mb-2">
  ラベルテキスト
</label>
```

## カードシステム

### 基本カード
```html
<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
  <h3 class="text-lg font-semibold text-gray-900 mb-4">カードタイトル</h3>
  <p class="text-gray-600">カードコンテンツ</p>
</div>
```

### ホバー効果付きカード
```html
<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
  <!-- カードコンテンツ -->
</div>
```

### 統計カード
```html
<div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
  <div class="flex items-center">
    <div class="flex-shrink-0">
      <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
        <span class="text-green-600 text-sm">📈</span>
      </div>
    </div>
    <div class="ml-4">
      <p class="text-sm font-medium text-gray-500">平均品質スコア</p>
      <p class="text-2xl font-semibold text-gray-900">4.2</p>
    </div>
  </div>
</div>
```

## 状態管理クラス

### ローディング状態
```html
<div class="opacity-50 pointer-events-none">
  <button class="bg-blue-500 text-white px-4 py-2 rounded-md cursor-wait">
    処理中...
  </button>
</div>
```

### エラー状態
```html
<div class="border-red-300 bg-red-50">
  <input class="border-red-300 focus:ring-red-500 focus:border-red-500" />
</div>
<p class="text-red-600 text-sm mt-1">エラーメッセージ</p>
```

### 成功状態
```html
<div class="border-green-300 bg-green-50">
  <input class="border-green-300 focus:ring-green-500 focus:border-green-500" />
</div>
<p class="text-green-600 text-sm mt-1">成功メッセージ</p>
```

## アニメーション・トランジション

### 基本トランジション
```html
<button class="bg-blue-500 hover:bg-blue-600 transition-colors duration-200">
  ボタン
</button>

<div class="transform hover:scale-105 transition-transform duration-300">
  ホバーで拡大
</div>
```

### フェードイン・アウト
```html
<div class="opacity-0 animate-fadeIn">
  フェードイン要素
</div>

<!-- カスタムアニメーション（tailwind.config.js） -->
animation: {
  'fadeIn': 'fadeIn 0.5s ease-in-out',
}
```

### スライドイン
```html
<div class="transform translate-x-full animate-slideIn">
  スライドイン要素
</div>
```

## レスポンシブ設計

### ブレークポイント
```html
<!-- モバイル → タブレット → デスクトップ -->
<div class="p-4 sm:p-6 lg:p-8">
  <h1 class="text-2xl sm:text-3xl lg:text-4xl">
    レスポンシブタイトル
  </h1>
</div>

<!-- グリッド -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
  <!-- アイテム -->
</div>

<!-- 表示・非表示 -->
<div class="hidden sm:block">タブレット以上で表示</div>
<div class="block sm:hidden">モバイルのみ表示</div>
```

## Tailwind設定ファイル

### tailwind.config.js
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      animation: {
        'fadeIn': 'fadeIn 0.5s ease-in-out',
        'slideIn': 'slideIn 0.3s ease-out',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideIn: {
          '0%': { transform: 'translateX(100%)' },
          '100%': { transform: 'translateX(0)' },
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
```

## 実装チェックリスト

### 基本コンポーネント（Tailwind実装）
- [ ] ヘッダー (`sticky top-0 z-10 bg-white/95 backdrop-blur-sm`)
- [ ] タイトル入力 (`text-4xl font-bold text-gray-900`)
- [ ] メタ情報 (`flex items-center space-x-4 text-sm`)
- [ ] 気づきメモ (`bg-gray-50 border-l-4 border-amber-400`)
- [ ] AIセクション (`bg-blue-50 border border-blue-200`)
- [ ] フィードバック (`bg-gray-50 rounded-lg p-6`)
- [ ] フローティング統計 (`fixed bottom-6 right-6`)

### レスポンシブ対応
- [ ] モバイル (`sm:` プレフィックス)
- [ ] タブレット (`md:` プレフィックス)
- [ ] デスクトップ (`lg:` プレフィックス)

### インタラクション
- [ ] ホバー効果 (`hover:` プレフィックス)
- [ ] フォーカス (`focus:ring-2 focus:ring-blue-500`)
- [ ] トランジション (`transition-colors duration-200`)
- [ ] アニメーション (`animate-` クラス)

### アクセシビリティ
- [ ] フォーカス可視化 (`focus:outline-none focus:ring-2`)
- [ ] カラーコントラスト (適切なグレー・ブルーの組み合わせ)
- [ ] キーボードナビゲーション
- [ ] スクリーンリーダー対応 (`sr-only` クラス活用)

### 状態管理
- [ ] ローディング (`opacity-50 pointer-events-none`)
- [ ] エラー (`border-red-300 bg-red-50`)
- [ ] 成功 (`border-green-300 bg-green-50`)
- [ ] 無効化 (`opacity-50 cursor-not-allowed`)

この仕様書により、開発者は一貫したTailwind CSSクラスを使用して、効率的にNotion風のUIを実装できます。