"""
Genie.jl API Server
"""

using Genie, Genie.Router, Genie.Renderer.Json
using SQLite

# Load models
include("app/models/Work.jl")
using .WorkModel

# Load config
include("config/env.jl")
using .EnvConfig

# Load controller
include("app/controllers/SearchController.jl")
using .SearchController

# Routes
route("/") do
    "Narou Search API - Running on Genie.jl"
end

route("/search", SearchController.search, method = GET)
route("/search", SearchController.search, method = POST)
route("/search", SearchController.search, method = OPTIONS)

# Start server
up(8000, async = false)
