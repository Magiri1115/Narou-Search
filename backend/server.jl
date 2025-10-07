"""
Genie.jl API Server
"""

using Genie, Genie.Router, Genie.Renderer.Json, Genie.Renderer.Html
using SQLite

# Load models
include("app/models/Work.jl")
using .WorkModel

# Load config
include("config/env.jl")
using .EnvConfig

# Load controllers
include("app/controllers/SearchController.jl")
using .SearchController

include("app/controllers/StatsController.jl")
using .StatsController

include("app/controllers/WorkController.jl")
using .WorkController

include("app/controllers/AuthorController.jl")
using .AuthorController

include("app/controllers/RandomController.jl")
using .RandomController

include("app/controllers/YearsController.jl")
using .YearsController

# Routes
route("/") do
    html_content = """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Narou Search API</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }

            body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                overflow-x: hidden;
                perspective: 1000px;
            }

            /* Door Animation */
            .door-container {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                z-index: 9999;
                pointer-events: none;
            }

            .door {
                position: absolute;
                top: 0;
                width: 50%;
                height: 100%;
                background: linear-gradient(to bottom, #1a1a2e 0%, #16213e 100%);
                transition: transform 1.5s cubic-bezier(0.68, -0.55, 0.265, 1.55);
                box-shadow: inset 0 0 100px rgba(0,0,0,0.5);
            }

            .door-left {
                left: 0;
                transform-origin: left;
                border-right: 2px solid #0f3460;
            }

            .door-right {
                right: 0;
                transform-origin: right;
                border-left: 2px solid #0f3460;
            }

            .door.open-left { transform: perspective(1200px) rotateY(-90deg); }
            .door.open-right { transform: perspective(1200px) rotateY(90deg); }

            .door-handle {
                position: absolute;
                top: 50%;
                width: 60px;
                height: 20px;
                background: linear-gradient(to bottom, #ffd700, #ffed4e);
                border-radius: 10px;
                transform: translateY(-50%);
                box-shadow: 0 4px 10px rgba(255, 215, 0, 0.4);
            }

            .door-left .door-handle { right: 30px; }
            .door-right .door-handle { left: 30px; }

            /* Main Content */
            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 2rem;
                opacity: 0;
                animation: fadeIn 1s ease-in 1.2s forwards;
            }

            @keyframes fadeIn {
                to { opacity: 1; }
            }

            header {
                text-align: center;
                color: white;
                padding: 3rem 2rem;
                margin-bottom: 3rem;
                position: relative;
            }

            h1 {
                font-size: 3.5rem;
                font-weight: 800;
                margin-bottom: 1rem;
                text-shadow: 0 4px 20px rgba(0,0,0,0.3);
                letter-spacing: -1px;
            }

            .lead {
                font-size: 1.2rem;
                opacity: 0.95;
                font-weight: 300;
            }

            .grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .card {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-radius: 16px;
                padding: 2rem;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                transition: all 0.3s ease;
                border: 1px solid rgba(255,255,255,0.2);
            }

            .card:hover {
                transform: translateY(-8px) scale(1.02);
                box-shadow: 0 30px 80px rgba(0,0,0,0.4);
            }

            .card-header {
                display: flex;
                align-items: center;
                gap: 1rem;
                margin-bottom: 1rem;
            }

            .method-badge {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 0.4rem 0.8rem;
                border-radius: 8px;
                font-size: 0.75rem;
                font-weight: 700;
                letter-spacing: 0.5px;
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            }

            .path {
                font-family: 'Monaco', 'Courier New', monospace;
                font-weight: 600;
                font-size: 1.1rem;
                color: #1a1a2e;
                flex: 1;
            }

            .description {
                color: #555;
                margin-bottom: 1rem;
                font-size: 0.95rem;
            }

            .params {
                background: #f8f9fa;
                padding: 1rem;
                border-radius: 8px;
                margin-bottom: 1rem;
                border-left: 3px solid #667eea;
            }

            .param-item {
                color: #666;
                font-size: 0.9rem;
                margin: 0.5rem 0;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            code {
                background: linear-gradient(135deg, #667eea20, #764ba220);
                padding: 0.3rem 0.6rem;
                border-radius: 6px;
                font-size: 0.85rem;
                font-weight: 600;
                color: #667eea;
                border: 1px solid #667eea40;
            }

            .try-btn {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                padding: 0.8rem 1.5rem;
                border-radius: 10px;
                cursor: pointer;
                font-weight: 600;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
                width: 100%;
                font-size: 0.95rem;
            }

            .try-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
            }

            .try-btn:active {
                transform: translateY(0);
            }

            .footer-card {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-radius: 16px;
                padding: 2rem;
                text-align: center;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                border: 1px solid rgba(255,255,255,0.2);
            }

            .footer-card h2 {
                color: #1a1a2e;
                margin-bottom: 1rem;
                font-size: 1.5rem;
            }

            .footer-link {
                display: inline-block;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 1rem 2rem;
                border-radius: 10px;
                text-decoration: none;
                font-weight: 600;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            }

            .footer-link:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
            }

            @media (max-width: 768px) {
                h1 { font-size: 2.5rem; }
                .grid { grid-template-columns: 1fr; }
            }
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
                    <button class="try-btn" onclick="window.open('/search?keyword=異世界&limit=5', '_blank')">試してみる →</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/api/stats</span>
                    </div>
                    <div class="description">統計情報（総作品数、年別作品数、人気作者）</div>
                    <button class="try-btn" onclick="window.open('/api/stats', '_blank')">試してみる →</button>
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
                    <button class="try-btn" onclick="window.open('/api/works/N4395IL', '_blank')">試してみる →</button>
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
                    <button class="try-btn" onclick="window.open('/api/authors?limit=10', '_blank')">試してみる →</button>
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
                    <button class="try-btn" onclick="window.open('/api/random?count=5', '_blank')">試してみる →</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="method-badge">GET</span>
                        <span class="path">/api/years</span>
                    </div>
                    <div class="description">利用可能な年のリスト</div>
                    <button class="try-btn" onclick="window.open('/api/years', '_blank')">試してみる →</button>
                </div>
            </div>

            <div class="footer-card">
                <h2>🖥️ フロントエンドUI</h2>
                <p style="color: #666; margin-bottom: 1.5rem;">ブラウザUIで快適に検索</p>
                <a href="http://localhost:5173" target="_blank" class="footer-link">フロントエンドを開く →</a>
            </div>
        </div>

        <script>
            // Door opening animation on page load
            window.addEventListener('load', () => {
                setTimeout(() => {
                    document.getElementById('doorLeft').classList.add('open-left');
                    document.getElementById('doorRight').classList.add('open-right');
                }, 300);
            });
        </script>
    </body>
    </html>
    """
    return html(html_content)
end

# Search endpoint
route("/search", SearchController.search, method = GET)
route("/search", SearchController.search, method = POST)
route("/search", SearchController.search, method = OPTIONS)

# Stats endpoint
route("/api/stats", StatsController.stats, method = GET)
route("/api/stats", StatsController.stats, method = OPTIONS)

# Work details endpoint
route("/api/works/:ncode", WorkController.get_work, method = GET)
route("/api/works/:ncode", WorkController.get_work, method = OPTIONS)

# Authors endpoint
route("/api/authors", AuthorController.list_authors, method = GET)
route("/api/authors", AuthorController.list_authors, method = OPTIONS)

# Random works endpoint
route("/api/random", RandomController.random_works, method = GET)
route("/api/random", RandomController.random_works, method = OPTIONS)

# Years endpoint
route("/api/years", YearsController.list_years, method = GET)
route("/api/years", YearsController.list_years, method = OPTIONS)

# Start server
up(8000, async = false)
