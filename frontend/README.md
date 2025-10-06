# フロントエンド（Vercel 配置）

## 目的：
 静的サイトとして検索フォーム・結果一覧を表示し、
 バックエンド（Genie.jl API）に fetch でリクエストを送信。

frontend/
├── index.html               # 🔹 検索ページのメインHTML（フォーム＋結果エリア）
│
├── css/
│   └── style.css            # ページデザイン（レスポンシブ・select付き）
│
├── js/
│   ├── app.js               # 検索処理、API呼び出し、結果描画、エラーハンドリング
│   ├── pagination.js        # ページネーション制御（1ページ10件）
│   └── utils.js             # 汎用関数（fetch共通処理・日付整形・URL生成）
│
├── img/
│   ├── logo.png             # サイトロゴ
│   └── icon_search.svg      # 検索アイコン等
│
├── vercel.json              # Vercel デプロイ設定（リダイレクト・CORS等）
├── README.md                # フロントエンド説明書
└── .env.example             # APIエンドポイント設定例 (例: API_BASE_URL=https://xxx.fly.dev)

## 主なファイル概要
ファイル
	機能概要
index.html
	検索フォーム（キーワード・年範囲・ソートselect）＋結果テーブル
style.css
	テーブル・ボタン・フォームのデザイン。モバイル対応。
app.js
	検索ボタンイベント、API fetch、結果描画、エラー表示
pagination.js
	ページ遷移、ボタン有効／無効制御、現在ページ管理
utils.js
	URLパラメータ生成、日付フォーマット、APIレスポンス処理


