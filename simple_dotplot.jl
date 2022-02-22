"""
ドットプロットでは，データ点が重ならないようにランダムな数値（Jitter）を加えているので，その並びに何らかの意味がありそうに見えてしまう。Python の seaborn にある swarmplot() を Julia から使えるようになっているが，これも同じ特質を持っている。

そのようなことを避けるために
https://blog.goo.ne.jp/r-de-r/e/237f8bdfda925c5d724604aa9eabc8e3
にプログラムを呈示している。
"""

using FreqTables, Plots
function simple_dotplot(x, y; accu=0, stp=0, logflag=false, simple=false,
            symmetrical=true, sizew=600, sizeh=400)
    function logaxis(z)
        pos = zeros(100)
        minval = minimum(z)
        maxval = maximum(z)
        logmaxval = log10(maxval)
        logminval = log10(minval)
        width = logmaxval - logminval
        factor = logmaxval < 3.5 ? 15 : 8
        w = width / factor
        st = floor(logminval)
        delta = 10^st
        ic = 0
        while true
            for i = 1:9
                v = i * delta
                if minval - delta <= v <= maxval + delta
                    if (i == 1 || ic == 0) || (ic > 0 && log10(v) - pos[ic] > w)
                        if i == 1 && ic > 0 && log10(v) - pos[ic] <= w
                            ic -= 1
                        end
                        ic += 1
                        pos[ic] = log10(v)
                        prev = v
                    end
                end
            end
            delta *= 10
            if delta > maxval
                break
            end
        end
        return ic > 3 ? pos[2:ic-1] : [logminval, median([logminval, logmaxval]), logmaxval]
    end
    if logflag == true
        y0 = y
        y = log10.(y);
    end
    minx = minimum(y)
    maxx = maximum(y)
    rng = maxx - minx
    minx = minx - rng * 20 / sizeh
    maxx = maxx + rng * 20 / sizeh
    if accu == 0
        accu = (maxx - minx) / 50
    end
    if stp == 0
        stp = 30 / sizew
    end
    y = round.(y ./ accu, digits=0) * accu
    table = freqtable(y, x)
    yname, xname = names(table)
    nvalue, ngroup = size(table)
    # pyplot()
    p = plot(tick_direction=:out, xticks=false, grid=false,
                size=(sizew, sizeh), xlims = (0, length(xname)+1),
                ylims=(minx, maxx), label="")
    xticks!(1:ngroup, xname)
    for i = 1:ngroup
        for j = 1:nvalue
            if table[j, i] != 0
                n = table[j, i]
                if n == 1
                    height, position = [yname[j]], [i]
                else
                    height = repeat([yname[j]], n)
                    position = collect(range(i-stp*(n-1)/2, i+stp*(n-1)/2, length=n))
                end
                p = scatter!(position, height, labels="", alpha=0.7,
                                markercolor=i, markerstrokecolor=i)
            end
        end
    end
    if logflag
        pos = logaxis(y0)
        yticks!(pos, string.(round.(10 .^ pos, digits = 1)))
    end
    println("accu = $accu, stp = $stp")
    # display(p)
    p
end;

"""
使用法

julia> using RDatasets


julia> airquality = RDatasets.dataset("datasets", "airquality");

julia> x = string.(airquality.Month); # 型変換が必要

julia> y = airquality.Wind;

julia> simple_dotplot(x, y, accu=0.105, stp=0.05)
accu = 0.105, stp = 0.05

"""
