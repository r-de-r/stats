"""

二重クロス集計表の各マス目の度数を円の面積で表現するのがバルーンプロットである。

以下の関数に freqtable() による集計表を与えれば描画される。注意点は，円の面積が度数に対応するということ。
"""

using Plots
function balloonplot(table; xlabel="", ylabel="",
                     color=:red, unit=100)
    θ = collect(0:360);
    x = cosd.(θ);
    y = sind.(θ);
    gr(linecolor=:black, label="")
    row, col = size(table)
    row_names, col_names = names(table)
    mx = maximum(table)
    p2 = vline(0.5:col+0.5, xlimit=(0.5, col+0.5),
        ylimit=(0.5, row+0.5), showaxis=false,
        xlabel=xlabel, ylabel=ylabel,
        aspect_ratio=1, size=(col*unit, row*unit))
    hline!(0.5:row+0.5)
    for i in 1:row
        for j in 1:col
            r = 0.45sqrt(table[i, j]/mx)
            plot!(r .* x .+ j, r .* y .+ (row - i + 1),
                  seriestype=:shape, fillcolor=color)
            annotate!(j, row - i + 1, text(string(table[i, j]), 8))
        end
    end
    xticks!(1:col, col_names)
    yticks!(1:row, reverse(row_names))
    p2
end;
​
"""
使用法

julia> using RDatasets

julia> haireyecolor = RDatasets.dataset("datasets", "HairEyeColor");

julia> using DataFrames, FreqTables, Plots

julia> haireyecolor[!, 1:3] = string.(haireyecolor[!, 1:3]); # String7 が使えないパッケージに対する過渡的な対処法

julia> HEC = DataFrame();

julia> for row in eachrow(haireyecolor), j in 1:row.Freq
           push!(HEC, row)
       end

julia> select!(HEC, Not(:Freq)); # Freq 列を除く

julia> EyeHair = freqtable(HEC.Eye, HEC.Hair)
4×4 Named Matrix{Int64}
Dim1 ╲ Dim2 │ Black  Blond  Brown    Red
────────────┼───────────────────────────
Blue        │    20     94     84     17
Brown       │    68      7    119     26
Green       │     5     16     29     14
Hazel       │    15     10     54     14

julia> balloonplot(EyeHair,
           xlabel="Hair color", ylabel="Eye color", color=:blue)
"""
