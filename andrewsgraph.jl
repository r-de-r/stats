"""

以下のプログラムを Julia に翻訳してみる。

三角多項式グラフ
http://aoki2.si.gunma-u.ac.jp/R/Andrews.html

使用法

using RDatasets
iris = dataset("datasets", "iris")
y = Matrix(iris[:, 1:4])
andrewsgraph(y)

col = transpose(vcat(fill(1, 50), fill(2, 50), fill(3, 50)))
andrewsgraph(y, normalize=false, col=col)
"""

using Statistics, Plots

function andrewsgraph(dat; normalize=true, points=100, col=1, alpha=0.2)
    data = copy(dat)
    n, nv = size(data)
    if normalize
        means = mean(data, dims=1)
        stds = std(data, dims=1)
        for i = 1:nv
            data[:, i] = (data[:, i] .- means[i]) ./ stds[i]
        end
    end
    θ = range(-π, π, length=points)
    coef = zeros((nv, points))
    for i = 2:nv
        func = i % 2 == 0 ? sin : cos
        coef[i, :] = func.((i ÷ 2) .* θ)
    end
    coef[1, :] = repeat([1/sqrt(2)], points)
    data = transpose(data * coef)
    # pyplot()
    plot(θ, data, color=col, alpha=alpha, grid=false,
            yticks=false, yshowaxis=false, label="")
    xticks!(range(-π, π, length=5), ["-π", "-π/2", "0", "π/2", "π"],
            tick_direction=:out)
end;
