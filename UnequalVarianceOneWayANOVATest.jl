"""
R ではウェルチの方法による一元元配置分散分析がデフォルトなのであるが，Julia にはないので以下の関数を定義しておく。

関数定義
UnequalVarianceOneWayANOVATestOneWayANOVATest(groups::AbstractVector{<:Real}...)

OneWayANOVATest(groups::AbstractVector{<:Real}...) の場合と同じく，引数として各標本の観測データベクトルを列挙する。
"""

using Statistics, Distributions

function UnequalVarianceOneWayANOVATest(groups::AbstractVector{<:Real}...)
    roundn(x, digits) = round(x, digits=digits)
    formatp(p) = p < 0.00001 ? "< 0.00001" : "= " * string(roundn(p, 5))
    ni = Int[]
    mi = Float64[]
    vi = Float64[]
    for x in groups
        append!(ni, length(x))
        append!(mi, mean(x))
        append!(vi, var(x))
    end
    k = length(ni)
    wi = ni ./ vi
    sum_wi = sum(wi)
    tmp = sum((1 .- wi ./ sum_wi).^2 ./ (ni .- 1)) ./ (k^2 - 1)
    m = sum(wi .* mi) / sum_wi
    df1, df2 = k - 1, 1 / 3tmp
    F = sum(wi .* (mi .- m).^2) / (df1 * (1 + 2 * (k - 2) * tmp))
    p = ccdf(FDist(df1, df2), F)
    println("F = $(roundn(F, 5)),  df1 = $df1,  df2 = $(roundn(df2, 5)),  p-value $(formatp(p)))")
end;

"""
使用例

julia> g1 = [27.7, 45.2, 32.8, 49.5, 31.0, 55.5, 31.7, 53.9];

julia> g2 = [38.0, 47.4, 55.3, 52.5, 39.2, 34.9];

julia> g3 = [44.0, 29.8, 42.5, 23.4, 20.7, 57.3, 42.0, 56.8, 44.1, 32.7];

julia> UnequalVarianceOneWayANOVATest(g1, g2, g3)
F = 0.51339,  df1 = 2,  df2 = 13.589,  p-value = 0.60962)

"""
