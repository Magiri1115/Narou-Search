"""
Search API Controller
"""
module SearchController

using Genie, Genie.Renderer.Json, Genie.Requests
using SQLite

include("../models/Work.jl")
using .WorkModel

include("../../config/env.jl")
using .EnvConfig

export search

function search()
    headers = Dict(
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type"
    )
    
    try
        payload = Genie.Requests.getpayload()
        
        keyword = get(payload, :keyword, nothing)
        if !isnothing(keyword) && isempty(keyword)
            keyword = nothing
        end
        
        year_from_str = get(payload, :year_from, nothing)
        year_from = isnothing(year_from_str) ? nothing : tryparse(Int, string(year_from_str))
        
        year_to_str = get(payload, :year_to, nothing)
        year_to = isnothing(year_to_str) ? nothing : tryparse(Int, string(year_to_str))
        
        sort_by = get(payload, :sort_by, "general_firstup")
        order = get(payload, :order, "DESC")
        
        page = max(1, tryparse(Int, string(get(payload, :page, "1"))) |> x -> isnothing(x) ? 1 : x)
        limit = clamp(tryparse(Int, string(get(payload, :limit, "10"))) |> x -> isnothing(x) ? 10 : x, 1, 100)
        offset = (page - 1) * limit
        
        db = SQLite.DB(EnvConfig.get_db_path())
        
        works = WorkModel.search_works(
            db,
            keyword = keyword,
            year_from = year_from,
            year_to = year_to,
            sort_by = sort_by,
            order = order,
            limit = limit,
            offset = offset
        )
        
        total = WorkModel.count_works(
            db,
            keyword = keyword,
            year_from = year_from,
            year_to = year_to
        )
        
        works_data = map(works) do work
            Dict(
                "ncode" => work.ncode,
                "title" => work.title,
                "writer" => work.writer,
                "year" => work.year,
                "general_firstup" => string(work.general_firstup)
            )
        end
        
        response = Dict(
            "total" => total,
            "page" => page,
            "per_page" => limit,
            "results" => works_data
        )
        
        return Genie.Renderer.Json.json(response, headers = headers)
        
    catch e
        @error "Search error" exception=(e, catch_backtrace())
        response = Dict("success" => false, "error" => string(e))
        return Genie.Renderer.Json.json(response, headers = headers)
    end
end

end # module
