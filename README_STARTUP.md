# なろう検索エンジン - 起動方法

## 🚀 サーバー起動

```bash
cd /Users/kimura2003/Downloads/julia/Narou-Search
./START_SERVERS.sh
```

起動後、ブラウザで以下にアクセス:
- **フロントエンド**: http://localhost:8080
- **バックエンドAPI**: http://localhost:8000

## ⏹ サーバー停止

```bash
./STOP_SERVERS.sh
```

## 📝 手動起動コマンド

### バックエンド (Julia/Genie.jl)
```bash
cd /Users/kimura2003/Downloads/julia/Narou-Search/backend
julia --project=. server.jl
```

### フロントエンド (静的ファイルサーバー)
```bash
cd /Users/kimura2003/Downloads/julia/Narou-Search/frontend
python3 -m http.server 8080
```

## 🔧 データ更新

なろうAPIから最新データを取得:
```bash
cd /Users/kimura2003/Downloads/julia/Narou-Search/backend
julia --project=. bin/fetch_data.jl
```

## 📊 現在のデータ

- データベース: `backend/db/production.sqlite3`
- 保存件数: 50件の人気作品
- 主な作品: 「転生したらスライムだった件」「無職転生」「Re:ゼロ」など

## 🧪 テスト実行

### モデルテスト
```bash
cd /Users/kimura2003/Downloads/julia/Narou-Search/backend
julia --project=. test/test_models.jl
```

### 統合テスト
```bash
julia --project=. test/test_search.jl
```

## 🌐 API仕様

### 検索エンドポイント
```
GET http://localhost:8000/search
```

### パラメータ
- `keyword`: キーワード検索（タイトル・作者名）
- `year_from`: 開始年
- `year_to`: 終了年
- `sort_by`: ソート列 (`general_firstup`, `title`, `year`)
- `order`: ソート順 (`ASC`, `DESC`)
- `page`: ページ番号
- `limit`: 1ページあたりの件数

### レスポンス例
```json
{
  "total": 50,
  "page": 1,
  "per_page": 10,
  "results": [
    {
      "ncode": "N6316BN",
      "title": "転生したらスライムだった件",
      "writer": "伏瀬",
      "year": 2013,
      "general_firstup": "2013-02-20T00:36:17"
    }
  ]
}
```
