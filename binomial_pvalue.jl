"""
Julia の binomialtest() は，母比率 ≠ 0.5 で両側検定の場合に片側 p 値を 2 倍した結果を返す。

他の多くの統計プログラムと同じ結果を得るためのオプション設定がないので，以下のようなプログラムを使用すればよい。
"""

using Distributions
function binomial_pvalue(x, n, p=0.5; tail=:both)
    obj = Binomial(n, p)
    tail == :left  && return cdf(obj, x)
    tail == :right && return ccdf(obj, x - 1)
    p == 0 && return Float64(x == 0)
    p == 1 && return Float64(x == n)
    m = n * p
    x == m && return 1
    limit = 1.0000001pdf(obj, x)
    if x < m
        y = sum(pdf.(obj, ceil(Int, m):n) .<= limit)
        cdf(obj, x) + ccdf(obj, n - y)
    else
        y = sum(pdf.(obj, 0:floor(Int, m)) .<= limit)
        cdf(obj, y - 1) + ccdf(obj, x - 1)
    end
end;

"""
使用法

julia> using HypothesisTests

julia> BinomialTest(12, 20, 0.8)
Binomial test
-------------
Population details:
    parameter of interest:   Probability of success
    value under h_0:         0.8
    point estimate:          0.6
    95% confidence interval: (0.3605, 0.8088)

Test summary:
    outcome with 95% confidence: fail to reject h_0
    two-sided p-value:           0.0643

Details:
    number of observations: 20
    number of successes:    12


julia> binomial_pvalue(12, 20, 0.8)
0.04367187812694369

"""
