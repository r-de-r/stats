"""
イエーツの連続性の補正による p 値

2×2 分割表の場合，PowerDivergenceTest() で得られる検定統計量はイエーツの連続性の補正をしないものである。

イエーツの連続性の補正をする場合には，以下の関数を定義しておくとよい。
"""

using Distributions, HypothesisTests
function yates(x)
    result = PowerDivergenceTest(x, lambda=1.0)
    n = sum(x)
    a, c, b, d = x
    stat = n*max(0, abs(a*d - b*c) - 0.5n)^2 / ((a+b)*(c+d)*(a+c)*(b+d))
    p = ccdf(Chisq(1), stat)
    println("corrected χ-sq. = $stat,  df = 1,  p value = $p")
end;

"""
使用法

julia> x = [12 35
            43 56]
2×2 Matrix{Int64}:
 12  35
 43  56

julia> yates(x)
corrected χ-sq. = 3.621119907386832,  df = 1,  p value = 0.057050457416995715

"""
