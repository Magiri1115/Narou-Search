FROM julia:1.10

WORKDIR /app

# システム依存関係
RUN apt-get update && apt-get install -y \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Juliaパッケージのインストール
COPY Project.toml Manifest.toml ./
RUN julia -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

# アプリケーションコードをコピー
COPY . .

# データベースディレクトリ作成
RUN mkdir -p /app/db

# ポート公開
EXPOSE 8000

# Genie.jlアプリ起動
CMD ["julia", "--project=.", "-e", "using Genie; Genie.loadapp(); up(8000, async=false)"]
