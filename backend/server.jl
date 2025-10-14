"""
Genie.jl API Server
"""

using Genie, Genie.Router, Genie.Renderer.Json, Genie.Renderer.Html
using SQLite

# Load models
include("app/models/Work.jl")
using .WorkModel

include("app/models/User.jl")
using .UserModel

# Load config
include("config/env.jl")
using .EnvConfig

# Initialize database tables
db = get_db()
UserModel.create_tables(db)

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

include("app/controllers/AuthController.jl")
using .AuthController

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
                font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Courier New', monospace;
                background: #0a0a0a;
                min-height: 100vh;
                overflow-x: hidden;
                perspective: 1000px;
                position: relative;
            }

            /* Animated Background Grid */
            body::before {
                content: '';
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background:
                    linear-gradient(90deg, rgba(0, 255, 255, 0.03) 1px, transparent 1px),
                    linear-gradient(rgba(0, 255, 255, 0.03) 1px, transparent 1px);
                background-size: 50px 50px;
                animation: gridMove 20s linear infinite;
                pointer-events: none;
                z-index: 0;
            }

            @keyframes gridMove {
                0% { transform: translate(0, 0); }
                100% { transform: translate(50px, 50px); }
            }

            /* Glowing particles */
            body::after {
                content: '';
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: radial-gradient(circle at 20% 50%, rgba(0, 255, 255, 0.1) 0%, transparent 50%),
                            radial-gradient(circle at 80% 80%, rgba(255, 0, 255, 0.1) 0%, transparent 50%);
                animation: pulse 4s ease-in-out infinite;
                pointer-events: none;
                z-index: 0;
            }

            @keyframes pulse {
                0%, 100% { opacity: 0.5; }
                50% { opacity: 1; }
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
                background: linear-gradient(to bottom, #000000 0%, #0a0a0a 100%);
                transition: transform 1.8s cubic-bezier(0.87, 0, 0.13, 1);
                box-shadow: inset 0 0 200px rgba(0, 255, 255, 0.1);
                border: 1px solid rgba(0, 255, 255, 0.2);
            }

            .door-left {
                left: 0;
                transform-origin: left;
                border-right: 2px solid #00ffff;
                box-shadow: 0 0 30px rgba(0, 255, 255, 0.5);
            }

            .door-right {
                right: 0;
                transform-origin: right;
                border-left: 2px solid #00ffff;
                box-shadow: 0 0 30px rgba(0, 255, 255, 0.5);
            }

            .door.open-left { transform: perspective(1500px) rotateY(-110deg); }
            .door.open-right { transform: perspective(1500px) rotateY(110deg); }

            .door-handle {
                position: absolute;
                top: 50%;
                width: 80px;
                height: 8px;
                background: linear-gradient(90deg, #00ffff, #ff00ff);
                transform: translateY(-50%);
                box-shadow: 0 0 20px rgba(0, 255, 255, 0.8), 0 0 40px rgba(255, 0, 255, 0.5);
                animation: handleGlow 2s ease-in-out infinite;
            }

            @keyframes handleGlow {
                0%, 100% { box-shadow: 0 0 20px rgba(0, 255, 255, 0.8), 0 0 40px rgba(255, 0, 255, 0.5); }
                50% { box-shadow: 0 0 30px rgba(0, 255, 255, 1), 0 0 60px rgba(255, 0, 255, 0.8); }
            }

            .door-left .door-handle { right: 40px; }
            .door-right .door-handle { left: 40px; }

            /* Main Content */
            .container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 2rem;
                opacity: 0;
                animation: fadeIn 1.5s ease-out 1.5s forwards;
                position: relative;
                z-index: 1;
            }

            @keyframes fadeIn {
                to { opacity: 1; }
            }

            header {
                text-align: center;
                color: #00ffff;
                padding: 4rem 2rem;
                margin-bottom: 4rem;
                position: relative;
            }

            h1 {
                font-size: 4.5rem;
                font-weight: 900;
                margin-bottom: 1rem;
                background: linear-gradient(135deg, #00ffff 0%, #ff00ff 50%, #00ffff 100%);
                background-size: 200% auto;
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
                animation: gradientShift 3s ease infinite;
                text-shadow: 0 0 40px rgba(0, 255, 255, 0.5);
                letter-spacing: -2px;
                text-transform: uppercase;
            }

            @keyframes gradientShift {
                0%, 100% { background-position: 0% 50%; }
                50% { background-position: 100% 50%; }
            }

            .lead {
                font-size: 1rem;
                color: #888;
                font-weight: 400;
                letter-spacing: 3px;
                text-transform: uppercase;
            }

            .grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .card {
                background: rgba(10, 10, 10, 0.6);
                backdrop-filter: blur(20px);
                border-radius: 2px;
                padding: 2rem;
                box-shadow: 0 0 1px rgba(0, 255, 255, 0.5),
                            0 0 20px rgba(0, 255, 255, 0.1),
                            inset 0 0 60px rgba(0, 255, 255, 0.05);
                transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
                border: 1px solid rgba(0, 255, 255, 0.2);
                position: relative;
                overflow: hidden;
            }

            .card::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: linear-gradient(45deg, transparent, rgba(0, 255, 255, 0.05), transparent);
                transform: rotate(45deg);
                transition: all 0.6s;
            }

            .card:hover::before {
                left: 100%;
            }

            .card:hover {
                transform: translateY(-10px);
                box-shadow: 0 0 2px rgba(0, 255, 255, 0.8),
                            0 0 40px rgba(0, 255, 255, 0.3),
                            0 0 80px rgba(255, 0, 255, 0.2),
                            inset 0 0 80px rgba(0, 255, 255, 0.1);
                border-color: rgba(0, 255, 255, 0.6);
            }

            .card-header {
                display: flex;
                align-items: center;
                gap: 1rem;
                margin-bottom: 1rem;
            }

            .method-badge {
                background: linear-gradient(135deg, #00ffff 0%, #ff00ff 100%);
                color: #000;
                padding: 0.4rem 1rem;
                border-radius: 0;
                font-size: 0.7rem;
                font-weight: 900;
                letter-spacing: 2px;
                box-shadow: 0 0 20px rgba(0, 255, 255, 0.5);
                text-transform: uppercase;
                border: 1px solid rgba(0, 255, 255, 0.5);
            }

            .path {
                font-family: 'SF Mono', 'Monaco', monospace;
                font-weight: 700;
                font-size: 1.1rem;
                color: #00ffff;
                flex: 1;
                text-shadow: 0 0 10px rgba(0, 255, 255, 0.5);
            }

            .description {
                color: #888;
                margin-bottom: 1rem;
                font-size: 0.9rem;
                letter-spacing: 0.5px;
            }

            .params {
                background: rgba(0, 255, 255, 0.03);
                padding: 1rem;
                border-radius: 0;
                margin-bottom: 1rem;
                border-left: 2px solid #00ffff;
                border-right: 2px solid rgba(255, 0, 255, 0.3);
            }

            .param-item {
                color: #aaa;
                font-size: 0.85rem;
                margin: 0.5rem 0;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            code {
                background: rgba(0, 255, 255, 0.1);
                padding: 0.3rem 0.6rem;
                border-radius: 0;
                font-size: 0.8rem;
                font-weight: 700;
                color: #00ffff;
                border: 1px solid rgba(0, 255, 255, 0.3);
                box-shadow: 0 0 10px rgba(0, 255, 255, 0.2);
            }

            .try-btn {
                background: transparent;
                color: #00ffff;
                border: 2px solid #00ffff;
                padding: 1rem 2rem;
                border-radius: 0;
                cursor: pointer;
                font-weight: 900;
                transition: all 0.4s ease;
                box-shadow: 0 0 20px rgba(0, 255, 255, 0.3), inset 0 0 20px rgba(0, 255, 255, 0.1);
                width: 100%;
                font-size: 0.9rem;
                letter-spacing: 2px;
                text-transform: uppercase;
                font-family: 'SF Mono', monospace;
                position: relative;
                overflow: hidden;
            }

            .try-btn::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(0, 255, 255, 0.3), transparent);
                transition: left 0.5s;
            }

            .try-btn:hover::before {
                left: 100%;
            }

            .try-btn:hover {
                background: rgba(0, 255, 255, 0.1);
                box-shadow: 0 0 30px rgba(0, 255, 255, 0.6),
                            0 0 60px rgba(255, 0, 255, 0.3),
                            inset 0 0 30px rgba(0, 255, 255, 0.2);
                border-color: #ff00ff;
                color: #ff00ff;
            }

            .try-btn:active {
                transform: scale(0.98);
            }

            .footer-card {
                background: rgba(10, 10, 10, 0.6);
                backdrop-filter: blur(20px);
                border-radius: 0;
                padding: 3rem;
                text-align: center;
                box-shadow: 0 0 1px rgba(255, 0, 255, 0.5),
                            0 0 40px rgba(255, 0, 255, 0.2),
                            inset 0 0 60px rgba(255, 0, 255, 0.05);
                border: 1px solid rgba(255, 0, 255, 0.3);
            }

            .footer-card h2 {
                color: #ff00ff;
                margin-bottom: 1rem;
                font-size: 2rem;
                font-weight: 900;
                text-transform: uppercase;
                letter-spacing: 3px;
                text-shadow: 0 0 20px rgba(255, 0, 255, 0.5);
            }

            .footer-link {
                display: inline-block;
                background: transparent;
                color: #ff00ff;
                padding: 1rem 3rem;
                border-radius: 0;
                text-decoration: none;
                font-weight: 900;
                transition: all 0.4s ease;
                box-shadow: 0 0 20px rgba(255, 0, 255, 0.3);
                border: 2px solid #ff00ff;
                letter-spacing: 2px;
                text-transform: uppercase;
                font-size: 0.9rem;
            }

            .footer-link:hover {
                background: rgba(255, 0, 255, 0.1);
                box-shadow: 0 0 40px rgba(255, 0, 255, 0.8), 0 0 80px rgba(0, 255, 255, 0.4);
                border-color: #00ffff;
                color: #00ffff;
            }

            /* System Status Panel */
            .status-panel {
                background: rgba(10, 10, 10, 0.8);
                border: 1px solid rgba(0, 255, 255, 0.3);
                padding: 1.5rem;
                margin-bottom: 3rem;
                font-family: 'SF Mono', monospace;
                box-shadow: 0 0 30px rgba(0, 255, 255, 0.2), inset 0 0 30px rgba(0, 255, 255, 0.05);
            }

            .status-header {
                color: #00ffff;
                font-size: 0.85rem;
                font-weight: 900;
                letter-spacing: 3px;
                margin-bottom: 1rem;
                text-transform: uppercase;
                display: flex;
                align-items: center;
                gap: 1rem;
            }

            .status-indicator {
                width: 12px;
                height: 12px;
                background: #00ff00;
                border-radius: 50%;
                box-shadow: 0 0 15px #00ff00;
                animation: blink 1.5s ease-in-out infinite;
            }

            @keyframes blink {
                0%, 100% { opacity: 1; }
                50% { opacity: 0.3; }
            }

            .status-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1rem;
                margin-bottom: 1.5rem;
            }

            .status-item {
                display: flex;
                justify-content: space-between;
                padding: 0.5rem;
                background: rgba(0, 255, 255, 0.05);
                border-left: 2px solid rgba(0, 255, 255, 0.5);
            }

            .status-label {
                color: #888;
                font-size: 0.75rem;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .status-value {
                color: #00ffff;
                font-weight: 700;
                text-shadow: 0 0 8px rgba(0, 255, 255, 0.5);
            }

            .log-console {
                background: rgba(0, 0, 0, 0.8);
                padding: 1rem;
                font-size: 0.75rem;
                color: #0f0;
                border: 1px solid rgba(0, 255, 0, 0.3);
                max-height: 200px;
                overflow-y: auto;
                font-family: 'SF Mono', monospace;
            }

            .log-line {
                margin: 0.25rem 0;
                opacity: 0;
                animation: logAppear 0.5s forwards;
            }

            @keyframes logAppear {
                to { opacity: 1; }
            }

            .log-time {
                color: #666;
                margin-right: 1rem;
            }

            .log-success { color: #00ff00; }
            .log-info { color: #00ffff; }
            .log-warning { color: #ffff00; }

            /* Scrollbar styling */
            .log-console::-webkit-scrollbar {
                width: 4px;
            }

            .log-console::-webkit-scrollbar-track {
                background: rgba(0, 255, 255, 0.1);
            }

            .log-console::-webkit-scrollbar-thumb {
                background: rgba(0, 255, 255, 0.5);
            }

            /* API Test Modal */
            .modal {
                display: none;
                position: fixed;
                z-index: 10000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.9);
                backdrop-filter: blur(10px);
                animation: modalFadeIn 0.3s ease;
            }

            @keyframes modalFadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }

            .modal.show {
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .modal-content {
                background: rgba(10, 10, 10, 0.95);
                border: 2px solid #00ffff;
                width: 90%;
                max-width: 800px;
                max-height: 80vh;
                box-shadow: 0 0 50px rgba(0, 255, 255, 0.5), inset 0 0 50px rgba(0, 255, 255, 0.1);
                animation: modalSlideIn 0.3s ease;
                overflow: hidden;
                display: flex;
                flex-direction: column;
            }

            @keyframes modalSlideIn {
                from {
                    transform: translateY(-50px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }

            .modal-header {
                padding: 1.5rem;
                border-bottom: 1px solid rgba(0, 255, 255, 0.3);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .modal-title {
                color: #00ffff;
                font-size: 1rem;
                font-weight: 900;
                letter-spacing: 3px;
                font-family: 'SF Mono', monospace;
            }

            .modal-close {
                background: transparent;
                border: 2px solid #ff00ff;
                color: #ff00ff;
                font-size: 1.5rem;
                width: 40px;
                height: 40px;
                cursor: pointer;
                transition: all 0.3s ease;
                font-weight: bold;
                line-height: 1;
            }

            .modal-close:hover {
                background: rgba(255, 0, 255, 0.2);
                box-shadow: 0 0 20px rgba(255, 0, 255, 0.5);
            }

            .modal-body {
                padding: 1.5rem;
                overflow-y: auto;
                flex: 1;
            }

            .response-header {
                display: flex;
                gap: 2rem;
                margin-bottom: 1rem;
                padding-bottom: 1rem;
                border-bottom: 1px solid rgba(0, 255, 255, 0.2);
                font-family: 'SF Mono', monospace;
                font-size: 0.85rem;
            }

            .response-header span {
                color: #00ffff;
            }

            #responseBody {
                background: rgba(0, 0, 0, 0.8);
                border: 1px solid rgba(0, 255, 255, 0.3);
                padding: 1.5rem;
                color: #00ff00;
                font-family: 'SF Mono', monospace;
                font-size: 0.85rem;
                overflow-x: auto;
                white-space: pre-wrap;
                word-wrap: break-word;
                line-height: 1.6;
            }

            @media (max-width: 768px) {
                h1 { font-size: 2.5rem; }
                .grid { grid-template-columns: 1fr; }
                .status-grid { grid-template-columns: 1fr; }
                .modal-content { width: 95%; max-height: 90vh; }
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
            // ============================================
            // Door Animation Component
            // ============================================
            class DoorAnimation {
                constructor() {
                    this.doorLeft = document.getElementById('doorLeft');
                    this.doorRight = document.getElementById('doorRight');
                }

                open() {
                    setTimeout(() => {
                        this.doorLeft?.classList.add('open-left');
                        this.doorRight?.classList.add('open-right');
                    }, 300);
                }
            }

            // ============================================
            // Uptime Counter Component
            // ============================================
            class UptimeCounter {
                constructor(elementId) {
                    this.element = document.getElementById(elementId);
                    this.startTime = Date.now();
                    this.intervalId = null;
                }

                start() {
                    this.update();
                    this.intervalId = setInterval(() => this.update(), 1000);
                }

                update() {
                    if (!this.element) return;

                    const elapsed = Math.floor((Date.now() - this.startTime) / 1000);
                    const hours = String(Math.floor(elapsed / 3600)).padStart(2, '0');
                    const minutes = String(Math.floor((elapsed % 3600) / 60)).padStart(2, '0');
                    const seconds = String(elapsed % 60).padStart(2, '0');

                    this.element.textContent = hours + ':' + minutes + ':' + seconds;
                }

                stop() {
                    if (this.intervalId) {
                        clearInterval(this.intervalId);
                    }
                }
            }

            // ============================================
            // Console Logger Component
            // ============================================
            class ConsoleLogger {
                constructor(elementId) {
                    this.console = document.getElementById(elementId);
                    this.logs = [
                        { delay: 10, type: 'info', msg: '→ API health check completed' },
                        { delay: 15, type: 'success', msg: '✓ Database connection healthy' },
                        { delay: 20, type: 'info', msg: '→ Request received from client' },
                        { delay: 25, type: 'success', msg: '✓ Response sent: 200 OK' },
                        { delay: 30, type: 'info', msg: '→ Monitoring system performance...' },
                        { delay: 35, type: 'success', msg: '✓ All systems operational' }
                    ];
                    this.currentIndex = 0;
                }

                start() {
                    this.scheduleNext();
                }

                scheduleNext() {
                    if (this.currentIndex >= this.logs.length) return;

                    const log = this.logs[this.currentIndex];
                    setTimeout(() => {
                        this.addLog(log.type, log.msg);
                        this.currentIndex++;
                        this.scheduleNext();
                    }, log.delay * 1000);
                }

                addLog(type, message) {
                    if (!this.console) return;

                    const now = new Date();
                    const timeStr = [now.getHours(), now.getMinutes(), now.getSeconds()]
                        .map(n => String(n).padStart(2, '0'))
                        .join(':');

                    const logLine = document.createElement('div');
                    logLine.className = 'log-line log-' + type;
                    logLine.innerHTML = '<span class="log-time">[' + timeStr + ']</span> ' + message;

                    this.console.appendChild(logLine);
                    this.console.scrollTop = this.console.scrollHeight;
                }
            }

            // ============================================
            // API Tester Component
            // ============================================
            async function testAPI(endpoint) {
                const modal = document.getElementById('apiModal');
                const statusEl = document.getElementById('responseStatus');
                const timeEl = document.getElementById('responseTime');
                const bodyEl = document.getElementById('responseBody');

                // Show modal with loading state
                modal.classList.add('show');
                statusEl.textContent = 'Loading...';
                timeEl.textContent = '';
                bodyEl.textContent = 'Fetching data...';

                const startTime = performance.now();

                try {
                    const response = await fetch(endpoint);
                    const endTime = performance.now();
                    const responseTime = Math.round(endTime - startTime);

                    const data = await response.json();

                    // Update modal with response
                    statusEl.textContent = 'Status: ' + response.status + ' ' + response.statusText;
                    timeEl.textContent = 'Time: ' + responseTime + 'ms';
                    bodyEl.textContent = JSON.stringify(data, null, 2);

                } catch (error) {
                    statusEl.textContent = 'Error';
                    timeEl.textContent = '';
                    bodyEl.textContent = 'Failed to fetch: ' + error.message;
                }
            }

            function closeModal() {
                const modal = document.getElementById('apiModal');
                modal.classList.remove('show');
            }

            // Close modal on outside click
            window.onclick = function(event) {
                const modal = document.getElementById('apiModal');
                if (event.target === modal) {
                    closeModal();
                }
            };

            // ============================================
            // Application Initialization
            // ============================================
            window.addEventListener('load', () => {
                // Initialize door animation
                const door = new DoorAnimation();
                door.open();

                // Initialize uptime counter
                const uptime = new UptimeCounter('uptime');
                uptime.start();

                // Initialize console logger
                const logger = new ConsoleLogger('console');
                logger.start();
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

# Authentication endpoints
route("/api/auth/signup", AuthController.signup, method = POST)
route("/api/auth/signup", AuthController.signup, method = OPTIONS)

route("/api/auth/login", AuthController.login, method = POST)
route("/api/auth/login", AuthController.login, method = OPTIONS)

route("/api/auth/logout", AuthController.logout, method = POST)
route("/api/auth/logout", AuthController.logout, method = OPTIONS)

route("/api/auth/refresh", AuthController.refresh, method = POST)
route("/api/auth/refresh", AuthController.refresh, method = OPTIONS)

route("/api/auth/me", AuthController.me, method = GET)
route("/api/auth/me", AuthController.me, method = OPTIONS)

# Favicon route (to suppress 404 errors)
route("/favicon.ico") do
    return ""
end

# Start server
up(8000, async = false)
