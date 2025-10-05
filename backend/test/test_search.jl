"""
Search API Integration Tests
"""

using Test
using HTTP
using JSON3
using SQLite
using Dates

include("../app/models/Work.jl")
using .WorkModel

include("../config/env.jl")
using .EnvConfig

"""
Setup test database
"""
function setup_test_db()
    db_path = joinpath(@__DIR__, "..", "db", "test.sqlite3")

    if isfile(db_path)
        rm(db_path)
    end

    db = SQLite.DB(db_path)
    WorkModel.create_table(db)

    test_works = [
        Work("N0001", "Isekai Story", "Author A", 2020, DateTime(2020, 1, 1, 0, 0, 0)),
        Work("N0002", "Magic Academy", "Author B", 2021, DateTime(2021, 6, 15, 12, 0, 0)),
        Work("N0003", "Hero Adventure", "Author C", 2022, DateTime(2022, 3, 20, 9, 30, 0)),
        Work("N0004", "Isekai Chef", "Author A", 2023, DateTime(2023, 7, 10, 18, 0, 0)),
        Work("N0005", "Slime Life", "Author D", 2021, DateTime(2021, 12, 1, 0, 0, 0))
    ]

    for work in test_works
        WorkModel.save_work(db, work)
    end

    @info "Test data loaded" count=length(test_works)
    return db, db_path
end

@testset "Keyword Search Test" begin
    db, db_path = setup_test_db()

    results = WorkModel.search_works(db, keyword="Isekai")
    @test length(results) == 2
    @test any(w -> w.title == "Isekai Story", results)
    @test any(w -> w.title == "Isekai Chef", results)

    results = WorkModel.search_works(db, keyword="Author A")
    @test length(results) == 2

    @info "✓ Keyword search test passed"
end

@testset "Year Range Search Test" begin
    db, db_path = setup_test_db()

    results = WorkModel.search_works(db, year_from=2021, year_to=2021)
    @test length(results) == 2

    results = WorkModel.search_works(db, year_from=2020, year_to=2022)
    @test length(results) == 4

    results = WorkModel.search_works(db, year_from=2023)
    @test length(results) == 1
    @test results[1].title == "Isekai Chef"

    @info "✓ Year range search test passed"
end

@testset "Sort Test" begin
    db, db_path = setup_test_db()

    results = WorkModel.search_works(db, sort_by="title", order="ASC")
    @test results[1].title < results[end].title

    results = WorkModel.search_works(db, sort_by="year", order="DESC")
    @test results[1].year == 2023
    @test results[end].year == 2020

    @info "✓ Sort test passed"
end

@testset "Pagination Test" begin
    db, db_path = setup_test_db()

    results = WorkModel.search_works(db, limit=2, offset=0)
    @test length(results) == 2

    results = WorkModel.search_works(db, limit=2, offset=2)
    @test length(results) == 2

    results = WorkModel.search_works(db, limit=2, offset=4)
    @test length(results) == 1

    @info "✓ Pagination test passed"
end

@testset "Count Test" begin
    db, db_path = setup_test_db()

    total = WorkModel.count_works(db)
    @test total == 5

    total = WorkModel.count_works(db, keyword="Isekai")
    @test total == 2

    total = WorkModel.count_works(db, year_from=2021, year_to=2021)
    @test total == 2

    @info "✓ Count test passed"
end

@testset "UPSERT Test" begin
    db, db_path = setup_test_db()

    updated_work = Work("N0001", "Isekai Story [Revised]", "Author A", 2020, DateTime(2020, 1, 1, 0, 0, 0))
    WorkModel.save_work(db, updated_work)

    results = WorkModel.search_works(db, keyword="Revised")
    @test length(results) == 1
    @test results[1].title == "Isekai Story [Revised]"

    total = WorkModel.count_works(db)
    @test total == 5

    @info "✓ UPSERT test passed"
end

@info "All integration tests completed"
