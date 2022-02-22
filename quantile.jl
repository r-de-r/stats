"""
複数の変数に対して，任意の q 値に対するパーセンタイル値を求めるには，以下のような関数を定義すればよい。

missing を除去して計算される。
"""

function quantile2(df, qs=[0, 0.25, 0.5, 0.75, 1])
    Names =["q$(Int(100q))" for q in qs]
    Names = replace(Names, "q0" => "min", "q50" => "median", "q100" => "max")
    qtile = map(x -> quantile(skipmissing(x), qs), eachcol(df))
    df2 = DataFrame(Matrix(reshape(vcat(qtile...), length(qs), :)'), Names)
    n = map(x -> length(filter(!ismissing, x)), eachcol(df))
    insertcols!(df2, 1, :variable => names(df), :n => n)
    df2
end

"""
使用例

julia> using RDatasets, Statistics


julia> iris = dataset("datasets", "iris");



julia> quantile2(iris[:, 1:4])
4×7 DataFrame
 Row │ variable     n      min      q25      median   q75      max
     │ String       Int64  Float64  Float64  Float64  Float64  Float64
─────┼─────────────────────────────────────────────────────────────────
   1 │ SepalLength    150      4.3      5.1     5.8       6.4      7.9
   2 │ SepalWidth     150      2.0      2.8     3.0       3.3      4.4
   3 │ PetalLength    150      1.0      1.6     4.35      5.1      6.9
   4 │ PetalWidth     150      0.1      0.3     1.3       1.8      2.5
"""
