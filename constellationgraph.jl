"""

以下のプログラムを Julia に翻訳してみる。

星座グラフ
http://aoki2.si.gunma-u.ac.jp/R/Constellation.html

using RDatasets
iris = dataset("datasets", "iris")
dat = Matrix(iris[:, 1:4])
col = vcat(fill(1, 50), fill(2, 50), fill(3, 50))
constellationgraph(dat, col=col)

"""

using Statistics, Plots

function constellationgraph(dat; w=0, points=100, col=1, alpha=0.2)
    if w == 0
        nv = size(dat, 2)
        w = fill(1/nv, nv)
    end
    mx = maximum(dat, dims=1)
    mn = minimum(dat, dims=1)
    rg = mx-mn
    dat = π .* (dat .- mn) ./ rg
    y = sin.(dat) * w
    x = cos.(dat) * w
    pyplot()
    scatter(x, y, color=col, alpha=alpha, aspect_ratio=1,
            xlims=(-1.05, 1.05), ylims=(0, 1.05), grid=false,
            yticks=false, yshowaxis=false, label="")
    θ = range(0, π, length=points)
    plot!(cos.(θ), sin.(θ), color=:black, label="", linewidth=0.5)
    xticks!([-1, 0, 1], tick_direction=:out)
end
