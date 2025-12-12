# Narou Search

なろう小説検索システム - Julia/Genie.jlベースのWebアプリケーション

## 概要

このプロジェクトは、小説家になろうの作品を検索・閲覧するためのWebアプリケーションです。

- **バックエンド**: Julia + Genie.jl + SQLite
- **フロントエンド**: HTML + CSS + JavaScript (Vanilla)
- **認証**: JWT (JSON Web Token)

## 機能

- 作品検索（タイトル、作者名、年代）
- 統計情報の表示
- ランダム作品の取得
- 作者一覧の表示
- ユーザー認証（サインアップ/ログイン）
- レスポンシブデザイン

## システム要件

- **Julia**: 1.6以上
- **Python**: 3.6以上（フロントエンド配信用）
- **SQLite3**: データベース用
- **Bash**: 起動スクリプト用

### macOSの場合

```bash
brew install julia
brew install python3
```

### Linuxの場合

```bash
apt-get install julia python3 sqlite3
```

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd "julia 2"
```

### 2. Julia依存パッケージのインストール

```bash
cd backend
julia --project=. -e 'using Pkg; Pkg.instantiate()'
cd ..
```

### 3. データベースの準備

データベースファイルを配置してください。初回起動時に自動的にテーブルが作成されます。

## 起動方法

### 簡単な起動（推奨）

```bash
bash start.sh
```

このスクリプトは以下を自動的に行います：
- 既存のサーバープロセスの停止（ポート5173, 8000）
- バックエンドサーバーの起動（Julia/Genie on port 8000）
- フロントエンドサーバーの起動（HTTP server on port 5173）

### 手動起動

#### バックエンドのみ起動

```bash
cd backend
julia --project=. server.jl
```

#### フロントエンドのみ起動

```bash
cd frontend
python3 -m http.server 5173
```

## アクセス方法

サーバー起動後、以下のURLにアクセスできます：

- **フロントエンド**: http://localhost:5173
- **バックエンドAPI**: http://localhost:8000
- **APIドキュメント**: http://localhost:8000（ルートページにAPI仕様が表示されます）

## サーバーの停止

`start.sh`で起動した場合は、`Ctrl+C`で両方のサーバーを停止できます。

手動で停止する場合：

```bash
lsof -ti:5173,8000 | xargs kill -9
```

## API エンドポイント

### 検索

```
GET /search?keyword=異世界&year_from=2010&limit=20
```

パラメータ:
- `keyword`: タイトル・作者名（部分一致）
- `year_from`, `year_to`: 年代範囲
- `page`, `limit`: ページネーション

### 統計情報

```
GET /api/stats
```

### 作品詳細

```
GET /api/works/:ncode
```

### ランダム作品

```
GET /api/random?count=10
```

### 作者一覧

```
GET /api/authors?limit=20&page=1
```

### 年リスト

```
GET /api/years
```

### 認証

```
POST /api/auth/signup    - ユーザー登録
POST /api/auth/login     - ログイン
POST /api/auth/logout    - ログアウト
POST /api/auth/refresh   - トークンリフレッシュ
GET  /api/auth/me        - ユーザー情報取得
```

## プロジェクト構造

```
julia 2/
├── backend/
│   ├── app/
│   │   ├── controllers/     # コントローラー
│   │   ├── models/          # データモデル
│   │   ├── middleware/      # ミドルウェア
│   │   └── utils/           # ユーティリティ
│   ├── config/              # 設定ファイル
│   ├── Project.toml         # Julia依存関係
│   └── server.jl            # サーバーエントリーポイント
├── frontend/
│   ├── css/                 # スタイルシート
│   ├── js/                  # JavaScript
│   ├── index.html           # メインページ
│   └── package.json
├── start.sh                 # 起動スクリプト
├── requirements.txt         # Python依存関係（空）
├── Project.toml             # プロジェクトメタデータ
└── README.md               # このファイル
```

## 開発

### Julia依存パッケージ

- **Genie**: Webフレームワーク
- **SQLite**: データベース
- **JSON3**: JSON処理
- **HTTP**: HTTPクライアント
- **YAML**: YAML設定ファイル処理
- **DBInterface**: データベースインターフェース
- **MbedTLS_jll**: TLS/SSL暗号化
- 標準ライブラリ: Dates, SHA, Test

### コーディング規約

- Julia: 標準的なJuliaスタイルガイドに従う
- JavaScript: ES6+構文を使用
- CSS: BEM命名規則を推奨

## トラブルシューティング

### ポートが既に使用されている

```bash
# 使用中のプロセスを確認
lsof -i:5173
lsof -i:8000

# 強制停止
lsof -ti:5173,8000 | xargs kill -9
```

### Julia依存パッケージのエラー

```bash
cd backend
julia --project=. -e 'using Pkg; Pkg.resolve(); Pkg.instantiate()'
```

### データベース接続エラー

- `backend/config/env.jl`でデータベースパスを確認
- データベースファイルの読み書き権限を確認

## ライセンス

このプロジェクトは個人利用を目的としています。

## 作者

kimura2003

## 更新履歴

- v1.0.0 (2024) - 初回リリース
  - 基本的な検索機能
  - JWT認証システム
  - レスポンシブUI
