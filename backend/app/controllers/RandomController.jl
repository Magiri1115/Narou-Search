"""
Random Work API Controller
"""
module RandomController

using Genie, Genie.Renderer.Json, Genie.Requests
using SQLite
using DBInterface
using Dates

include("../../config/env.jl")
using .EnvConfig

export random_works

function random_works()
    headers = Dict(
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type"
    )

    try
        payload = Genie.Requests.getpayload()

        count = clamp(tryparse(Int, string(get(payload, :count, "10"))) |> x -> isnothing(x) ? 10 : x, 1, 50)

        db = SQLite.DB(EnvConfig.get_db_path())

        result = DBInterface.execute(db, """
            SELECT ncode, title, writer, year, general_firstup
            FROM works
            ORDER BY RANDOM()
            LIMIT ?
        """, [count])

        works_data = [Dict(
            "ncode" => row.ncode,
            "title" => row.title,
            "writer" => row.writer,
            "year" => row.year,
            "general_firstup" => string(row.general_firstup)
        ) for row in result]

        response = Dict(
            "count" => length(works_data),
            "works" => works_data
        )

        return Genie.Renderer.Json.json(response, headers = headers)

    catch e
        @error "Random works error" exception=(e, catch_backtrace())
        response = Dict("success" => false, "error" => string(e))
        return Genie.Renderer.Json.json(response, status = 500, headers = headers)
    end
end

end # module
