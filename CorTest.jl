"""

Julia  の HypothesisTests には，母相関係数の検定がないので，以下の関数を定義する。

スピアマンの順位相関係数，ケンドールの順位相関係数においては，同順位がある場合には近似検定になる。

ケンドールの順位相関係数においては，信頼区間は求めない。
"""

using Statistics, StatsBase, Distributions
roundn(x, digits) = round(x, digits=digits)
formatp(p) = p < 0.00001 ? "< 0.00001" : "= " * string(roundn(p, 5))
index(method) = indexin(method[1], ['p', 's', 'k'])[1]
function CorTest(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}; level=0.95, method="pearson")
    func = [cor, corspearman, corkendall][index(method)]
    CorTest(length(x), func(x, y); level, method)
end
function CorTest(n::Int, r::Float64; level=0.95, method="pearson")
    if method != "kendall"
        t = r * sqrt((n-2)/(1-r^2))
        df = n-2
        p = 2ccdf(TDist(df), abs(t))
        q = quantile(Normal(), 0.5 - 0.5level)
        conf = tanh.(atanh(r) .+ [q, -q] ./ sqrt(n-3))
        println("n = $n, r = $(roundn(r, 5)), t = $(roundn(t, 5)), df = $df, p-value $(formatp(p))")
        println("$(Int(100level)) percent confidence interval = $(roundn.(conf, 5))")
    else
        z = r / sqrt((4n + 10) / (9n * (n - 1)))
        p = 2ccdf(Normal(), abs(z))
        println("n = $n, r = $(roundn(r, 5)), z = $(roundn(z, 5)), p-value $(formatp(p))")
    end
end;

"""
使用法

julia> x = [58.3, 43.6, 49.9, 64.1, 51.6, 36.6, 58.7, 66.7, 50.7, 53.1,
            56.1, 42.0, 45.5, 30.9, 42.3];

julia> y = [46.3, 51.5, 64.5, 55.6, 63.9, 35.6, 61.2, 56.9, 44.2, 57.3,
            42.7, 47.1, 32.4, 39.7, 51.0];

julia> CorTest(x, y)
n = 15, r = 0.52225, t = 2.20803, df = 13, p-value = 0.04582
95 percent confidence interval = [0.01363, 0.81616]

julia> CorTest(x, y, method="spearman")
n = 15, r = 0.47143, t = 1.92737, df = 13, p-value = 0.07607
95 percent confidence interval = [-0.05384, 0.79234]

julia> CorTest(x, y, method="kendall")
n = 15, r = 0.31429, z = 1.63308, p-value = 0.10245

julia> CorTest(x, y, level=0.99) # 信頼率の設定は，level= で指定する
n = 15, r = 0.52225, t = 2.20803, df = 13, p-value = 0.04582
99 percent confidence interval = [-0.16269, 0.86753]

julia> CorTest(24, 0.476, level=0.9) # サンプルサイズと相関係数を与える場合
n = 24, r = 0.476, t = 2.53869, df = 22, p-value = 0.01871
90 percent confidence interval = [0.15754, 0.70478]

"""
