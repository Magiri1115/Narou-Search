"""
Quick API test without starting server
"""

using SQLite

include("app/models/Work.jl")
using .WorkModel

include("config/env.jl")
using .EnvConfig

# Test search functionality
db_path = EnvConfig.get_db_path()
db = SQLite.DB(db_path)

println("=== Testing Search API ===")
println()

# Test 1: All works
println("1. Get all works (limit 5):")
results = WorkModel.search_works(db, limit=5)
for work in results
    println("  - $(work.title) by $(work.writer) ($(work.year))")
end
println()

# Test 2: Keyword search
println("2. Search by keyword 'スライム':")
results = WorkModel.search_works(db, keyword="スライム")
for work in results
    println("  - $(work.title) by $(work.writer)")
end
println()

# Test 3: Year range
println("3. Works from 2015-2018:")
results = WorkModel.search_works(db, year_from=2015, year_to=2018)
for work in results
    println("  - $(work.title) ($(work.year))")
end
println()

# Test 4: Count
total = WorkModel.count_works(db)
println("4. Total works in database: $total")
println()

println("=== API Test Complete ===")
