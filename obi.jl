"""
帯グラフは，グループごとの相対度数分布を積み上げ棒グラフにしたものなので，以下のような関数を作っておけばよい。
"""

function obi(table; title="", ylabel="", barwidth=0.9, fontsize=8, width=600, height=300)
    g, n = size(table)
    table2 = table ./ sum(table, dims=2)
    row_names, col_names = names(table)
    p2 = groupedbar(table2[:, end:-1:1],
        bar_width=barwidth,
        direction=:horizontal,
        bar_position = :stack,
        yticks = (1:length(row_names), row_names),
        xticks = (0:0.1:1, string.(0:10:100) .* "%"),
        showaxis=:x,
        title = title,
        ylabel = ylabel,
        size=(width, height)
        )
    for row in 1:g
        cum = cumsum(table2[row, :])
        cum0 = vcat(0, cum[1:end-1]...)
        for col in n:-1:1
            annotate!((cum0[col] + cum[col])/2, row,
                text(col_names[col] * "\n" * string(table[row, col]), fontsize))
        end
    end
    p2
end

"""
使用法は，freqtable() の第 1 引数にグループ分けの変数，第 2 引数に分布を表示する変数として得た二重クロス表を barplot2() に与える。

julia> using RDatasets

julia> haireyecolor = RDatasets.dataset("datasets", "HairEyeColor");

julia> haireyecolor[!, 1:3] = string.(haireyecolor[!, 1:3]); # String7 が使えないパッケージに対する過渡的な対処法

julia> HEC = DataFrame();

julia> for row in eachrow(haireyecolor), j in 1:row.Freq
           push!(HEC, row)
       end

julia> select!(HEC, Not(:Freq)); # Freq 列を除く

julia> using FreqTables, DataFrames, Plots, StatsPlots

julia> freq2 = freqtable(HEC.Hair, HEC.Sex)
4×2 Named Matrix{Int64}
Dim1 ╲ Dim2 │ Female    Male
────────────┼───────────────
Black       │     52      56
Blond       │     81      46
Brown       │    143     143
Red         │     37      34

julia> obi(freq2, ylabel="Hair", title="Distribution of hair color in students")

"""
