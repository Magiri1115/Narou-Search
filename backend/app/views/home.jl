"""
Home page view template
"""

function render_home_page()
    css = read(joinpath(@__DIR__, "styles.css"), String)
    js = read(joinpath(@__DIR__, "app.js"), String)

    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Narou Search API</title>
        <style>
        $css
        </style>
    </head>
    <body>
        <!-- Door Animation -->
        <div class="door-container">
            <div class="door door-left" id="doorLeft">
                <div class="door-handle"></div>
            </div>
            <div class="door door-right" id="doorRight">
                <div class="door-handle"></div>
            </div>
        </div>

        <div class="container">
            <header>
                <h1>🔍 Narou Search API</h1>
                <p class="lead">なろう小説検索API - Powered by Genie.jl</p>
            </header>

            <!-- System Status Panel -->
            <div class="status-panel">
                <div class="status-header">
                    <span class="status-indicator"></span>
                    SYSTEM STATUS
                </div>
                <div class="status-grid">
                    <div class="status-item">
                        <span class="status-label">Server</span>
                        <span class="status-value" id="server-status">ONLINE</span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">Endpoints</span>
                        <span class="status-value">6 ACTIVE</span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">Framework</span>
                        <span class="status-value">Genie.jl</span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">Database</span>
                        <span class="status-value">SQLite</span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">Port</span>
                        <span class="status-value">:8000</span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">Uptime</span>
                        <span class="status-value" id="uptime">00:00:00</span>
                    </div>
                </div>
                <div class="log-console" id="console">
                    <div class="log-line log-success"><span class="log-time">[00:00:00]</span> ✓ Server initialized on port 8000</div>
                    <div class="log-line log-info"><span class="log-time">[00:00:01]</span> → Loading controllers...</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:02]</span> ✓ SearchController loaded</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:02]</span> ✓ StatsController loaded</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:02]</span> ✓ WorkController loaded</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:03]</span> ✓ AuthorController loaded</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:03]</span> ✓ RandomController loaded</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:03]</span> ✓ YearsController loaded</div>
                    <div class="log-line log-info"><span class="log-time">[00:00:04]</span> → Establishing database connection...</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:04]</span> ✓ Database connected: SQLite</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:05]</span> ✓ All routes registered successfully</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:05]</span> ✓ CORS enabled for all origins</div>
                    <div class="log-line log-success"><span class="log-time">[00:00:06]</span> ✓ System ready - Listening on 127.0.0.1:8000</div>
                </div>
            </div>

            <div class="grid">
                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/search</span>
                    </div>
                    <div class="description">作品を検索します</div>
                    <div class="params">
                        <div class="param-item">📝 <code>keyword</code> - タイトル・作者名</div>
                        <div class="param-item">📅 <code>year_from</code> / <code>year_to</code> - 年範囲</div>
                        <div class="param-item">📄 <code>page</code>, <code>limit</code> - ページネーション</div>
                    </div>
                    <button class="try-btn" onclick="testAPI('/search?keyword=異世界&limit=5')">試してみる →</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/api/stats</span>
                    </div>
                    <div class="description">統計情報（総作品数、年別作品数、人気作者）</div>
                    <button class="try-btn" onclick="testAPI('/api/stats')">試してみる →</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/api/works/:ncode</span>
                    </div>
                    <div class="description">特定の作品詳細を取得</div>
                    <div class="params">
                        <div class="param-item">例: <code>/api/works/N4395IL</code></div>
                    </div>
                    <button class="try-btn" onclick="testAPI('/api/works/N4395IL')">試してみる →</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/api/authors</span>
                    </div>
                    <div class="description">作者一覧を取得</div>
                    <div class="params">
                        <div class="param-item">📄 <code>limit</code>, <code>page</code> - ページネーション</div>
                        <div class="param-item">🔍 <code>search</code> - 作者名検索</div>
                    </div>
                    <button class="try-btn" onclick="testAPI('/api/authors?limit=10')">試してみる →</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/api/random</span>
                    </div>
                    <div class="description">ランダムな作品を取得</div>
                    <div class="params">
                        <div class="param-item">🎲 <code>count</code> - 取得件数（1-50、デフォルト: 10）</div>
                    </div>
                    <button class="try-btn" onclick="testAPI('/api/random?count=5')">試してみる →</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/api/years</span>
                    </div>
                    <div class="description">利用可能な年のリスト</div>
                    <button class="try-btn" onclick="testAPI('/api/years')">試してみる →</button>
                </div>
            </div>

            <div class="footer-card">
                <h2>🖥️ フロントエンドUI</h2>
                <p style="color: #666; margin-bottom: 1.5rem;">ブラウザUIで快適に検索</p>
                <a href="http://localhost:5173" target="_blank" class="footer-link">フロントエンドを開く →</a>
            </div>
        </div>

        <!-- API Test Modal -->
        <div id="apiModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <span class="modal-title">API RESPONSE</span>
                    <button class="modal-close" onclick="closeModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="response-header">
                        <span id="responseStatus"></span>
                        <span id="responseTime"></span>
                    </div>
                    <pre id="responseBody"></pre>
                </div>
            </div>
        </div>

        <script>
        $js
        </script>
    </body>
    </html>
    """
end
