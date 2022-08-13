"""
以下のプログラムを Julia に翻訳してみる。

レーダーチャート
http://aoki2.si.gunma-u.ac.jp/R/radar.html

使用例

using RDatasets
swiss = dataset("datasets", "swiss")
test = swiss[1:5, 2:7]
radar(test)
radar(test, col=[:black, :red, :green4, :blue, :brown])
radar(test, maxx=[100, 50, 20, 20, 100, 25], normalize=false,
        col=[:black, :red, :green4, :blue, :brown])
radar(test, maxx=[100, 50, 20, 20, 100, 25],
        minx=[70, 10, 0, 0, 0, 20], normalize=false,
        col=[:black, :red, :green4, :blue, :brown])
radar(test, maxx=100, minx=0, normalize=false,
        col=[:black, :red, :green4, :blue, :brown])

"""

using Statistics, Plots

function radar(df; maxx=Inf, minx=Inf, normalize=true, col="", lty="", title="")
    function drawnet(x, border, lty)
        scale = (x .- minx) ./ (maxx .- minx)
        scale = vcat(scale, scale[1])
        if all(0 .< scale .<= 1.2)
            plot!(vcat(cosine, cosine[1]).*scale, vcat(sine, sine[1]).*scale,
                  seriestype=:path, label="", linecolor=border, linestyle=lty)
        end
    end
    # pyplot()
    axisname = names(df)
    df = Matrix(df)
    n, m = size(df)
    m >= 3 || error("3変数以上であるべし！")
    p = plot(xlimit=(-1.4, 1.4), ylimit=(-1.2, 1.2), aspect_ratio=1, axis=false,
             ticks=false, xlabel="", ylabel="", title=title, size=(600, 400))
    θ = π .*(0.5 .- collect(0:m-1) .* 2 ./ m)
    cosine = cos.(θ)
    sine = sin.(θ)
    if normalize
        means = mean(df, dims=1)
        stds = std(df, dims=1)
        for i = 1:m
            df[:, i] = (df[:, i] .- means[i]) ./ stds[i]
        end
        maxx = maximum(df)
        minx = minimum(df)
        w = (maxx - minx) * 0.1
        maxx = maxx + w
        minx = minx - w
        for i = -3:3
            x = fill(i, m)
            drawnet(x, :gray, i==0 ? :solid : :dot)
        end
    else
        maxx != Inf || (maxx = vec(maximum(df, dims=1)))
        minx != Inf || (minx = vec(minimum(df, dims=1)))
        w = (maxx - minx) * 0.1
        maxx = maxx + w
        minx = minx - w
        for i = 1:5
            x = cosine * i / 5
            y = sine * i / 5
            plot!(vcat(x, x[1]), vcat(y, y[1]), seriestype=:path,
                    linecolor=:gray, linestyle=:dot, label="")
        end
    end
    for i = 1:m
        plot!([0, cosine[i]*1.05], [0, sine[i]*1.05], seriestype=:path,
                color=:gray, label="")
        annotate!(cosine[i]*1.1, sine[i]*1.1, text(axisname[i], 10,
                i > m/2 ? :right : :left))
    end
    col != "" || (col = fill(:red, m))
    lty != "" || (lty = fill(:solid, m))
    for i = 1:n
        drawnet(df[i, :], col[i], lty[i])
    end
    display(p)
end
