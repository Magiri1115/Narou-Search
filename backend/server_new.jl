"""
Genie.jl API Server - Main Entry Point
"""

using Genie, Genie.Router, Genie.Renderer.Json, Genie.Renderer.Html
using SQLite

# Load configuration
include("config/env.jl")
using .EnvConfig

# Load models
include("app/models/Work.jl")
using .WorkModel

include("app/models/User.jl")
using .UserModel

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

# Load routes
include("config/routes.jl")

# Start server
println("🚀 Starting Narou Search API Server on port 8000...")
up(8000, async = false)
