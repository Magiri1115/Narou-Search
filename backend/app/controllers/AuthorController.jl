"""
Author API Controller
"""
module AuthorController

using Genie, Genie.Renderer.Json, Genie.Requests
using SQLite
using DBInterface

include("../../config/env.jl")
using .EnvConfig

export list_authors

function list_authors()
    headers = Dict(
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type"
    )

    try
        payload = Genie.Requests.getpayload()

        page = max(1, tryparse(Int, string(get(payload, :page, "1"))) |> x -> isnothing(x) ? 1 : x)
        limit = clamp(tryparse(Int, string(get(payload, :limit, "20"))) |> x -> isnothing(x) ? 20 : x, 1, 100)
        offset = (page - 1) * limit

        search = get(payload, :search, nothing)

        db = SQLite.DB(EnvConfig.get_db_path())

        # Build query
        query = """
            SELECT writer, COUNT(*) as work_count
            FROM works
        """
        params = []

        if !isnothing(search) && !isempty(search)
            query *= " WHERE writer LIKE ?"
            push!(params, "%$search%")
        end

        query *= " GROUP BY writer ORDER BY work_count DESC, writer ASC LIMIT ? OFFSET ?"
        push!(params, limit, offset)

        result = DBInterface.execute(db, query, params)
        authors = [Dict("writer" => row.writer, "work_count" => row.work_count) for row in result]

        # Get total count
        count_query = "SELECT COUNT(DISTINCT writer) as count FROM works"
        count_params = []

        if !isnothing(search) && !isempty(search)
            count_query *= " WHERE writer LIKE ?"
            push!(count_params, "%$search%")
        end

        count_result = DBInterface.execute(db, count_query, count_params)
        total = first(count_result).count

        response = Dict(
            "total" => total,
            "page" => page,
            "per_page" => limit,
            "authors" => authors
        )

        return Genie.Renderer.Json.json(response, headers = headers)

    catch e
        @error "List authors error" exception=(e, catch_backtrace())
        response = Dict("success" => false, "error" => string(e))
        return Genie.Renderer.Json.json(response, status = 500, headers = headers)
    end
end

end # module
