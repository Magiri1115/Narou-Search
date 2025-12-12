"""
Work Details API Controller
"""
module WorkController

using Genie, Genie.Renderer.Json
using SQLite
using DBInterface
using Dates

include("../models/Work.jl")
using .WorkModel

include("../../config/env.jl")
using .EnvConfig

export get_work

function get_work()
    headers = Dict(
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type"
    )

    try
        ncode = Genie.Router.params(:ncode)

        if isnothing(ncode) || isempty(ncode)
            response = Dict("success" => false, "error" => "ncode parameter is required")
            return Genie.Renderer.Json.json(response, status = 400, headers = headers)
        end

        db = SQLite.DB(EnvConfig.get_db_path())

        result = DBInterface.execute(db, """
            SELECT ncode, title, writer, year, general_firstup
            FROM works
            WHERE ncode = ?
        """, [ncode])

        row = nothing
        for r in result
            row = r
            break
        end

        if isnothing(row)
            response = Dict("success" => false, "error" => "Work not found")
            return Genie.Renderer.Json.json(response, status = 404, headers = headers)
        end

        work_data = Dict(
            "ncode" => row.ncode,
            "title" => row.title,
            "writer" => row.writer,
            "year" => row.year,
            "general_firstup" => string(row.general_firstup)
        )

        return Genie.Renderer.Json.json(work_data, headers = headers)

    catch e
        @error "Get work error" exception=(e, catch_backtrace())
        response = Dict("success" => false, "error" => string(e))
        return Genie.Renderer.Json.json(response, status = 500, headers = headers)
    end
end

end # module
