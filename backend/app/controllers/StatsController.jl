"""
Statistics API Controller
"""
module StatsController

using Genie, Genie.Renderer.Json
using SQLite
using DBInterface

include("../../config/env.jl")
using .EnvConfig

export stats

function stats()
    headers = Dict(
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type"
    )

    try
        db = SQLite.DB(EnvConfig.get_db_path())

        # Total works count
        total_result = DBInterface.execute(db, "SELECT COUNT(*) as count FROM works")
        total_works = first(total_result).count

        # Works by year
        year_result = DBInterface.execute(db, """
            SELECT year, COUNT(*) as count
            FROM works
            GROUP BY year
            ORDER BY year DESC
        """)
        works_by_year = [Dict("year" => row.year, "count" => row.count) for row in year_result]

        # Top authors by work count
        author_result = DBInterface.execute(db, """
            SELECT writer, COUNT(*) as count
            FROM works
            GROUP BY writer
            ORDER BY count DESC
            LIMIT 10
        """)
        top_authors = [Dict("writer" => row.writer, "count" => row.count) for row in author_result]

        response = Dict(
            "total_works" => total_works,
            "works_by_year" => works_by_year,
            "top_authors" => top_authors
        )

        return Genie.Renderer.Json.json(response, headers = headers)

    catch e
        @error "Stats error" exception=(e, catch_backtrace())
        response = Dict("success" => false, "error" => string(e))
        return Genie.Renderer.Json.json(response, headers = headers)
    end
end

end # module
