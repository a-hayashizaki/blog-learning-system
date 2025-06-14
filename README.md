# Blog Learning System

AIを活用したブログ記事学習システムです。記事の生成、分析、フィードバックの収集を行います。

## 🚀 セットアップ

### 必要な環境
- Ruby 3.4.4
- Node.js (LTS版)
- Docker & Docker Compose

### 開発環境の起動

```bash
# devcontainerを使用する場合（推奨）
code .
# VS CodeでdevcontainerとしてReopen

# 手動セットアップの場合
bundle install
rails db:create db:migrate db:seed
rails server
```

## 🔧 MCP (Model Context Protocol) 設定

このプロジェクトでは複数のMCPサーバーを使用して、ブラウザ自動化やデザインツール連携機能を提供しています。

### ローカル環境でのMCPサーバー起動

#### 1. Playwright MCPサーバーのインストール

```bash
# グローバルインストール（推奨）
npm install -g @mcp-suite/mcp-server-playwright

# または、npxを使用してインストール不要で実行
npx @mcp-suite/mcp-server-playwright --host 0.0.0.0 --port 9222
```

#### 2. Figma Developer MCPサーバーのインストール

```bash
# グローバルインストール
npm install -g figma-developer-mcp@latest

# 起動（別のポートで）
figma-developer-mcp --port 9223
```

#### 3. サーバーの起動

```bash
# Playwright MCP（ブラウザ自動化）
mcp-server-playwright --host 0.0.0.0 --port 9222

# Figma Developer MCP（デザインツール連携）
figma-developer-mcp --port 9223

# volta環境等でのコマンド実行
# （このプロジェクトではvoltaが使用されているため、上記コマンドが有効）
```

### Claude Code での MCP 設定

1. Claude Code で複数のMCPサーバーを追加：

[公式の説明](https://docs.anthropic.com/ja/docs/claude-code/tutorials#mcp%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%82%B9%E3%82%B3%E3%83%BC%E3%83%97%E3%82%92%E7%90%86%E8%A7%A3%E3%81%99%E3%82%8B)
```bash
# Playwright MCP（ブラウザ自動化）
claude mcp add --transport sse playwright http://host.docker.internal:9222/sse -s project

# Figma Developer MCP（デザインツール連携）
claude mcp add --transport sse figma http://host.docker.internal:9223/sse -s project
```


2. またはマニュアル設定（`.mcp.json`）：

```json
{
  "mcpServers": {
    "playwright": {
      "type": "sse",
      "url": "http://host.docker.internal:9222/sse"
    },
    "figma": {
      "type": "sse",
      "url": "http://host.docker.internal:9223/sse"
    }
  }
}
```

### MCP機能のテスト

#### Playwright MCP
1. Claude Desktop を開く
2. 「Playwright MCP でグーグルを開いて」と入力
3. ブラウザが自動で開かれることを確認

#### Figma Developer MCP
1. Claude Desktop を開く
2. 「Figmaのデザインファイルを確認して」と入力
3. Figmaとの連携機能が動作することを確認

## 📱 機能

- **記事生成**: AIを使用した記事の自動生成
- **学習分析**: 記事内容の分析と学習ポイントの抽出
- **フィードバック**: ユーザーからのフィードバック収集
- **ブラウザ自動化**: Playwright MCPによるWeb操作
- **デザイン連携**: Figma Developer MCPによるデザインツール連携

## 🗄️ データベース

```bash
# マイグレーション実行
rails db:migrate

# シードデータの投入
rails db:seed

# リセット（開発環境のみ）
rails db:reset
```

## 🧪 テスト

```bash
# 全テスト実行
rails test

# システムテスト実行
rails test:system
```

## 🚢 デプロイ

```bash
# Kamalを使用したデプロイ
kamal deploy
```

## 📚 主要なGem

- **Rails 8.0** - Webアプリケーションフレームワーク
- **SQLite** - データベース
- **Tailwind CSS** - スタイリング
- **Stimulus** - JavaScript フレームワーク
- **Kamal** - デプロイツール
