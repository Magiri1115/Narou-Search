"""
モデルユニットテスト
"""

using Test
using SQLite
using Dates

include("../app/models/Work.jl")
using .WorkModel

@testset "Work構造体テスト" begin
    work = Work(
        "N1234",
        "テスト作品",
        "テスト作者",
        2024,
        DateTime(2024, 1, 1, 0, 0, 0)
    )

    @test work.ncode == "N1234"
    @test work.title == "テスト作品"
    @test work.writer == "テスト作者"
    @test work.year == 2024
    @test work.general_firstup == DateTime(2024, 1, 1, 0, 0, 0)

    @info "✓ Work構造体テスト成功"
end

@testset "テーブル作成テスト" begin
    db = SQLite.DB(":memory:")
    WorkModel.create_table(db)

    result = DBInterface.execute(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='works'")
    @test length(collect(result)) == 1

    @info "✓ テーブル作成テスト成功"
end

@info "全モデルテスト完了"
