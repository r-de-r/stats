"""
DataFrames　の describe() は，sum(), var() を計算しない。

sum(), var() に対応する関数 describe2() を定義しておく。

指定できるのは :sum, :mean, :var, :std, :min, :q25, :median, :q75, :max, :nmissing である。

すべての統計量を計算するときは，統計量の指定をしないようにするか :all を指定すればよい。

なお，DataFrames.describe() と競合してもかまわないならば，関数名を describe にしてもよい。
この場合，DataFrames　の describe() を使うときは，DataFrames.describe() とする。

"""

using DataFrames, Statistics
function describe(df, arg...=:all)
    q25(x) = quantile(x, 0.25)
    q75(x) = quantile(x, 0.75)
    nmissing(x) = nrow(df) - length(ismissing.(x))
    arg0 = [:sum, :mean, :var, :std, :min, :q25, :median, :q75, :max, :nmissing]
    func = [sum, mean, var, std, minimum, q25, median, q75, maximum, nmissing]
    funcname = ["sum", "mean", "var", "std", "minimum", "q25", "median", "q75", "maximum", "nmissing"]
    arg[1] == :all && (arg = arg0)
    res = DataFrame(variable = Symbol.(names(df)))
    n = ncol(df)
    m = length(arg)
    body = Array{Float64, 2}(undef, n, m)
    loc = indexin(arg, arg0)
    for i in 1:n
        x = skipmissing(df[!, i])
        body[i, :] = [func[j](x) for j in loc]
    end
    bodydf = DataFrame(body, funcname[loc])
    pos = indexin(["nmissing"], funcname[loc])[1]
    isnothing(pos) || (bodydf[!, pos] = Int.(bodydf[:, pos]))
    hcat(res, bodydf)
end

"""
使用例

julia> using RDatasets, Statistics

julia> iris = dataset("datasets", "iris");

julia> describe(iris[:, 1:4])
4×11 DataFrame
 Row │ variable     sum      mean     var       std       minimum  q25      median   q75      maximum  nmissing
     │ Symbol       Float64  Float64  Float64   Float64   Float64  Float64  Float64  Float64  Float64  Int64
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ SepalLength    876.5  5.84333  0.685694  0.828066      4.3      5.1     5.8       6.4      7.9         0
   2 │ SepalWidth     458.6  3.05733  0.189979  0.435866      2.0      2.8     3.0       3.3      4.4         0
   3 │ PetalLength    563.7  3.758    3.11628   1.7653        1.0      1.6     4.35      5.1      6.9         0
   4 │ PetalWidth     179.9  1.19933  0.581006  0.762238      0.1      0.3     1.3       1.8      2.5         0

julia> DataFrames.describe(iris[:, 1:4])
4×7 DataFrame
 Row │ variable     mean     min      median   max      nmissing  eltype
     │ Symbol       Float64  Float64  Float64  Float64  Int64     DataType
─────┼─────────────────────────────────────────────────────────────────────
   1 │ SepalLength  5.84333      4.3     5.8       7.9         0  Float64
   2 │ SepalWidth   3.05733      2.0     3.0       4.4         0  Float64
   3 │ PetalLength  3.758        1.0     4.35      6.9         0  Float64
   4 │ PetalWidth   1.19933      0.1     1.3       2.5         0  Float64
"""
