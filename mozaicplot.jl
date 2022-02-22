"""
モザイクプロットは，の帯グラフにおいて，帯の幅をグループの相対度数に反映させたものである。

帯グラフ（積み上げ相対度数分布グラフ）は帯の幅を変えることができないので，以下のような関数を書く。
"""

using FreqTables
using Plots
function mosaicplot(t; xlabel="", ylabel="",
            color=1:size(t, 1), disp=:num, alpha=0.6, plotsize=(400, 400))
      function rect(x, i, y, j, color)
            plot!([x[i], x[i+1], x[i+1], x[i], x[i]],
                  [y[j], y[j], y[j+1], y[j+1], y[j]],
                  seriestype=:shape, linecolor=:yellow,
                  fillcolor=color, alpha=alpha, label="")
      end
      t = reverse(t, dims=1)
      dispt = disp == :num ? t : round.(t ./ sum(t), digits=3)
      rownames, colnames = names(t)
      color = reverse(color)
      nrow, ncol = size(t)
      n = sum(t)
      colsums = vec(sum(t, dims=1));
      colcumsums = cumsum(colsums) ./ n;
      pushfirst!(colcumsums, 0);
      colmid = (colcumsums[1:ncol] .+ colcumsums[2:end]) ./ 2;
      p = plot(grid=false, tick_direction=:out,
            xlabel=xlabel, xlims=(0,1),
            ylabel=ylabel, ylims=(0,1),
            aspect_ratio=1, size=plotsize, label="");
      for col = 1:ncol # col = 1
            x1, x2 = colcumsums[col:col+1]
            rowsums = t[:, col] ./ sum(t[:, col])
            rowcumsums = vec(cumsum(rowsums))
            pushfirst!(rowcumsums, 0)
            rowmid = (rowcumsums[1:end-1] .+ rowcumsums[2:end]) ./ 2
            for row = 1:nrow
                  rect(colcumsums, col, rowcumsums, row, color[row])
                  annotate!(colmid[col], rowmid[row],
                        text("$(colnames[col])\n$(rownames[row])\n$(dispt[row, col])", :white, 8,),
                        label="")
            end
      end
      display(p)
end

"""
使用例

てんとう虫の住んでいる場所と色についてのデータをモザイクプロットで描いてみる。

ladybirds_morph_colour.csv
https://github.com/R4All/datasets/blob/master/ladybirds_morph_colour.csv

julia> io = IOBuffer("""
           Habitat,Site,morph_colour,number
           Rural,R1,black,10
           Rural,R2,black,3
           Rural,R3,black,4
           Rural,R4,black,7
           Rural,R5,black,6
           Rural,R1,red,15
           Rural,R2,red,18
           Rural,R3,red,9
           Rural,R4,red,12
           Rural,R5,red,16
           Industrial,U1,black,32
           Industrial,U2,black,25
           Industrial,U3,black,25
           Industrial,U4,black,17
           Industrial,U5,black,16
           Industrial,U1,red,17
           Industrial,U2,red,23
           Industrial,U3,red,21
           Industrial,U4,red,9
           Industrial,U5,red,15""")
IOBuffer(data=UInt8[...], readable=true, writable=false, seekable=true, append=false, size=416, maxsize=Inf, ptr=1, mark=-1)

julia> using CSV, DataFrames, FreqTables

julia> dat = CSV.read(io, DataFrame);

julia> table = freqtable(dat.morph_colour, dat.Habitat, weights=dat.number)
2×2 Named Matrix{Int64}
Dim1 ╲ Dim2 │ "Industrial"       "Rural"
────────────┼───────────────────────────
"black"     │          115            30
"red"       │           85            70

julia> mosaicplot(table; xlabel="Havitat", ylabel="morph_colour", color=[:black, :red])
"""
