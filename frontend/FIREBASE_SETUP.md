# Firebase認証設定ガイド

## Googleログインが動作しない場合の対処法

### 1. Firebase Consoleでの設定

1. **Firebase Consoleにアクセス**
   - https://console.firebase.google.com/
   - プロジェクト「magiri」を選択

2. **Googleログインを有効化**
   - 左メニュー「Authentication」をクリック
   - 「Sign-in method」タブを選択
   - 「Google」をクリック
   - 「有効にする」をONにする
   - プロジェクトのサポートメールを選択
   - 「保存」をクリック

3. **承認済みドメインの確認**
   - 「Settings」タブを選択
   - 「承認済みドメイン」セクションを確認
   - `localhost` が含まれているか確認
   - なければ「ドメインを追加」で `localhost` を追加

### 2. 現在の設定

**Firebase Config:**
- Project ID: `magiri`
- Auth Domain: `magiri.firebaseapp.com`

**有効化が必要なプロバイダ:**
- ✅ メール/パスワード
- ✅ Google

### 3. トラブルシューティング

#### エラー: "unauthorized-domain"
- Firebase Consoleで `localhost` が承認済みドメインに追加されているか確認

#### エラー: "popup-closed-by-user"
- ポップアップがブロックされている可能性
- ブラウザのポップアップブロッカーを無効化

#### Googleボタンをクリックしても反応しない
1. ブラウザのコンソールを開く（F12）
2. エラーメッセージを確認
3. Firebase Consoleでプロバイダが有効か確認

### 4. 代替方法：リダイレクトフローを使用

ポップアップがブロックされる場合は、リダイレクトフローに変更：

`frontend/js/auth.js` の `signInFlow` を以下のように変更：

```javascript
signInFlow: 'redirect',  // 'popup' から 'redirect' に変更
```

### 5. テスト手順

1. ページをリロード（Ctrl+R または Cmd+R）
2. 「Googleでログイン」ボタンをクリック
3. Googleアカウント選択画面が表示される
4. アカウントを選択してログイン

### 6. 確認コマンド

ブラウザのコンソール（F12）で以下を確認：

```javascript
// FirebaseUIがロードされているか確認
console.log(typeof firebaseui);  // 'object' と表示されるべき

// Firebase Authが初期化されているか確認
console.log(firebase.auth().currentUser);  // null または user object
```

## よくある質問

**Q: メールログインは動くがGoogleログインが動かない**
A: Firebase ConsoleでGoogleプロバイダを有効化してください

**Q: ポップアップが表示されない**
A: ブラウザのポップアップブロッカーを確認、またはリダイレクトフローに変更

**Q: 「このアプリは確認されていません」と表示される**
A: 開発中は「詳細」→「安全でないページに移動」で続行可能
