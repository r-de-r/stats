using Plots, FreqTables, CategoricalArrays

function sunflowerplot(x::AbstractVector{T}, y::AbstractVector{T};
        initialize=true, r=0, color=:black, rotate=false, title="", xlabel="", ylabel="") where T<:Real
    function petals(x, y, n, r, color, rotate)
        δ = rotate ? 180rand(1)[1] : 0
        for θ in 90+δ:(360/n):450+δ
            plot!([x, x + r*cosd(θ)], [y, y + r*sind(θ)], color=color, linewidth=2)
        end
    end
    gr(label="", grid=false, tick_direction=:out,
        markerstrokewidth=0, aspect_ratio=1)
    r == 0 && (r = min(diff(vcat(extrema(x)...)), diff(vcat(extrema(y)...)))[1]/40)
    tbl = freqtable(x, y)
    xval, yval = names(tbl)
    nx, ny = size(tbl)
    initialize && (p = plot())
    p = plot!(title=title, xlabel=xlabel, ylabel=ylabel)
    for i in 1:nx
        for j in 1:ny
            n = tbl[i, j]
            if n == 1
                scatter!([xval[i]], [yval[j]], color=color, markersize=3)
            elseif n != 0
                scatter!([xval[i]], [yval[j]], color=color, markersize=2)
                 n > 1 && petals(xval[i], yval[j], n, r, color, rotate)
            end
        end
    end
    r
    p
end
