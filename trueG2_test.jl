"""

trueG2_test() は，分割表のマス目のうちに 0 があるような場合でも，正確に lambda=0.0 にした場合の，正しい答えを返す。

"""

using Distributions
function trueG2_test(x; correct=false)
    # セルに 0 があっても正しい答えを出す
    # correct=true で，連続性の補正も行うことができる
    ln(n) = sum(n .== 0 ? 0 : n .* log(n) for n in vcat(n...))
    nrows, ncols = size(x)
    n = sum(x) # 全サンプルサイズ
    n1 = sum(x, dims=2) # 行和
    n2 = sum(x, dims=1) # 列和
    G2 = 2*(ln(x) - ln(n1) - ln(n2) + ln(n)) # G 統計量
    correct && (G2 /= 1 + (n * sum(1 ./ n1) - 1) * (n * sum(1 ./ n2) - 1) / (6n * nrows * ncols)) # 連続性の補正
    df = (nrows - 1) * (ncols - 1) # G の自由度
    p = ccdf(Chisq(df), G2)
    name = correct ? "corrected G-sq." : "G-sq."
    println("$name = $G2,  df = $df,  p value = $p")
end

"""
使用法

julia> z = [4 5 2 0
            0 7 6 1
            1 0 3 1]
3×4 Matrix{Int64}:
 4  5  2  0
 0  7  6  1
 1  0  3  1

julia> trueG2_test(z)
G-sq. = 15.364591286599591,  df = 6,  p value = 0.017602886503051453

また，ピアソンの χ2
検定では 2×2 分割表の場合にしか連続性の補正は行えないが，G2 検定は分割表の大きさに関わらず，連続性の補正を行うことができる。

上に示した関数 trueG2_test() で correct=true を指定すればよい。

julia> trueG2_test(z, correct=true) # 連続性の補正
corrected G-sq. = 13.776490649307341,  df = 6,  p value = 0.032235015595581236

"""
