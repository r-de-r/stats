"""

Julia の Clustering.hclust() はデンドログラムを描く機能を持たない。

以下のプログラムは，R の plot() と同じであるが水平方向のデンドログラムを描く。
"""

using Plots
function plot_hclust_horizontal(hc)
    function get(i, x)
        x[i] < 0 && return(ord[abs(x[i])])
        get(x[i], x)
    end
    n = length(hc.order)
    apy = collect(n:-1:1) .+ 0.5
    apx = zeros(n)
    ord = sortperm(hc.order)
    plot(yshowaxis=false, yticks=false, tick_direction=:out, grid=false,
         xlims=(-0.05, maximum(hc.height)), ylims=(0, apy[1]),
         xlabel="height", label="")
    for i in 1:n
        annotate!(0, apy[i], text(string(hc.labels[hc.order[i]]) * " ", 8, :right))
    end
    for i in 1:n-1
        c1 = get(i, hc.merge[:,1])
        c2 = get(i, hc.merge[:,2])
        plot!([apx[c1], hc.height[i], hc.height[i], apx[c2]],
              [apy[c1], apy[c1], apy[c2], apy[c2]], color=:black, label="")
        apx[c1] = apx[c2] = hc.height[i]
        apy[c1] = apy[c2] = (apy[c1] + apy[c2]) / 2
    end
    plot!()
end

"""
使用法

julia> using RDatasets

julia> iris = RDatasets.dataset("datasets", "iris");

julia> function distancematrix(X)
           nr,  nc = size(X)
           d = zeros(nr, nr)
           for i in 1:nr-1
               for j in i+1:nr
                   d[i, j] = d[j, i] = sqrt(sum((X[i, :] .- X[j, :]).^2))
               end
           end
           d
       end;

julia> # using Random; Random.seed!(123) # 毎回同じ結果にするためには乱数の種を設定する
       using Clustering

julia> x = Matrix(iris[1:20, 1:4]);

julia> D = distancematrix(x);

julia> hc = hclust(D, linkage=:ward);

julia> plot_hclust_horizontal(hc)

"""
