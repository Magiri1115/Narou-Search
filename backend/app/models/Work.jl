"""
Work data model
"""
module WorkModel

using SQLite
using DBInterface
using Dates

export Work, search_works, save_work, create_table

"""
Work struct
"""
struct Work
    ncode::String
    title::String
    writer::String
    year::Int
    general_firstup::DateTime
end

"""
Create works table
"""
function create_table(db::SQLite.DB)
    DBInterface.execute(db, """
        CREATE TABLE IF NOT EXISTS works (
            ncode TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            writer TEXT NOT NULL,
            year INTEGER NOT NULL,
            general_firstup TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
end

"""
Search works
"""
function search_works(
    db::SQLite.DB;
    keyword::Union{String, Nothing} = nothing,
    year_from::Union{Int, Nothing} = nothing,
    year_to::Union{Int, Nothing} = nothing,
    sort_by::String = "general_firstup",
    order::String = "DESC",
    limit::Int = 10,
    offset::Int = 0
)::Vector{Work}

    query = "SELECT ncode, title, writer, year, general_firstup FROM works WHERE 1=1"
    params = []

    if !isnothing(keyword) && !isempty(keyword)
        # スペースで区切って複数キーワードをAND検索
        keywords = split(keyword)
        for kw in keywords
            if !isempty(kw)
                query *= " AND (title LIKE ? OR writer LIKE ?)"
                keyword_pattern = "%$kw%"
                push!(params, keyword_pattern, keyword_pattern)
            end
        end
    end

    if !isnothing(year_from)
        query *= " AND year >= ?"
        push!(params, year_from)
    end

    if !isnothing(year_to)
        query *= " AND year <= ?"
        push!(params, year_to)
    end

    valid_sort_columns = ["general_firstup", "title", "year"]
    sort_column = sort_by in valid_sort_columns ? sort_by : "general_firstup"
    sort_order = uppercase(order) in ["ASC", "DESC"] ? uppercase(order) : "DESC"
    query *= " ORDER BY $sort_column $sort_order"

    query *= " LIMIT ? OFFSET ?"
    push!(params, limit, offset)

    result = DBInterface.execute(db, query, params)

    works = Work[]
    for row in result
        push!(works, Work(
            row.ncode,
            row.title,
            row.writer,
            row.year,
            DateTime(row.general_firstup)
        ))
    end

    return works
end

"""
Save work (UPSERT)
"""
function save_work(db::SQLite.DB, work::Work)
    DBInterface.execute(db, """
        INSERT INTO works (ncode, title, writer, year, general_firstup)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(ncode) DO UPDATE SET
            title = excluded.title,
            writer = excluded.writer,
            year = excluded.year,
            general_firstup = excluded.general_firstup
    """, [work.ncode, work.title, work.writer, work.year, string(work.general_firstup)])
end

"""
Count works
"""
function count_works(
    db::SQLite.DB;
    keyword::Union{String, Nothing} = nothing,
    year_from::Union{Int, Nothing} = nothing,
    year_to::Union{Int, Nothing} = nothing
)::Int

    query = "SELECT COUNT(*) as count FROM works WHERE 1=1"
    params = []

    if !isnothing(keyword) && !isempty(keyword)
        # スペースで区切って複数キーワードをAND検索
        keywords = split(keyword)
        for kw in keywords
            if !isempty(kw)
                query *= " AND (title LIKE ? OR writer LIKE ?)"
                keyword_pattern = "%$kw%"
                push!(params, keyword_pattern, keyword_pattern)
            end
        end
    end

    if !isnothing(year_from)
        query *= " AND year >= ?"
        push!(params, year_from)
    end

    if !isnothing(year_to)
        query *= " AND year <= ?"
        push!(params, year_to)
    end

    result = DBInterface.execute(db, query, params)
    row = first(result)
    return row.count
end

end # module
