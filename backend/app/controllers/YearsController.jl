"""
Years API Controller
"""
module YearsController

using Genie, Genie.Renderer.Json
using SQLite
using DBInterface

include("../../config/env.jl")
using .EnvConfig

export list_years

function list_years()
    headers = Dict(
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type"
    )

    try
        db = SQLite.DB(EnvConfig.get_db_path())

        result = DBInterface.execute(db, """
            SELECT DISTINCT year
            FROM works
            ORDER BY year DESC
        """)

        years = [row.year for row in result]

        response = Dict(
            "years" => years,
            "min_year" => isempty(years) ? nothing : minimum(years),
            "max_year" => isempty(years) ? nothing : maximum(years),
            "count" => length(years)
        )

        return Genie.Renderer.Json.json(response, headers = headers)

    catch e
        @error "List years error" exception=(e, catch_backtrace())
        response = Dict("success" => false, "error" => string(e))
        return Genie.Renderer.Json.json(response, status = 500, headers = headers)
    end
end

end # module
