# バックエンド（Fly.io / Render 配置）

backend/
├── app/
│   ├── controllers/
│   │   └── SearchController.jl   # /search エンドポイント
│   ├── models/
│   │   └── Work.jl               # works モデル
│   ├── views/                    # (APIなので基本不要)
│   └── routes.jl                 # ルーティング設定
│
├── bin/
│   └── fetch_data.jl             # 小説家になろうAPIから作品データを取得しSQLiteに保存
│
├── config/
│   ├── database.yml              # SQLite設定 (db/production.sqlite3 など)
│   └── env.jl                    # 環境変数
│
├── db/
│   ├── schema.sql                # works のテーブル定義
│   ├── seeds.sql                 # 初期データ投入（任意）
│   └── production.sqlite3        # デプロイ先で生成されるDBファイル
│
├── test/
│   ├── test_search.jl            # 検索APIのテスト
│   └── test_models.jl            # モデルのテスト
│
├── Dockerfile                    # Fly.io / Render 用のコンテナ設定
├── fly.toml                      # Fly.io デプロイ用
├── render.yaml                   # Render デプロイ用
├── Project.toml
├── Manifest.toml
└── README.md
