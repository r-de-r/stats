"""
HypothesisTests.ChisqTest() を補完するプログラム chisq_test()

https://juliastats.org/HypothesisTests.jl/stable/
で解説されている ChisqTest() を使いやすくするために書いた。

使用する場合は，このファイル chisq_test.jl を Julia の Path が通っているディレクトリに保存しておき，
>julia include("chisq_test.jl")
のようにインクルードする。

使用法は https://r-de-r.github.io/stats/Julia-stats7.html を参照のこと。
"""

using HypothesisTests

using FreqTables

# 結果を簡潔に表示するための関数
function PDTsummary(result)
    println("chisq. = $(round(result.stat, digits=5)), df = $(result.df), p.value = $(round(pvalue(result), digits=5))")
end

# 多項分布の検定
function chisq_test(x::AbstractVector{T}, theta0::Vector{U} = ones(length(x))/length(x)) where {T<:Integer,U<:AbstractFloat}
    result = PowerDivergenceTest(reshape(x, length(x), 1), lambda=1.0, theta0=theta0)
    PDTsummary(result)
end

# 分割表を入力してχ二乗検定
function chisq_test(x::AbstractMatrix{T}; correct::Bool=false) where T<:Integer
    nrows, ncols = size(x)
    if correct && nrows == 2 && ncols == 2
        n = sum(x)
        a, c, b, d = float.(x)
        stat = n*max(0, abs(a*d - b*c) - 0.5n)^2 / ((a+b)*(c+d)*(a+c)*(b+d))
        result = PowerDivergenceTest(1, ones(4), stat, 1, x, n, ones(4), x, x, x)   
    else
        result = PowerDivergenceTest(x, lambda=1.0)
    end
    PDTsummary(result)
end

# 2 つの整数ベクトルを入力してχ二乗検定
function chisq_test(x::AbstractVector{T}, y::AbstractVector{T}) where T<:Integer
    d = freqtable(x, y)
    result = PowerDivergenceTest(d, lambda=1.0)
    PDTsummary(result)
end

# 2 つの文字列ベクトルを入力してχ二乗検定
function chisq_test(x::AbstractVector{T}, y::AbstractVector{T}) where T<:String
    d = freqtable(x, y)
    result = PowerDivergenceTest(d, lambda=1.0)
    PDTsummary(result)
end

# 整数ベクトルと文字列ベクトルを入力してχ二乗検定
function chisq_test(x::AbstractVector{T}, y::AbstractVector{U}) where {T<:Integer,U<:String}
    d = freqtable(x, y)
    result = PowerDivergenceTest(d, lambda=1.0)
    PDTsummary(result)
end

# 文字列ベクトルと整数ベクトルを入力してχ二乗検定
function chisq_test(x::AbstractVector{T}, y::AbstractVector{U}) where {T<:String,U<:Integer}
    d = freqtable(x, y)
    result = PowerDivergenceTest(d, lambda=1.0)
    PDTsummary(result)
end
