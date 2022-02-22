"""
固定書式ファイルからデータフレームへ入力するプログラム

このプログラムを fixedformat.jl という名前で保存しておき，
使用するときに

include("fixedformat.jl")

でインクルードする。



使用法-1

fixedformat(fn; settype=true)

データファイルの 1, 2 行目に読み取り方を示す情報を記述しておく場合

データファイルの1行目に，カンマで区切った変数名
2行目には，読み込む変数の開始桁と変数の型を下記のように指定する
i は整数値 欄内に符号があってもよい
f は実数値 欄内に符号，小数点があってもよい
s は文字列
x は読み飛ばす
文字のある桁位置から次の文字のある桁位置の前までを文字の種類に応じて読む
以下の例では
1〜5   の 5 文字を整数値として読む
6〜13  の 8 文字を実数値として読む
14〜21 の 8 文字を文字列として読む
32〜35 の 4 文字を読み飛ばす...　ことを表している。
データは デフォルトでは 3 行目から
i1, f1, s1, i2, i3, f2
i    f       s       x   i i  f
1234567890123456789012345678901234567890
67897978.7827897289078329738290878696899
7897807890.80780780780780676786767967867

使用例-1-1

include("fixedformat.jl") # include はセッションごとに 1 回でよい
fn = "sample1.dat"
df = fixedformat(fn)

  i1: (i)  1 - 5 [5]
  f1: (f)  6 - 13 [8]
  s1: (s)  14 - 21 [8]
SKIP: (x)  22 - 25 [4]
  i2: (i)  26 - 27 [2]
  i3: (i)  28 - 30 [3]
  f2: (f)  31 - 39 [9]

4 rows × 6 columns

   i1     f1         s1        i2     i3     f2
   Int64  Float64    String    Int64  Int64  Float64
1  12345  6.78901e7  45678901  67     890    1.23457e8
2  67897  978.783    89728907  73     829    8.78697e7
3  78978  7890.8     78078078  67     678    6.76797e8

使用例-1-2

include("fixedformat.jl") # include はセッションごとに 1 回でよい
df = fixedformat(fn, settype=false)

settype=false を指定すると，各列の変数型を Any のままにする。

4 rows × 6 columns

   i1     f1         s1        i2   i3     f2
   Any    Any        Any       Any  Any    Any
1  12345  6.78901e7  45678901  67   890    1.23457e8
2  67897  978.783    89728907  73   829    8.78697e7
3  78978  7890.8     78078078  67   678    6.76797e8

使用法-2

include("fixedformat.jl") # include はセッションごとに 1 回でよい
fixedformat(fn; datarow=1, settype=true, names=String[], begins=Int[], ends=Int[], types=Char[])

変数名 names，開始桁位置 begins，終了桁位置 ends，変数の型 types をベクトルで与える場合

使用例-1 と同じことをするための関数呼び出しを例示する。
なお，上と同じデータファイルを使用する場合は，データの始まる行を datarow で指定しなければならない。
names は "name1" のようなダブルクオートで囲んだ文字列，types は 'i' のような文字型（シングルクオートで囲んだ一文字）で与えることに注意。

df = fixedformat(fn, datarow=3,
    names=["Int1", "Float1", "String", "Int2", "Int3", "Float2"],
    begins=[1, 6, 14, 26, 28, 31],
    ends=[5, 13, 21, 27, 30, 39],
    types=['i', 'f', 's', 'i', 'i', 'f'])

"""

using DataFrames
function getformat(format)
    begins = Int[]
    types  = Char[]
    for (b, t) in enumerate(format)
        isnothing(indexin(t, ['i', 'f', 's', 'x'])[1]) && continue
        append!(begins, b)
        append!(types,  t)
    end
    # println(begins)
    # println(types)
    ends = begins .- 1
    popfirst!(ends)
    push!(ends, length(format))
    (begins, ends, types)
end

function getdata(txt, begins, ends, types)
    data = Any[]
    for (b, e, t) in zip(begins, ends, types)
        if t == 'i'
            append!(data, parse(Int, txt[b:e]))
        elseif t == 'f'
            append!(data, parse(Float64, txt[b:e]))
        elseif t == 's'
            append!(data, [txt[b:e]])
        end
    end
    DataFrame(reshape(data, 1, :), :auto)
end

function fixedformat(fn; datarow=1, settype=true, names=String[], begins=Int[], ends=Int[], types=Char[])
    f = open(fn, "r")
    n = length(names)
    if n == 0
        names = split(readline(f), r"[, ]+")
        format = readline(f)
        # println(names)
        # println(format)
        (begins, ends, types) = getformat(format)
    else
        length(names) == length(begins) == length(ends) == length(types) || return "names, begins, ends, types の要素数が違います"
        for _ in 1:datarow-1
            readline(f)
        end
    end
    n = length(names)
    w = max(maximum(length.(names)), 5)
    j = 0
    for i in 1:length(begins)
        if types[i] != 'x'
            j += 1
            name = ((" " ^ (w)) * names[j])[end-w+1:end]
        else
            name = ((" " ^ (w)) * "SKIP")[end-w+1:end]
        end
        println("$name: ($(types[i]))  $(begins[i]) - $(ends[i]) [$(ends[i] - begins[i] + 1)]")
    end
    df = DataFrame[]
    while (txt = readline(f)) != ""
        if df == []
            df = getdata(txt, begins, ends, types)
            first = false
        else
            append!(df, getdata(txt, begins, ends, types))
        end
        # println(data)
    end
    close(f)
    rename!(df, names)
    settype || return df
    for i in 1:length(names)
        type = typeof(df[1, i])
        df[!, i] = type.(df[:, i])
        # println("$i, $type")
    end
    df
end
