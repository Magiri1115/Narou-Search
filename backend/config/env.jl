"""
環境変数設定モジュール
"""
module EnvConfig

export get_env, get_db_path, get_api_base_url, is_production

"""
環境変数を取得（デフォルト値付き）
"""
function get_env(key::String, default::String="")::String
    return get(ENV, key, default)
end

"""
データベースパスを取得
"""
function get_db_path()::String
    return get_env("DB_PATH", joinpath(@__DIR__, "..", "db", "production.sqlite3"))
end

"""
APIベースURLを取得
"""
function get_api_base_url()::String
    return get_env("API_BASE_URL", "http://localhost:8000")
end

"""
本番環境かどうかを判定
"""
function is_production()::Bool
    return lowercase(get_env("ENV", "development")) == "production"
end

end # module
