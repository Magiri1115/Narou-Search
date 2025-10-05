"""
Narou API data fetch and cache update script
"""

using HTTP
using JSON3
using SQLite
using Dates

include("../app/models/Work.jl")
using .WorkModel

include("../config/env.jl")
using .EnvConfig

"""
Fetch data from Narou API
"""
function fetch_narou_data(;limit::Int = 50)::Vector
    url = "https://api.syosetu.com/novelapi/api/"

    params = Dict(
        "out" => "json",
        "of" => "n-t-w-gf",
        "lim" => limit,
        "order" => "hyoka"
    )

    try
        response = HTTP.get(url, query = params)
        data = JSON3.read(String(response.body))

        if length(data) > 1
            return collect(data[2:end])
        else
            return []
        end
    catch e
        @error "Narou API fetch error" exception=(e, catch_backtrace())
        return []
    end
end

"""
Convert API data to Work struct
"""
function convert_to_work(item)::Union{Work, Nothing}
    try
        datetime_str = get(item, :general_firstup, "")
        if isempty(datetime_str)
            return nothing
        end

        dt = DateTime(datetime_str, "yyyy-mm-dd HH:MM:SS")
        year = Dates.year(dt)

        return Work(
            get(item, :ncode, ""),
            get(item, :title, "Untitled"),
            get(item, :writer, "Unknown"),
            year,
            dt
        )
    catch e
        @error "Data conversion error" item exception=(e, catch_backtrace())
        return nothing
    end
end

"""
Update database
"""
function update_database(works::Vector{Work})
    db_path = EnvConfig.get_db_path()

    db = SQLite.DB(db_path)
    WorkModel.create_table(db)

    saved_count = 0
    for work in works
        try
            WorkModel.save_work(db, work)
            saved_count += 1
        catch e
            @error "Save error" work exception=(e, catch_backtrace())
        end
    end

    @info "Database updated" saved_count total=length(works)
    return saved_count
end

"""
Main process
"""
function main()
    @info "Starting Narou API data fetch..."

    raw_data = fetch_narou_data(limit = 50)
    @info "Fetched data count" count=length(raw_data)

    works = Work[]
    for item in raw_data
        work = convert_to_work(item)
        if !isnothing(work)
            push!(works, work)
        end
    end

    @info "Conversion completed" valid_works=length(works)

    if length(works) > 0
        saved = update_database(works)
        @info "Process completed" saved_count=saved
    else
        @warn "No valid data found"
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
