"""
Application Bootstrap
Initialize dependencies and setup
"""

using SQLite

"""
Initialize database and tables
"""
function init_database(UserModel)
    db = get_db()
    UserModel.create_tables(db)
    return db
end

"""
Load all controllers
Returns a named tuple of all controllers
"""
function load_controllers()
    # Load controllers
    include("../app/controllers/SearchController.jl")
    include("../app/controllers/StatsController.jl")
    include("../app/controllers/WorkController.jl")
    include("../app/controllers/AuthorController.jl")
    include("../app/controllers/RandomController.jl")
    include("../app/controllers/YearsController.jl")
    include("../app/controllers/AuthController.jl")

    # Return controllers as named tuple
    return (
        SearchController = Main.SearchController,
        StatsController = Main.StatsController,
        WorkController = Main.WorkController,
        AuthorController = Main.AuthorController,
        RandomController = Main.RandomController,
        YearsController = Main.YearsController,
        AuthController = Main.AuthController
    )
end

"""
Load all models
Returns a named tuple of all models
"""
function load_models()
    include("../app/models/Work.jl")
    include("../app/models/User.jl")

    return (
        WorkModel = Main.WorkModel,
        UserModel = Main.UserModel
    )
end
