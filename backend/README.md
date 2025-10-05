# バックエンド（Fly.io / Render 配置）
## 目的
 小説家になろうAPIから作品データを取得・キャッシュ（SQLite保存）し、
 検索API（/search）を提供する。

backend/
├── app/
│   ├── controllers/
│   │   └── SearchController.jl    # 🔹 /search エンドポイント
│   │
│   ├── models/
│   │   └── Work.jl                # works モデル（検索・保存処理）
│   │
│   ├── views/                     # （APIのみのため空）
│   └── routes.jl                  # ルーティング設定 (/search)
│
├── bin/
│   └── fetch_data.jl              # 🔹 なろうAPI→SQLite キャッシュ更新スクリプト
│
├── config/
│   ├── database.yml               # SQLite設定 (db/production.sqlite3)
│   └── env.jl                     # 環境変数設定
│
├── db/
│   ├── schema.sql                 # works テーブル定義
│   ├── seeds.sql                  # 初期データ投入（任意）
│   └── production.sqlite3         # 実運用DB（キャッシュ格納）
│
├── test/
│   ├── test_search.jl             # /search API のテスト
│   └── test_models.jl             # モデルテスト（Work.jl）
│
├── Dockerfile                     # Fly.io / Render 用コンテナ設定
├── fly.toml                       # Fly.io デプロイ設定
├── render.yaml                    # Render デプロイ設定
├── Project.toml                   # Genie.jl 依存管理
├── Manifest.toml                  # 固定依存解決ファイル
└── README.md                      # バックエンド説明書

## 主なファイル概要
ファイル
	機能概要
    
SearchController.jl
	/search エンドポイント実装。パラメータ検証・SQL検索。

Work.jl
	works モデル（ncode, title, writer, year, general_firstup）定義。

fetch_data.jl
	なろうAPIから最大50件取得、フィールド制限、SQLite更新。3日キャッシュ＋週次更新。

database.yml
	SQLite接続設定。

routes.jl
	/search のルーティング登録。

test_search.jl
	APIの検索・ページネーション・ソートテスト。

Dockerfile
	Genie.jlアプリ用コンテナ。

fly.toml / render.yaml
	デプロイ環境設定。


