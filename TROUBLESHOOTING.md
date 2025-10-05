# トラブルシューティング

## フロントエンドとバックエンドの接続確認

### 1. バックエンドが起動しているか確認
```bash
curl http://localhost:8000/
# 結果: "Narou Search API - Running on Genie.jl" が表示されればOK
```

### 2. APIが正常に動作しているか確認
```bash
curl "http://localhost:8000/search?keyword=スライム&limit=5"
# JSON形式のデータが返ってくればOK
```

### 3. CORSヘッダーが設定されているか確認
```bash
curl -v "http://localhost:8000/search?limit=1" 2>&1 | grep -i "access-control"
# Access-Control-Allow-Origin: * が表示されればOK
```

### 4. ブラウザでテストページを開く
```
http://localhost:8080/test.html
```
「APIをテスト」ボタンをクリックして動作確認

### よくある問題

#### CORSエラー
**症状**: ブラウザのコンソールに「CORS policy」エラー

**原因**: バックエンドのCORSヘッダー設定が不足

**解決方法**: SearchController.jlでヘッダーが正しく設定されているか確認

#### 接続エラー
**症状**: 「Failed to fetch」エラー

**原因**: バックエンドが起動していない、または異なるポート

**解決方法**:
```bash
ps aux | grep julia  # バックエンドが起動しているか確認
ps aux | grep "python.*8080"  # フロントエンドが起動しているか確認
```

#### サーバー再起動
```bash
./STOP_SERVERS.sh
./START_SERVERS.sh
```

### デバッグ用コマンド

```bash
# バックエンドログ確認
tail -f /tmp/genie_server.log

# フロントエンドログ確認
tail -f /tmp/frontend_server.log

# 現在のサーバー状況
ps aux | grep -E "(julia|python.*8080)" | grep -v grep
```
