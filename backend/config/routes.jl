"""
Route definitions
"""

using Genie.Router

# Load view
include("../app/views/home.jl")

# Home route
route("/") do
    html(render_home_page())
end

# Search endpoints
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
