# Julia で統計解析　第 9 章　関数


```julia
Version()
```

    最新バージョン 2024-07-18 11:16


統計解析を行う上で，ファイルからデータフレームに読み込んだ変数をそのまま使うということは意外と少ない。データフレームの変数を変換したり，新たな変数を作成したりという作業が必要である。そのような場合に，四則演算などの演算子や平方根を取る関数 `sqrt()` や対数を取る関数 `log()` などの基本的数学関数以外にも様々な関数がある。

## データの種類

### 定数

#### 数学定数

- **円周率**は  REPL 環境では `\` `p` `i` `tabキー` で入力できる。


```julia
π
```




    π = 3.1415926535897...



`1π` は数学的には `π` と同じであるが，Julia では `1π` は倍精度実数（Float64）であり，単に `π` と書いたときとは表示が異なる。


```julia
1π
```




    3.141592653589793




```julia
typeof(1π)
```




    Float64



`π` の型は `Irrational{:π}` である。


```julia
typeof(π)
```




    Irrational{:π}



Julia には，任意の精度の浮動小数点型 `BigFloat` がある。デフォルトでは 256 ビット実数なので，有効桁数はほぼ 77 桁である（実際には 79 桁が表示されるが）。

これを用いて `π` を型変換して表示してみると，以下のようになる。


```julia
BigFloat(π)
```




    3.141592653589793238462643383279502884197169399375105820974944592307816406286198



1000 ビット実数に設定すると，有効桁数が 1000*log10(2)≒301 桁になる（実際には 302 桁が表示される）。


```julia
setprecision(BigFloat, 1000) # 精度を 1000 ビットにする。
BigFloat(π)
```




    3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412736



`π` の入力が面倒だと言う人は，`pi` と書いても同じである。


```julia
pi # π と同じ
```




    π = 3.1415926535897...



- **ネイピア数**は REPL 環境では `\` `e` `u` `l` `e` `r` `tabキー` で入力できる。


```julia
ℯ
```




    ℯ = 2.7182818284590...




```julia
typeof(ℯ)
```




    Irrational{:ℯ}



円周率と同じで，ℯ の型は `Irrational{:ℯ}` である。

#### 自分で定義する定数

定数はプログラム中で一定不変の値を持つものとして定義できる。普通の変数なら間違えて変更してしまうことがあるが，定数は変更すると警告が出る。警告は出るが，実行はされるので注意が必要である。

このようなことから，定数は大文字で指定するのが慣例である。


```julia
const YEAR = 2020
YEAR += 1 # 実行されるが，警告が出る
YEAR
```

    WARNING: redefinition of constant Main.YEAR. This may fail, cause incorrect answers, or produce other errors.





    2021



### 数

#### 整数

整数の型は数種類ある。

もっとも一般的に使われるのが `Int64` で，-9223372036854775808 から 9223372036854775807 の整数を表すことができるので，大概の用に間に合う。

もっと広い範囲の値を扱う必要がある場合には `Int128`， `BigInt` が使える。


```julia
(2, typeof(2))
```




    (2, Int64)




```julia
typeof(12345678900000000000000)
```




    Int128




```julia
typeof(123456789000000000000000000000000000000000000000000)
```




    BigInt



■ 整数の型と値の範囲


```julia
for T in [Int8,Int16,Int32,Int64,Int128,UInt8,UInt16,UInt32,UInt64,UInt128]
    println("$(lpad(T,7)): [$(typemin(T)),$(typemax(T))]")
end
```

       Int8: [-128,127]
      Int16: [-32768,32767]
      Int32: [-2147483648,2147483647]
      Int64: [-9223372036854775808,9223372036854775807]
     Int128: [-170141183460469231731687303715884105728,170141183460469231731687303715884105727]
      UInt8: [0,255]
     UInt16: [0,65535]
     UInt32: [0,4294967295]
     UInt64: [0,18446744073709551615]
    UInt128: [0,340282366920938463463374607431768211455]


#### 実数（浮動小数点数）

実数は `Float64` 型が一般的に使われる。


```julia
(2.0, typeof(2.0))
```




    (2.0, Float64)



64 ビット実数とも呼ばれるが，数を表すのには 64 ビットのうちの 52 ビットが仮数部として使われる。細かいことをいえば，52 ビットの上に暗黙の 1 ビットがあると仮定するので，有効桁数は `53*log10(2)≒15.9546` で，実質 16 桁と思っておけばよい。


```julia
4503599627370496.0, 4503599627370497.0, 9007199254740991.0, 9007199254740992.0 # 正確に表現できる最大数
```




    (4.503599627370496e15, 4.503599627370497e15, 9.007199254740991e15, 9.007199254740992e15)




```julia
4503599627370496.0, 4503599627370496.1, 4503599627370496.2, 4503599627370496.3 # 区別できない
```




    (4.503599627370496e15, 4.503599627370496e15, 4.503599627370496e15, 4.503599627370496e15)



最小の精度は `1/(2^52)≒2.220446049250313e-16` で，この値のことを Machine epsilon という。2つの実数の差がこの値より大きければ，2つの実数として扱われることになる。


```julia
2^-52, eps(1.0), eps(Float64) # Machine epsilon
```




    (2.220446049250313e-16, 2.220446049250313e-16, 2.220446049250313e-16)



いろいろ細かいことはあるが，**2 進数ベースのコンピュータで扱える浮動小数点数は，近似値である**ということを肝に銘じておくことが肝心だ。

64 ビットのうちの残り 11 ビットは バイアスのある指数部（符号なし整数）と 1 ビットの符号である。

これらを併せて $\text{符号}\times\text{仮数部}\times2^{\text{指数部−1023}}$ で数を表す。

より詳しくは，Wikipedia の[倍精度浮動小数点数](https://ja.wikipedia.org/wiki/%E5%80%8D%E7%B2%BE%E5%BA%A6%E6%B5%AE%E5%8B%95%E5%B0%8F%E6%95%B0%E7%82%B9%E6%95%B0) を参照する。

`Float64` は `Inf`，`-Inf`，`NaN`, `missing` という特別な値を持つことができる。


```julia
Inf, -Inf, NaN, missing
```




    (Inf, -Inf, NaN, missing)



これらは，相互の演算において厄介な振る舞いを見せるので注意が必要である。


```julia
NaN == NaN, isnan(NaN)
```




    (false, true)




```julia
missing == missing, ismissing(missing)
```




    (missing, true)




```julia
NaN ==  missing
```




    missing




```julia
3 + NaN, 4 * missing
```




    (NaN, missing)



#### 虚数

- 定数

虚数の記述法は言語によって異なる。Julia では`実部 ± 虚部im` である。


```julia
7 + 2im, typeof(7 + 2im)
```




    (7 + 2im, Complex{Int64})




```julia
7.1 + 2.2im, typeof(7.1 + 2.2im)
```




    (7.1 + 2.2im, ComplexF64)



- `complex(x)` 実部が `x` の複素数を作る。


```julia
x = 1.2
complex(x)
```




    1.2 + 0.0im



- `complex(x)` 実部が `x`，虚部が `y` の複素数を作る。


```julia
x = 1.2; y = 3.6
complex(x, y) # x + y im などと書くことはできない
```




    1.2 + 3.6im



- 複素数 `z` の実部を返す。


```julia
z = 7.1 + 2.2im
real(z)
```




    7.1



- 複素数 `z` の虚部を返す。


```julia
imag(z)
```




    2.2



- 複素数 `z` の共役複素数を返す。


```julia
conj(z)
```




    7.1 - 2.2im



- 複素数 `z` の絶対値を返す。`abs(z) ≡ sqrt(real(z)^2 + imag(z)^2)`


```julia
abs(z)
```




    7.433034373659252



- 複素数 `z` の絶対値の ２ 乗を返す。`abs(z) ≡ real(z)^2 + imag(z)^2`


```julia
abs2(z)
```




    55.25



- 複素数 `z` の偏角 `∠z` をラジアンで返す。結果(値域)は `−π` から `π` である。


```julia
z = complex(-1/2, sqrt(3)/2)
angle(z)
```




    2.0943951023931957



### タプル

タプルは複数の要素をカンマで区切り，全体を `( )` で囲んだものである。

#### 空のタプル


```julia
t = ()
```




    ()



#### タプルを定義する


```julia
t = (1, 2, 3)
typeof(t)
```




    Tuple{Int64, Int64, Int64}



要素は様々な型が混在していてかまわない。


```julia
nt = (a = 1, b = "foo", c = 3.14, d = 'x')
nt |> println
```

    (a = 1, b = "foo", c = 3.14, d = 'x')


なお，要素が 1 個の場合には要素の後に `,` が必要である。


```julia
(24,)
```




    (24,)



#### タプルの要素の参照

要素は様々な方法で参照できる。


```julia
nt[1]
```




    1




```julia
nt.b
```




    "foo"




```julia
nt[:c]
```




    3.14



ただし，代入はできない（イミュータブルと言われる）。


```julia
# nt[2] = 5 　　MethodError になる
```

#### タプルを対象とする関数


```julia
keys(nt) # キーのリスト
```




    (:a, :b, :c, :d)




```julia
values(nt) # 値のリスト
```




    (1, "foo", 3.14, 'x')




```julia
isempty(nt) # 空か?
```




    false




```julia
length(nt) # 長さ（要素数）
```




    4



### ベクトル

#### 空ベクトル

空ベクトルは `[]` で定義できるが，型が決められるならば型を指定する。


```julia
[], Int[], Float64[], String[], Char[]
```




    (Any[], Int64[], Float64[], String[], Char[])



#### 行ベクトル

実は 1×n 行列である。空白で要素を区切り `[ ]` で囲む。


```julia
[1 2 3 4 5]
```




    1×5 Matrix{Int64}:
     1  2  3  4  5



#### 列ベクトル

カンマまたはセミコロンで要素を区切り `[ ]` で囲む。


```julia
[2, 4, 6]
```




    3-element Vector{Int64}:
     2
     4
     6




```julia
[2; 4; 6]
```




    3-element Vector{Int64}:
     2
     4
     6



ベクトルの要素は任意の型が混在していてかまわない。それぞれの要素を `,` で区切って全体を `[ ]` で囲む。


```julia
[1, 2.0, "abc", 'x'] |> println
```

    Any[1, 2.0, "abc", 'x']


#### 整数ゼロベクトル


```julia
repeat([0], 3) |> println
```

    [0, 0, 0]



```julia
fill(0, 3) |> println
```

    [0, 0, 0]



```julia
zeros(Int, 3) |> println
```

    [0, 0, 0]


#### 実数ゼロベクトル


```julia
repeat([0.0], 3) |> println
```

    [0.0, 0.0, 0.0]



```julia
fill(0.0, 3) |> println
```

    [0.0, 0.0, 0.0]



```julia
zeros(3) |> println
```

    [0.0, 0.0, 0.0]


#### 整数 1 ベクトル


```julia
repeat([1], 3) |> println
```

    [1, 1, 1]



```julia
fill(1, 3) |> println
```

    [1, 1, 1]



```julia
ones(Int, 3) |> println
```

    [1, 1, 1]


#### 実数 1 ベクトル


```julia
repeat([1.0], 3) |> println
```

    [1.0, 1.0, 1.0]



```julia
fill(1.0, 3) |> println
```

    [1.0, 1.0, 1.0]



```julia
ones(3) |> println
```

    [1.0, 1.0, 1.0]


#### 論理 trues ベクトル


```julia
trues(5) |> println
```

    Bool[1, 1, 1, 1, 1]



```julia
fill(true, 5) |> println
```

    Bool[1, 1, 1, 1, 1]


#### 論理 falses ベクトル


```julia
falses(5) |> println
```

    Bool[0, 0, 0, 0, 0]



```julia
fill(false, 5) |> println
```

    Bool[0, 0, 0, 0, 0]


#### 等差ベクトル

初項 $a$，公差 $b$，最終項 $c$ の等差ベクトル `collect(a:b:c)`


```julia
Vector(1:5) |> println 
```

    [1, 2, 3, 4, 5]



```julia
collect(1:5) |> println
```

    [1, 2, 3, 4, 5]



```julia
[1:5;] |> println
```

    [1, 2, 3, 4, 5]



```julia
[1:5] |> println
```

    UnitRange{Int64}[1:5]



```julia
(1:5) |> println
```

    1:5



```julia
collect(10:1:15) |> println
```

    [10, 11, 12, 13, 14, 15]



```julia
collect(1:2:10) |> println
```

    [1, 3, 5, 7, 9]



```julia
collect(8:-2:0) |> println
```

    [8, 6, 4, 2, 0]



```julia
collect(0:0.1:0.5) |> println
```

    [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]


初項 $a$ ，公差 $b$ ，項数 $n$ の等差ベクトル


```julia
a, b, n = 25, 5, 10
collect(range(a, step=b, length=n)) |> println
```

    [25, 30, 35, 40, 45, 50, 55, 60, 65, 70]


#### 等比ベクトル

初項 $a$，公比 $b$，項数 $n$ の等比ベクトル


```julia
a, b, n = 1, 1.1, 5
a .* b .^ collect(1:n) |> println
```

    [1.1, 1.2100000000000002, 1.3310000000000004, 1.4641000000000004, 1.6105100000000006]


#### 要素の参照

要素の参照は，1 〜 `length(x)` の値を取る添字式で行う。なお，`length(x)` を `end` で表すことができる。


```julia
x = collect(1:10)
x[1], x[end], x[end-2] # 先頭，末尾，末尾の 2 つ前を参照する
```




    (1, 10, 8)




```julia
x[iseven.(x)] |> println # true に対応する要素を参照する
```

    [2, 4, 6, 8, 10]



```julia
x[1:2:10] |> println # 1 から 2 刻みで 10 までを参照する
```

    [1, 3, 5, 7, 9]



```julia
x[3:8] |> println # 3 から 8 までを参照する
```

    [3, 4, 5, 6, 7, 8]


#### ベクトルを対象とする関数


```julia
a = [1, 2, 3]
length(a) # 長さ
```




    3




```julia
isempty(a) # 空か？
```




    false




```julia
empty!(a) # 空にする
```




    Int64[]




```julia
a = [1, 2, 3]
pushfirst!(a, 0) |> println # 先頭に要素を追加する
```

    [0, 1, 2, 3]



```julia
a = [1, 2, 3]
x = popfirst!(a) # 先頭の要素を取り出す
x |> println
a |> println
```

    1
    [2, 3]



```julia
a = [1, 2, 3]
push!(a, 99) |> println # 先頭の要素を取り出す
```

    [1, 2, 3, 99]



```julia
a = [1, 2, 3]
pop!(a) |> println # 先頭の要素を取り出す
a |> println
```

    3
    [1, 2]



```julia
a = [1, 2, 3]
popat!(a, 2) # 先頭の要素を取り出す
a |> println
```

    [1, 3]



```julia
a = [1, 2, 3]
insert!(a, 2, 44) # 先頭の要素を取り出す
a |> println
```

    [1, 44, 2, 3]



```julia
a = [1, 2, 3]
deleteat!(a, 3) # 先頭の要素を取り出す
a |> println
```

    [1, 2]



```julia
a = [1,2,3]
b = [10,20,30]
[a; b] |> println # ベクトルの後ろにベクトルを連結する
```

    [1, 2, 3, 10, 20, 30]



```julia
vcat(a, b) |> println # ベクトルの後ろにベクトルを連結する
```

    [1, 2, 3, 10, 20, 30]



```julia
cat(a, b, dims=1) |> println # ベクトルの後ろにベクトルを連結する
```

    [1, 2, 3, 10, 20, 30]



```julia
hcat(a, b) # 縦ベクトルを横方向に連結する
```




    3×2 Matrix{Int64}:
     1  10
     2  20
     3  30




```julia
cat(a, b, dims=2) # 縦ベクトルを横方向に連結する
```




    3×2 Matrix{Int64}:
     1  10
     2  20
     3  30



`cat()` で長さの異なるベクトルを `dims=2` で連結すると `1 × n` 行列になる


```julia
x = [1 2 3]
y = [4 5 6 7]
cat(x, y, dims=2) # 
```




    1×7 Matrix{Int64}:
     1  2  3  4  5  6  7




```julia
vec1 = collect(1:6) # ベクトル
vec1 |> println
reshape(vec1, 2, 3) # 2 × 3 行列に変換
```

    [1, 2, 3, 4, 5, 6]





    2×3 Matrix{Int64}:
     1  3  5
     2  4  6




```julia
reshape(vec1, (2, 3)) # 次元をタプルで指定してもよい
```




    2×3 Matrix{Int64}:
     1  3  5
     2  4  6




```julia
reshape(vec1, 2, :) # `:` の次元は自動的に計算される
```




    2×3 Matrix{Int64}:
     1  3  5
     2  4  6




```julia
reshape(vec1, 6, :) # 6 × 1 行列
```




    6×1 Matrix{Int64}:
     1
     2
     3
     4
     5
     6



### 行列

#### 整数ゼロ行列


```julia
zeros(Int, 2, 3)
```




    2×3 Matrix{Int64}:
     0  0  0
     0  0  0




```julia
fill(0, 2, 3)
```




    2×3 Matrix{Int64}:
     0  0  0
     0  0  0



#### 実数ゼロ行列


```julia
zeros(2, 3)
```




    2×3 Matrix{Float64}:
     0.0  0.0  0.0
     0.0  0.0  0.0




```julia
fill(0.0, 2, 3)
```




    2×3 Matrix{Float64}:
     0.0  0.0  0.0
     0.0  0.0  0.0



#### 整数 1 行列


```julia
ones(Int, 2, 3)
```




    2×3 Matrix{Int64}:
     1  1  1
     1  1  1




```julia
fill(1, 2, 3)
```




    2×3 Matrix{Int64}:
     1  1  1
     1  1  1



#### 実数 1 行列


```julia
ones(2, 3)
```




    2×3 Matrix{Float64}:
     1.0  1.0  1.0
     1.0  1.0  1.0




```julia
fill(1.0, 2, 3)
```




    2×3 Matrix{Float64}:
     1.0  1.0  1.0
     1.0  1.0  1.0



#### 論理 trues 行列


```julia
trues(2, 3)
```




    2×3 BitMatrix:
     1  1  1
     1  1  1




```julia
fill(true, 2, 3)
```




    2×3 Matrix{Bool}:
     1  1  1
     1  1  1



#### 論理 falses 行列


```julia
falses(2, 3)
```




    2×3 BitMatrix:
     0  0  0
     0  0  0




```julia
fill(false, 2, 3)
```




    2×3 Matrix{Bool}:
     0  0  0
     0  0  0



#### 単位行列


```julia
using LinearAlgebra
Array{Int}(I, 3, 3)
```




    3×3 Matrix{Int64}:
     1  0  0
     0  1  0
     0  0  1




```julia
Array{Int}(I, 2, 3)
```




    2×3 Matrix{Int64}:
     1  0  0
     0  1  0




```julia
Array{Float64}(I, 3, 3)
```




    3×3 Matrix{Float64}:
     1.0  0.0  0.0
     0.0  1.0  0.0
     0.0  0.0  1.0




```julia
Array{Bool}(I, 3, 3)
```




    3×3 Matrix{Bool}:
     1  0  0
     0  1  0
     0  0  1



#### 対角行列


```julia
diagm(0 => 1:3)
```




    3×3 Matrix{Int64}:
     1  0  0
     0  2  0
     0  0  3




```julia
Diagonal([1,2,3])
```




    3×3 Diagonal{Int64, Vector{Int64}}:
     1  ⋅  ⋅
     ⋅  2  ⋅
     ⋅  ⋅  3



対角要素の n 上


```julia
diagm(1 => 1:3)
```




    4×4 Matrix{Int64}:
     0  1  0  0
     0  0  2  0
     0  0  0  3
     0  0  0  0



対角要素の n 下


```julia
diagm(-2 => 1:3)
```




    5×5 Matrix{Int64}:
     0  0  0  0  0
     0  0  0  0  0
     1  0  0  0  0
     0  2  0  0  0
     0  0  3  0  0



複数指定可能


```julia
diagm(-1 => 1:3, 1 => [10, 20, 30, 40])
```




    5×5 Matrix{Int64}:
     0  10   0   0   0
     1   0  20   0   0
     0   2   0  30   0
     0   0   3   0  40
     0   0   0   0   0



#### 行列を対象とする関数


```julia
a = zeros(10, 5);
size(a), size(a, 1), size(a, 2) # 行列のサイズ
```




    ((10, 5), 10, 5)




```julia
length(a) # 行列の要素数
```




    50




```julia
ndims(a) # 行列の次元数
```




    2




```julia
using LinearAlgebra
a = [1 2 3; 4 5 6; 7 8 9]
Base.print_matrix(stdout, a, "", " ", "\n\n")
diag(a) |> println # 対角要素の取り出し
```

    1 2 3
    4 5 6
    7 8 9
    
    [1, 5, 9]



```julia
diag(a, 1) |> println # 対角要素より n 上
```

    [2, 6]



```julia
diag(a, -1) |> println # 対角要素より n 下
```

    [4, 8]



```julia
tr(a), sum(diag(a)) # トレース（対角成分の和）
```




    (15, 15)




```julia
a[triu(trues(size(a)))] |> println # 上三角要素の取り出し
```

    [1, 2, 5, 3, 6, 9]



```julia
a[triu(trues(size(a)), 1)] |> println
```

    [2, 3, 6]



```julia
UpperTriangular(a)
```




    3×3 UpperTriangular{Int64, Matrix{Int64}}:
     1  2  3
     ⋅  5  6
     ⋅  ⋅  9




```julia
a[tril(trues(size(a)))] |> println # 下三角要素の取り出し
```

    [1, 4, 7, 5, 8, 9]



```julia
a[tril(trues(size(a)), -2)] |> println
```

    [7]



```julia
LowerTriangular(a)
```




    3×3 LowerTriangular{Int64, Matrix{Int64}}:
     1  ⋅  ⋅
     4  5  ⋅
     7  8  9




```julia
transpose(a) # 転置
```




    3×3 transpose(::Matrix{Int64}) with eltype Int64:
     1  4  7
     2  5  8
     3  6  9




```julia
a' # 転置
```




    3×3 adjoint(::Matrix{Int64}) with eltype Int64:
     1  4  7
     2  5  8
     3  6  9




```julia
rotr90(a) # 90度右回転
```




    3×3 Matrix{Int64}:
     7  4  1
     8  5  2
     9  6  3




```julia
rotl90(a) # 90度左回転
```




    3×3 Matrix{Int64}:
     3  6  9
     2  5  8
     1  4  7




```julia
rotl90(rotl90(a)) # 90度左回転，90度左回転 == rotl90(a, 2)
```




    3×3 Matrix{Int64}:
     9  8  7
     6  5  4
     3  2  1




```julia
rotl90(rotl90(rotl90(a))) # 90度左回転，90度左回転，90度左回転  == rotl90(a, 3)
```




    3×3 Matrix{Int64}:
     7  4  1
     8  5  2
     9  6  3




```julia
rotl90(rotl90(rotl90(rotl90(a)))) # 90度左回転，90度左回転，90度左回転，90度左回転
```




    3×3 Matrix{Int64}:
     1  2  3
     4  5  6
     7  8  9




```julia
rot180(a) # 180度回転
```




    3×3 Matrix{Int64}:
     9  8  7
     6  5  4
     3  2  1




```julia
A = round.(rand(3, 3), digits=3)
```




    3×3 Matrix{Float64}:
     0.602  0.566  0.937
     0.388  0.194  0.38
     0.605  0.077  0.005




```julia
vec(A) |> println # 行列をベクトルに変換する
```

    [0.602, 0.388, 0.605, 0.566, 0.194, 0.077, 0.937, 0.38, 0.005]



```julia
A[:] |> println # 行列をベクトルに変換する
```

    [0.602, 0.388, 0.605, 0.566, 0.194, 0.077, 0.937, 0.38, 0.005]


#### 線形代数

##### ランク


```julia
A = [1.0 3.0 5.0; 6.0 8.0 3.0; 3.0 4.0 2.0];
rank(A) # ランク
```




    3



##### 行列式


```julia
A = [1.0 3.0 5.0; 6.0 8.0 3.0; 3.0 4.0 2.0];
det(A) # 行列式
```




    -5.0



##### 逆行列


```julia
A = [1.0 3.0 5.0; 6.0 8.0 3.0; 3.0 4.0 2.0]
inv(A) # 逆行列
```




    3×3 Matrix{Float64}:
     -0.8  -2.8   6.2
      0.6   2.6  -5.4
      0.0  -1.0   2.0




```julia
A * inv(A)
```




    3×3 Matrix{Float64}:
     1.0  -8.88178e-16  0.0
     0.0   1.0          0.0
     0.0   0.0          1.0



##### 連立方程式 $A x = b$ を解く


```julia
A = [1.0 3.0 5.0; 6.0 8.0 3.0; 3.0 4.0 2.0];
b = [3, 4, 6]
A \ b |> println
```

    [23.599999999999998, -20.2, 8.0]



```julia
inv(A) * b |> println # これはお勧めではない
```

    [23.599999999999994, -20.199999999999996, 8.0]


##### 固有値，固有ベクトル


```julia
a = [3 1; 2 4;]
F = eigen(a)
F.values  |> println
F.vectors 
```

    [2.0, 5.0]





    2×2 Matrix{Float64}:
     -0.707107  -0.447214
      0.707107  -0.894427



固有値の大きい順に並べ替える


```julia
eigenvalues, eigenvectors = eigen(a, sortby=x-> -x)
```




    Eigen{Float64, Float64, Matrix{Float64}, Vector{Float64}}
    values:
    2-element Vector{Float64}:
     5.0
     2.0
    vectors:
    2×2 Matrix{Float64}:
     -0.447214  -0.707107
     -0.894427   0.707107



一般的な行列の場合の LU 分解


```julia
a = [3 1; 2 4;]
F = factorize(a);
```


```julia
F.L
```




    2×2 Matrix{Float64}:
     1.0       0.0
     0.666667  1.0




```julia
F.U
```




    2×2 Matrix{Float64}:
     3.0  1.0
     0.0  3.33333



対称行列の場合


```julia
B = [1.5 2 -4; 2 -1 -3; -4 -3 5]
```




    3×3 Matrix{Float64}:
      1.5   2.0  -4.0
      2.0  -1.0  -3.0
     -4.0  -3.0   5.0




```julia
F = factorize(B)
```




    BunchKaufman{Float64, Matrix{Float64}, Vector{Int64}}
    D factor:
    3×3 Tridiagonal{Float64, Vector{Float64}}:
     -1.64286   0.0   ⋅ 
      0.0      -2.8  0.0
       ⋅        0.0  5.0
    U factor:
    3×3 UnitUpperTriangular{Float64, Matrix{Float64}}:
     1.0  0.142857  -0.8
      ⋅   1.0       -0.6
      ⋅    ⋅         1.0
    permutation:
    3-element Vector{Int64}:
     1
     2
     3



##### 特異値分解 SVD singular value decomposition


```julia
A = randn(3, 3)

using LinearAlgebra
U, S, V = LinearAlgebra.svd(A)
```




    SVD{Float64, Float64, Matrix{Float64}, Vector{Float64}}
    U factor:
    3×3 Matrix{Float64}:
     -0.429363  -0.199865   0.880739
     -0.874135  -0.153165  -0.4609
      0.227017  -0.967778  -0.108946
    singular values:
    3-element Vector{Float64}:
     1.8582231436918584
     0.8008048726012724
     0.12184918481431992
    Vt factor:
    3×3 Matrix{Float64}:
     0.156361  -0.707836    -0.688853
     0.151543   0.706367    -0.691434
     0.976005   0.00372246   0.217715



##### QR 分解


```julia
qr(A)
```




    LinearAlgebra.QRCompactWY{Float64, Matrix{Float64}, Matrix{Float64}}
    Q factor: 3×3 LinearAlgebra.QRCompactWYQ{Float64, Matrix{Float64}, Matrix{Float64}}
    R factor:
    3×3 Matrix{Float64}:
     0.336588  -0.931314  -1.29523
     0.0        1.08752    0.150984
     0.0        0.0        0.495351



##### コレスキー分解


```julia
using Statistics
r = cor(rand(10, 3))
```




    3×3 Matrix{Float64}:
      1.0        0.355344  -0.469512
      0.355344   1.0       -0.184936
     -0.469512  -0.184936   1.0




```julia
c = cholesky(r)
```




    Cholesky{Float64, Matrix{Float64}}
    U factor:
    3×3 UpperTriangular{Float64, Matrix{Float64}}:
     1.0  0.355344  -0.469512
      ⋅   0.934736  -0.0193614
      ⋅    ⋅         0.882714




```julia
c.U
```




    3×3 UpperTriangular{Float64, Matrix{Float64}}:
     1.0  0.355344  -0.469512
      ⋅   0.934736  -0.0193614
      ⋅    ⋅         0.882714




```julia
c.U * rand(3, 3)
```




    3×3 Matrix{Float64}:
     -0.0133188  0.319893  1.13218
      0.40984    0.676506  0.403429
      0.88051    0.419873  0.00384122



### 集合

#### 空集合


```julia
s1 = Set()
```




    Set{Any}()




```julia
s2 = Set([])
```




    Set{Any}()




```julia
s1 == s2 # どちらの定義でも同じ
```




    true



#### 集合を定義する

集合の要素は任意の型が混在していてかまわない。ユニークな要素で構成される。要素の順序は不定である。


```julia
a = Set([1, 2, 1, "abc", 1.3, 'x'])
a |> println
```

    Set(Any["abc", 1.3, 2, 'x', 1])



```julia
b = Set([2,1,3,4,2,5,2]) |> println
```

    Set([5, 4, 2, 3, 1])


#### 集合を対象にする関数


```julia
s = Set()
push!(s, "a")    # 要素の追加
push!(s, 2, 3.5)
s |> println
```

    Set(Any[2, 3.5, "a"])



```julia
in("b", s), in(3.5, s) # 要素に含まれるか？
```




    (false, true)




```julia
t = pop!(s, "a") # 要素の削除
t |> println
s |> println
```

    a
    Set(Any[2, 3.5])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
union(a, b) |> println # 和集合
```

    Set([5, 4, 7, 2, 9, 3, 1])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
union!(a, b) # インプレイスでの和集合
a |> println
```

    Set([5, 4, 7, 2, 9, 3, 1])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
intersect(a, b) |> println # 積集合
```

    Set([3, 1])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
intersect!(a, b) # インプレイスでの積集合
a |> println
```

    Set([3, 1])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
setdiff(a, b) |> println # 差集合
```

    Set([5, 7, 9])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
setdiff!(a, b) # インプレースでの差集合
a |> println
```

    Set([5, 7, 9])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
symdiff(a, b) |> println # 和集合から積集合を除く
```

    Set([5, 4, 7, 2, 9])



```julia
symdiff!(a, b) # インプレースで和集合から積集合を除く
a |> println
```

    Set([5, 4, 7, 2, 9])



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
issubset(a, b) |> println # 包含関係にあるか？
issubset(a, Set([1, 3, 5, 7, 9, 11])) |> println 
```

    false
    true



```julia
a = Set([1,3,5,7,9])
b = Set([1,2,3,4])
issetequal(a, b) |> println # 同一か？
issubset(a, Set([1,3,5,7,9])) |> println
```

    false
    true



```julia
isempty(a), isempty(Set()), isempty(Set([])) # 空集合か？
```




    (false, true, true)




```julia
a = Set([1,3,5,7,9])
length(a) # 空集合か？
```




    5




```julia
a = Set([1,3,5,7,9])
empty!(a) # 空集合にする
isempty(a) |> println
a          |> println
```

    true
    Set{Int64}()


### 辞書

#### 空の辞書


```julia
dic1 = Dict()
```




    Dict{Any, Any}()




```julia
dic2 = Dict([])
```




    Dict{Any, Any}()




```julia
dic1 == dic2 # どちらの定義でも同じ
```




    true



#### 辞書の定義


```julia
dic = Dict("a" => 1, "foo" => "bar") # => で指定
```




    Dict{String, Any} with 2 entries:
      "a"   => 1
      "foo" => "bar"




```julia
Dict([("a", 1), ("foo", "bar")]) # タプルのベクトルで指定
```




    Dict{String, Any} with 2 entries:
      "a"   => 1
      "foo" => "bar"



#### 要素の参照


```julia
dic["a"], dic[:"foo"]
```




    (1, "bar")



#### 辞書を対象にする関数


```julia
dic = Dict()
dic[:a] = 1 # 要素の追加
dic[:foo] = "bar"
dic
```




    Dict{Any, Any} with 2 entries:
      :a   => 1
      :foo => "bar"




```julia
dic = Dict("a" => 1, "b" => 2)
x = pop!(dic, "a") # 要素の取り出し。取り出したものを使わないのであれば消去 delete!() と同じ
x   |> println
dic |> println
```

    1
    Dict("b" => 2)



```julia
dic = Dict("a" => 1, "b" => 2)
delete!(dic, "b") # 要素の削除
dic |> println
```

    Dict("a" => 1)



```julia
haskey(dic, "a"), haskey(dic, "x") # キーの存否
```




    (true, false)




```julia
keys(dic) |> println # キーの一覧
```

    ["a"]



```julia
values(dic) |> println # 値の一覧
```

    [1]



```julia
isempty(dic) # 辞書は空か?
```




    false




```julia
length(dic) # 辞書の長さ（要素数）
```




    1




```julia
empty!(dic) # 辞書を空にする
isempty(dic), length(dic)
```




    (true, 0)



マージ

第 1 引数，第 2 引数の両方にある要素は，第 2 引数の要素に置き換わる。


```julia
a = Dict("foo" => 0.0, "bar" => 42.0)
b = Dict("baz" => 17, "bar" => 4711)
merge(a, b)
```




    Dict{String, Float64} with 3 entries:
      "bar" => 4711.0
      "baz" => 17.0
      "foo" => 0.0




```julia
merge(b, a)
```




    Dict{String, Float64} with 3 entries:
      "bar" => 42.0
      "baz" => 17.0
      "foo" => 0.0



## 四則演算 + $\alpha$

### 加算


```julia
1 + 2, +(1, 2), +(1, 2, 3, 4, 5) # 和
```




    (3, 3, 15)



### 減算


```julia
5 - 3 , -(5, 3) # 差
```




    (2, 2)



### 乗算


```julia
2 * 8, *(2, 8), *(1, 2, 3, 4, 5, 6)
```




    (16, 16, 720)



乗算記号は省略できる。


```julia
x = 3
2x, 3.5x, 12/2x, 12/(2x), 2(x+4), 2^3x, 2^(3x)
```




    (6, 10.5, 2.0, 2.0, 14, 512, 512)



### 除算


```julia
14 / 3, /(14, 3) # 商
```




    (4.666666666666667, 4.666666666666667)



### 整数除算

整数除算演算子 `÷` は `\` `d` `i` `v` `tabキー` で入力できる。


```julia
13 ÷ 4, 13 ÷ -4, -13 ÷ 4, -13 ÷ -4, 13 ÷ 2
```




    (3, -3, -3, 3, 6)



整数除算は `div(x, y)` もある。


```julia
div(13, 4), div(13, -4), div(-13, 4), div(-13, -4), div(13, 2) # 整数除算
```




    (3, -3, -3, 3, 6)



### 剰余


```julia
13 % 4, 13 % -4, -13 % 4, -13 % -4, 13 % 2
```




    (1, 1, -1, -1, 1)



剰余は `rem(x, y)` もある。`rem(x, y)` と `x % y` は同じ結果になる。


```julia
rem(13, 4), rem(13, -4), rem(-13, 4), rem(-13, -4), rem(13, 2) # 剰余
```




    (1, 1, -1, -1, 1)



剰余関数は `mod(x, y)` もある。`mod(x, y)` と `rem(x, y)` の結果は違う場合がある。 


```julia
mod(13, 4), mod(13, -4), mod(-13, 4), mod(-13, -4), mod(13, 2)
```




    (1, -3, 3, -1, 1)



商と剰余を同時に求める `divrem(x, y)` がある。


```julia
divrem(13, 4), divrem(-13, 4), divrem(13, -4), divrem(-13, -4) 
```




    ((3, 1), (-3, -1), (-3, 1), (3, -1))



### 累乗とべき乗


```julia
2 ^ 5, 2.0 ^ 5, ^(2.0, 5)
```




    (32, 32.0, 32.0)




```julia
1.27 ^ 2.3, 2 ^ 0.5, ^(2, 0.5) # べき乗
```




    (1.732800474471134, 1.4142135623730951, 1.4142135623730951)



### 分数演算

有理数のままで演算される。


```julia
1//2 + 2//3
```




    7//6



### 左辺乗算演算子

`x \ y` は `x` の逆（逆数）と `y` の乗算を行う。

整数引数に対しても実数の結果を与える。
 


```julia
a = 12 \ 4, (1/12) * 4, inv(12) * 4
```




    (0.3333333333333333, 0.3333333333333333, 0.3333333333333333)



## 数学関数

### 床


```julia
floor(3.14), floor(Int, 3.14), floor(-3.14), floor(Int, -3.14)
```




    (3.0, 3, -4.0, -4)




```julia
fld(7.35, 2.8), 7.35/2.8, floor(7.35/2.8), floor(Int, 7.35/2.8)
```




    (2.0, 2.625, 2.0, 2)




```julia
div(7.35, 2.8), div(7.35, 2.8, RoundDown), div(7.35, 2.8, RoundUp) 
```




    (2.0, 2.0, 3.0)



### 天井


```julia
ceil(3.14), ceil(Int, 3.14), ceil(-3.14), ceil(Int, -3.14)
```




    (4.0, 4, -3.0, -3)




```julia
cld(7.35, 2.8), 7.35/2.8, ceil(7.35/2.8), ceil(Int, 7.35/2.8)
```




    (3.0, 2.625, 3.0, 3)




```julia
div(7.35, 2.8), div(7.35, 2.8, RoundDown), div(7.35, 2.8, RoundUp) 
```




    (2.0, 2.0, 3.0)



### 丸め


```julia
round(π, digits=5), round(2.15, digits=1), round(2.25, digits=1)
```




    (3.14159, 2.2, 2.2)




```julia
round(π), round(Int, 1π) # round(Int, π) はエラーになる
```




    (3.0, 3)




```julia
round(1.3), round(-1.3), round(1.6), round(-1.6)
```




    (1.0, -1.0, 2.0, -2.0)



### 切り捨て


```julia
trunc(1.3), trunc(-1.3), trunc(1.6), trunc(-1.6)
```




    (1.0, -1.0, 1.0, -1.0)



### 型変換


```julia
Int(12.0) # 小数点以下を含む数の Int(x) は InexactError になる
```




    12




```julia
Float64(12)
```




    12.0




```julia
float.([1, 2.3, π, ℯ]) |> println
```

    [1.0, 2.3, 3.141592653589793, 2.718281828459045]


第 2 引数の型を第 1 引数の型にする


```julia
oftype(4.0, 3), oftype(4, 3.0)
```




    (3.0, 3)



第 2 引数の型を第 1 引数で指定した型にする


```julia
convert(Float64, 3), convert(typeof(4.0), 3)
```




    (3.0, 3.0)




```julia
convert(Int, 3.0), convert(typeof(4), 3.0) # convert(Int, 3.1)
```




    (3, 3)



### 符号


```julia
sign(10), sign(0), sign(-2)
```




    (1, 0, -1)



### 符号の付替

`copysign(x, y)` は `x` の絶対値に `y` の符号を付けたものを返す。


```julia
copysign(10, -23), copysign(-5, 6) 
```




    (-10, 5)



### 絶対値


```julia
abs(-1.3), abs(-4), abs(0), abs(4)
```




    (1.3, 4, 0, 4)




```julia
14 % 3, -14 % 3, 14 % -3, -14 % -3, 14 %2
```




    (2, -2, 2, -2, 0)



### 平方根


```julia
sqrt(10), sqrt(123)
```




    (3.1622776601683795, 11.090536506409418)



整数平方根

sqrt() の整数部分


```julia
isqrt(10), isqrt(123)
```




    (3, 11)



### 立方根


```julia
cbrt(8), 8^(1/3), ∛8
```




    (2.0, 2.0, 2.0)



### 累乗

次の累乗数

`nextpow(x, y)` は $x^n \geqq y$ である最小の $x^n$


```julia
nextpow(2, 1000), nextpow(13, 500)
```




    (1024, 2197)



前の累乗数

`prevpow(x, y)` は $x^n \leqq y$ である最大の $x^n$


```julia
prevpow(2, 1000), prevpow(13, 500)
```




    (512, 169)



法による累乗


```julia
powermod(2, 6, 5), mod(2^6, 5)
```




    (4, 4)



### 対数関数

`log(b, x)` により，底が `b` の場合に，`x` の対数を求める。R や Python と順序が逆なので注意。

自然対数（底が ℯ の対数）`log(x)`，常用対数（底が 10 の対数）`log10(x)`，底が 2 の対数 `log2(x)`


```julia
log(10, 100), log(ℯ), log10(10), log2(2)
```




    (2.0, 1, 1.0, 1.0)



### 指数関数

自然対数の逆関数 `exp(x)`，常用対数の逆関数 `exp10(x)`，底が 2 の対数の逆関数 `exp2(x)`


```julia
exp(1), exp10(1), exp2(1)
```




    (2.718281828459045, 10.0, 2.0)



### 三角関数

引数がラジアンの三角関数


```julia
sin(π/6), cos(π/6), tan(π/6)
```




    (0.49999999999999994, 0.8660254037844387, 0.5773502691896257)



引数が度の三角関数


```julia
sind(30), cosd(30), tand(30)
```




    (0.5, 0.8660254037844386, 0.5773502691896258)



### 逆三角関数

引数がラジアンの逆三角関数


```julia
asin(0.5), acos(sqrt(3)/2), atan(1/sqrt(3)), π/6
```




    (0.5235987755982989, 0.5235987755982989, 0.5235987755982989, 0.5235987755982988)



引数が度の逆三角関数


```julia
asind(0.5), acosd(sqrt(3)/2), atand(1/sqrt(3))
```




    (30.000000000000004, 30.000000000000004, 30.000000000000004)



### 双曲線関数


```julia
sinh(2), cosh(2), tanh(2)
```




    (3.6268604078470186, 3.7621956910836314, 0.9640275800758169)



### 逆双曲線関数


```julia
asinh(sinh(2)), acosh(cosh(2)), atanh(tanh(2))
```




    (2.0, 2.0, 2.0000000000000004)



### 階乗


```julia
factorial(5), prod(1:5)
```




    (120, 120)




```julia
factorial(20), prod(1:20)
```




    (2432902008176640000, 2432902008176640000)



ガンマ関数，対数ガンマ関数との関連

$n! \equiv \Gamma(n+1)$


```julia
using SpecialFunctions
gamma(6), factorial(5), exp(lgamma(6)), exp(logfactorial(5))
```




    (120.0, 120, 119.99999999999997, 119.99999999999997)



階乗はすぐに大きくなる。21! は Float64 で扱えない。`factorial(big(n))` で求めることができる。


```julia
factorial(big(21))
```




    51090942171709440000



### 組み合わせの数


```julia
binomial(5, 3), factorial(5)÷factorial(3)÷factorial(2), factorial(5)/factorial(3)/factorial(2)
```




    (10, 10, 10.0)



### 最大公約数，最小公倍数


```julia
gcd(9797, 3589) # 最大公約数
```




    97




```julia
gcd(48, 128, 300) # 最大公約数
```




    4




```julia
lcm(48, 36) # 最小公倍数
```




    144




```julia
lcm(2, 3, 5, 7, 9, 11, 13) # 最小公倍数
```




    90090



## ドット記法

通常はスカラー変数を対象とする関数を，ベクトルの要素全体に作用させ，ベクトルとして結果を得るという操作が必要な場合がある。

for ループを使って以下のように簡単に書くことができる[^2]。R や Python では for ループが遅いので，ベクトル演算を使うように言われるが，Julia ではそんなことはなく，むしろ for ループで書いたほうが実行速度が速いこともある。


```julia
x = Float64.([2, 3, 5, 7, 11])
for i in 1:5
    x[i] = sqrt(x[i])
end
x |> println
```

    [1.4142135623730951, 1.7320508075688772, 2.23606797749979, 2.6457513110645907, 3.3166247903554]


別の方法はドット記法を使って，`関数名.(x）` とすることにより関数をベクトル対応にすることができる。


```julia
sqrt.([2, 3, 5, 7, 11]) |> println # 平方根を求める
```

    [1.4142135623730951, 1.7320508075688772, 2.23606797749979, 2.6457513110645907, 3.3166247903554]


四則演算子もドット記法を使うことによって，ベクトル演算をすることができる。


```julia
x = [2, 3, 5, 7, 11];
y = [1, 1, 2, 3,  5];

x .+ y |> println
x  + y |> println # `+` はドットを付けなくてもベクトル演算になる
```

    [3, 4, 7, 10, 16]
    [3, 4, 7, 10, 16]



```julia
x .- y |> println
x  - y |> println # `-` はドットを付けなくてもベクトル演算になる
```

    [1, 2, 3, 4, 6]
    [1, 2, 3, 4, 6]



```julia
x .* y |> println
# x * y |> println これは MethodError になる
```

    [2, 3, 10, 21, 55]



```julia
x / y # これは意図しない結果を生む
```




    5×5 Matrix{Float64}:
     0.05   0.05   0.1   0.15   0.25
     0.075  0.075  0.15  0.225  0.375
     0.125  0.125  0.25  0.375  0.625
     0.175  0.175  0.35  0.525  0.875
     0.275  0.275  0.55  0.825  1.375




```julia
x ./ y |> println
```

    [2.0, 3.0, 2.5, 2.3333333333333335, 2.2]



```julia
x .^ y |> println
```

    [2, 3, 25, 343, 161051]


## 文字列関数

### 文字列の比較


```julia
"abc" < "abcd", "xyz" == "xyz", "as" != "is"
```




    (true, true, true)



### 空白で区切る


```julia
s = "123 456 7890";
split(s) |> println
```

    SubString{String}["123", "456", "7890"]


### 任意の文字で区切る


```julia
t = "1-2/3/4"
split.(t, r"[-/]") |> println # 区切り文字は正規表現で指定できる
```

    SubString{String}["1", "2", "3", "4"]


### 1 文字ずつに分解する


```julia
u = "abc123!@#あいう統計学"
Char[u...] |> println
```

    ['a', 'b', 'c', '1', '2', '3', '!', '@', '#', 'あ', 'い', 'う', '統', '計', '学']


### 文字の連結


```julia
join(['a', 'b', 'c', '1', '2', '3', '!', '@', '#', 'あ', 'い', 'う', '統', '計', '学'])
```




    "abc123!@#あいう統計学"




```julia
join(['a', 'b', 'c', '1', '2', '3', '!', '@', '#', 'あ', 'い', 'う', '統', '計', '学'], "-")
```




    "a-b-c-1-2-3-!-@-#-あ-い-う-統-計-学"



### 文字列の連結


```julia
"abc" * "12345"
```




    "abc12345"




```julia
"123" * "abc" * "@#&" * "漢字"
```




    "123abc@#&漢字"




```julia
*("123", "abc", "@#&", "漢字")
```




    "123abc@#&漢字"




```julia
string("123", "abc", "@#&", "漢字")
```




    "123abc@#&漢字"




```julia
join(["123", "abc", "@#&", "漢字"])
```




    "123abc@#&漢字"




```julia
["a", "b", "c"] .* ["1", "2", "3"]　|> println
```

    ["a1", "b2", "c3"]



```julia
"Var" .* string.(1:5)　|> println
```

    ["Var1", "Var2", "Var3", "Var4", "Var5"]


### 文字列を数値に変換する

文字列を整数に変換する


```julia
parse(Int, "123")
```




    123




```julia
parse.(Int, ["123", "456", "7890"]) |> println
```

    [123, 456, 7890]



```julia
parse.(Int, split("123 456 7890")) |> println
```

    [123, 456, 7890]


文字列を実数に変換する


```julia
parse(Float64, "12.3")
```




    12.3




```julia
parse.(Float64, ["12.3", "4.56", "78.90"]) |> println
```

    [12.3, 4.56, 78.9]



```julia
parse.(Float64, split("12.3 4.56 78.90")) |> println
```

    [12.3, 4.56, 78.9]


### 数値を文字列に変換する
文字列に変換する


```julia
string(12.345), string(67890), string(-5.7)
```




    ("12.345", "67890", "-5.7")




```julia
string.([123, 4.56, -6.78]) |> println
```

    ["123.0", "4.56", "-6.78"]


### 文字列のアペンド

第 2 引数が文字列か文字列ベクトルかで違う。


```julia
a = []
append!(a, "12345")
a |> println
```

    Any['1', '2', '3', '4', '5']



```julia
b = []
append!(b, ["12345"])
b |> println
```

    Any["12345"]



```julia
c = []
append!(c, ["12345", "abc", "@#^"])
c |> println
```

    Any["12345", "abc", "@#^"]


### 文字列の繰り返し


```julia
"123"^4, "a"^5, 'x'^8
```




    ("123123123123", "aaaaa", "xxxxxxxx")



### 連続する文字列


```julia
String(0x41:0x5A), String(0x61:0x7A)
```




    ("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz")



### 文字コード（整数）を文字へ変換


```julia
Char(65), Char(65.0), Char(26412), Char(0x672c)
```




    ('A', 'A', '本', '本')



### 文字の文字コード


```julia
Int('A'), Float64('A'), Int('本')
```




    (65, 65.0, 26412)



### パディング（ゼロ埋め）


```julia
string(123, pad=5), string(-45, pad=8)
```




    ("00123", "-00000045")



### 文字列置換


```julia
x = 123; y = "abc"
"x = $x, sqrt(x) = $(sqrt(x)), y = $y"
```




    "x = 123, sqrt(x) = 11.090536506409418, y = abc"



### 文字列の逆転


```julia
reverse("1234567890abcde")
```




    "edcba0987654321"




```julia
reverse(["abc", "def", "ghi", "jkl", "mno"]) |> println
```

    ["mno", "jkl", "ghi", "def", "abc"]


### 大文字/小文字変換


```julia
lowercase("ABCdef"), uppercase("ABCdef"), titlecase("ABCdef")
```




    ("abcdef", "ABCDEF", "Abcdef")



### 行頭，末尾の文字の切り取り

最後の改行文字を取る


```julia
chomp("Hello\n"), chomp("Hello\n\n")
```




    ("Hello", "Hello\n")



先頭，末尾の文字を切り取る


```julia
chop("March", head = 1, tail = 2)
```




    "ar"



### スライス


```julia
a = "123456789"
a[2], a[3:5], a[end], a[end-2:end], a[1:2:end], a[2:3:end]
```




    ('2', "345", '9', "789", "13579", "258")




```julia
SubString(a, 2), SubString(a, 2, 2), SubString(a, 3, 5) # 引数が 1 個の場合は，それ以降全部になる
```




    ("23456789", "2", "345")




```julia
b = ["abc", "def", "ghi", "jkl", "mno"]
b[2], b[2:4], b[end], b[1:2, end]
```




    ("def", ["def", "ghi", "jkl"], "mno", ["abc", "def"])



### 部分文字列の存在

第 3 引数は探索を始める文字位置（省略できない）。


```julia
findnext("abc", "123abc5678abc", 1)
```




    4:6




```julia
findnext("abc", "123abc5678abc", 7)
```




    11:13



文字列が存在しないときは `nothing` を返す（多くのプログラミング言語では 0 や -1 を返すが Julia は違う）。


```julia
a = findnext("xyz", "123abc5678abc", 1)
println(a)
```

    nothing



```julia
isnothing(a)
```




    true




```julia
findlast("abc", "123abc5678abc")
```




    11:13



### 文字の位置


```julia
findfirst(isequal('o'), "xylophone")
```




    4




```julia
a = findfirst(isequal('z'), "xylophone")
println(a)
```

    nothing



```julia
findlast(isequal('o'), "xylophone")
```




    7




```julia
findnext(isequal('o'), "xylophone", 5)
```




    7




```julia
findprev(isequal('o'), "xylophone", 5)
```




    4



## 述語関数

述語関数とは「○○は△△か?」の結果を与える関数の総称で，たとえば「x は整数か?」とか「x は素数か?」のようなものである。結果は `true`, `false` である。

### 偶数か？


```julia
iseven(8), iseven(9)
```




    (true, false)



### 奇数か?


```julia
isodd(8), isodd(9)
```




    (false, true)



### 2 の累乗数か？


```julia
ispow2(0.5), ispow2(128), ispow2(347)
```




    (true, true, false)



### 型を知る


```julia
isa(1, Int)
```




    true




```julia
isa(1.0, Float64)
```




    true




```julia
isa([1, 2, 3], Array)
```




    true




```julia
isa([1, 2, 3], Vector)
```




    true




```julia
isa([1, 2, 3], Matrix)
```




    false




```julia
isa("1", String)
```




    true




```julia
isa([1 2; 3 4], Vector)
```




    false




```julia
isa([1 2; 3 4], Matrix)
```




    true



### 文字の種類


```julia
isuppercase('Ａ')
```




    true




```julia
isdigit('@'), isdigit('2'), isdigit('s'), isdigit('漢') # 数字か?
```




    (false, true, false, false)




```julia
isletter('@'), isletter('2'), isletter('s'), isletter('漢') # 文字か?
```




    (false, false, true, true)




```julia
isascii('@'), isascii('2'), isascii('s'), isascii('漢') # ASCII 文字か?
```




    (true, true, true, false)




```julia
isnumeric('@'), isnumeric('2'), isnumeric('s'), isnumeric('漢') # 数字か?
```




    (false, true, false, false)




```julia
isnumeric('９'), isdigit('９') # 全角数字は numeric であるが digit ではない
```




    (true, false)




```julia
islowercase('a'), islowercase('A'), islowercase('ａ') # アルファベット小文字
```




    (true, false, true)




```julia
isuppercase('a'), isuppercase('A'), isuppercase('Ａ') # アルファベット大文字
```




    (false, true, true)




```julia
isspace(' '), isspace('\n'), isspace('\t') # 空白文字類
```




    (true, true, true)




```julia
iscntrl(' '), iscntrl('\n'), iscntrl('\t') # 制御文字
```




    (false, true, true)



### 同じかどうか


```julia
isequal("a", "A"), isequal("a", "a"), isequal("a")("a"), "abc" == "abc"
```




    (false, true, true, true)



### `nothing` か


```julia
isnothing(nothing), isnothing(1)
```




    (true, false)




```julia
a = indexin(["boo"], ["foo", "bar", "baz"])[1]
b = indexin(["bar"], ["foo", "bar", "baz"])[1]
isnothing(a), isnothing(b)
```




    (true, false)



### `missing` か

Julia では欠損値は `missing` で表す。


```julia
ismissing(missing), ismissing(nothing), ismissing(NaN)
```




    (true, false, false)



### `NaN` か


```julia
isnan(NaN), isnan(Inf)
```




    (true, false)



### 無限か


```julia
isinf(Inf), isinf(-Inf)
```




    (true, true)



### 1 か

型によらず，1 かどうかを判定する。


```julia
isone(1), isone(1.0), isone(1//1), isone(big"1")
```




    (true, true, true, true)



### 0 か

型によらず，1 かどうかを判定する。


```julia
iszero(0), iszero(0.0), iszero(0//1), iszero(big"0")
```




    (true, true, true, true)



### 実数化したものが等しいか

`isreal(x)` は `isequal(x, real(x))` と同じである。


```julia
x = 1.23; real(x), isreal(x), isequal(x, real(x))
```




    (1.23, true, true)




```julia
x = 1.23+0im; real(x), isreal(x), isequal(x, real(x))
```




    (1.23, true, true)




```julia
x = Inf; real(x), isreal(x), isequal(x, real(x))
```




    (Inf, true, true)




```julia
x = -Inf; real(x), isreal(x), isequal(x, real(x))
```




    (-Inf, true, true)




```julia
x = NaN; real(x), isreal(x), isequal(x, real(x))
```




    (NaN, true, true)




```julia
x = missing; real(x), isreal(x), isequal(x, real(x))
```




    (missing, missing, true)



### 小さいか


```julia
isless(3, 5), isless("a", "a"), isless("blue", "red")
```




    (true, false, true)



### ソートされているか


```julia
issorted([1,3,6,9]), issorted([3,2,4,9])
```




    (true, false)



### 辞書順の比較

辞書順で大きければ 1，同じならば 0，小さければ -1


```julia
cmp("def", "abc"), cmp("ab", "ab"), cmp("abc", "xyz")
```




    (1, 0, -1)



### パスは存在するか


```julia
ispath("/Applications/julia-1.7.app")
```




    false



### ディレクトリか


```julia
isdir("/Applications/julia-1.7.app")
```




    false



### ファイルか


```julia
isfile("/Applications/julia-1.7.app")
```




    false




```julia
isfile("/Applications/Julia-1.7.app/Contents/Resources/julia/bin/julia")
```




    false



### オープンされているか


```julia
isfile("testfile12345.txt") # ファイルが存在するか
```




    false




```julia
io = open("testfile12345.txt", "w") # 存在しないので，書き込みのためにオープンする
```




    IOStream(<file testfile12345.txt>)




```julia
isopen(io) # オープンされたか
```




    true




```julia
close(io) # クローズする
```


```julia
isopen(io) # オープンされているか--> closer(io) したのでオープンしていない
```




    false




```julia
ispath("testfile12345.txt") # ファイルは存在するか
```




    true




```julia
rm("testfile12345.txt") # 削除する
```


```julia
ispath("testfile12345.txt") # ファイルは存在するか再確認
```




    false



## 乱数関数


```julia
using Random
```

### 乱数の種の設定


```julia
Random.seed!(123);
```

### シャッフル


```julia
shuffle(collect(1:10)) |> println
```

    [8, 9, 3, 4, 1, 6, 5, 7, 2, 10]


### 一様乱数ベクトル


```julia
rand(4) |> println
```

    [0.7201025594903295, 0.5736192424686392, 0.6644684787269287, 0.29536650475479964]


### 一様乱数行列


```julia
rand(2,3)
```




    2×3 Matrix{Float64}:
     0.276597  0.880897  0.380949
     0.983436  0.234017  0.131944



### 無作為抽出


```julia
rand(1:6, 10) |> println
```

    [1, 2, 3, 5, 2, 1, 4, 2, 1, 2]



```julia
rand(100:120, 5) |> println
```

    [108, 100, 101, 119, 108]



```julia
rand(["abc", "de", "fghi"], 5) |> println
```

    ["fghi", "de", "fghi", "abc", "fghi"]



```julia
rand("12345", 5) |> println
```

    ['5', '4', '1', '3', '5']



```julia
rand(['1', '2', '3', 'x', 'y'], 5) |> println
```

    ['2', 'y', '2', 'x', 'y']



```julia
rand(('x', 'y', :z), 5) |> println
```

    Any[:z, :z, :z, 'y', 'y']


### 正規乱数ベクトル

#### 母平均 0，標準偏差 1 の標準正規乱数


```julia
randn(4) |> println
```

    [0.43087746656883236, -0.7088849648388045, 1.5393309737299636, -0.5020836713902217]


#### 母平均 μ，標準偏差 σ の標準正規乱数


```julia
μ = 50; σ = 10
randn(4) .* σ .+ μ |> println
```

    [45.17815437593204, 60.38420185234335, 44.47126184287746, 38.01480674787298]



```julia
round.(randn(10) .* σ .+ μ, digits=2) |> println
```

    [37.15, 60.38, 59.78, 42.14, 48.64, 45.64, 31.04, 58.87, 50.98, 60.43]


### 正規乱数行列

#### 母平均 0，標準偏差 1 の標準正規乱数


```julia
randn(2, 3)
```




    2×3 Matrix{Float64}:
     -0.352303  -1.12886   2.1921
     -0.634858   0.436752  1.50917



## 統計関数


```julia
x = [0.5, 8.0, 5.4, 8.8, 5.0, 9.8, 2.3, 2.6, 0.1, 2.0];
```

### 最小値，最大値


```julia
argmin(x), findmin(x) # 最小値のある位置，（最小値，最小値のある位置）
```




    (9, (0.1, 9))




```julia
argmax(x), findmax(x) # 最大値のある位置，（最大値，最大値のある位置）
```




    (6, (9.8, 6))




```julia
minimum(x), maximum(x) # 最小値，最大値
```




    (0.1, 9.8)




```julia
extrema(x) # 最小値と最大値のタプル
```




    (0.1, 9.8)



### 和，平均値，中央位，不偏分散，標準偏差


```julia
using Statistics # mean(), median(), var(), std() を使うときに必要
sum(x), mean(x), median(x), var(x), std(x) # 和，平均値，中央値，不偏分散，標準偏差
```




    (44.5, 4.45, 3.8, 12.21388888888889, 3.494837462442122)




```julia
var(x, corrected=false), std(x, corrected=false) # 不偏ではない分散と標準偏差
```




    (10.992500000000001, 3.315493930020081)



### 幾何平均，調和平均


```julia
using StatsBase
geomean(x), harmmean(x) # 幾何平均，調和平均
```




    (2.5391383697713596, 0.7119839536457752)



### パーセンタイル値


```julia
quantile(x) |> println
```

    [0.1, 2.075, 3.8, 7.35, 9.8]



```julia
quantile(x, [0, 0.25, 0.5, 0.75, 1]) |> println # 第 2 引数で q 値を指定
```

    [0.1, 2.075, 3.8, 7.35, 9.8]



```julia
quantile(x, 0.95) |> println # 第 2 引数で q 値を指定
```

    9.350000000000001


### 累和，累積，差分


```julia
cumsum(1:10) |> println # 累和
```

    [1, 3, 6, 10, 15, 21, 28, 36, 45, 55]



```julia
cumprod(1:10) |> println # 累積
```

    [1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800]



```julia
diff(sort(x)) |> println # 差分
```

    [0.4, 1.5, 0.2999999999999998, 0.30000000000000027, 2.4, 0.40000000000000036, 2.5999999999999996, 0.8000000000000007, 1.0]



```julia
x = [0.5, 8.0, 5.4, 8.8, 5.0, 9.8, 2.3, 2.6, 0.1, 2.0];
y = [9.5, 2.9, 0.4, 7.6, 3.8, 0.1, 9.2, 5.5, 8.8, 3.6];
cov(x, y), cov(x, y, corrected=false) # 不偏分散共分散行列，分散共分散行列
```




    (-7.580000000000002, -6.822000000000001)



### 相関係数，順位相関係数


```julia
cor(x, y), corspearman(x, y), corkendall(x, y) # ピアソンの積率相関係数，スピアマンの順位相関係数，ケンドールの順位相関係数
```




    (-0.6144891041342924, -0.6727272727272727, -0.5111111111111111)



### missing, NaN の取り扱い

ベクトルから欠損値 `missing` を除いて集計する


```julia
a = [1,2, missing, 3, 4, 5]
a |> println
mean(a)
```

    Union{Missing, Int64}[1, 2, missing, 3, 4, 5]





    missing




```julia
b = skipmissing(a)
b |> println
mean(b)
```

    skipmissing(Union{Missing, Int64}[1, 2, missing, 3, 4, 5])





    3.0



ベクトルから `NaN` を取り除いて集計する


```julia
c = [3, 4, NaN, 5, 6]
d = filter(x -> !isnan(x), c)
mean(d)
```




    4.5



ベクトルから `missing`, `NaN` を除いて集計する


```julia
e = [3, 4, NaN, 5, missing]
```




    5-element Vector{Union{Missing, Float64}}:
       3.0
       4.0
     NaN
       5.0
        missing




```julia
f = filter(x -> !isnan(x), skipmissing(e))
```




    3-element Vector{Float64}:
     3.0
     4.0
     5.0




```julia
mean(f)
```




    4.0



### 関数適用後の統計量

関数を適用したあとの統計量


```julia
e = [1, 2, 3, 6, 9, 11];
mean(√, e)
```




    2.152063150513425




```julia
mean(sqrt, e)
```




    2.152063150513425




```julia
mean(sqrt.(e))
```




    2.152063150513425




```julia
sum(sqrt, e)
```




    12.91237890308055




```julia
std(sqrt.(e))
```




    0.9177957482156243



### 定義されているメソッド（関数）の一覧


```julia
methods(mean)
```




# 9 methods for generic function <b>mean</b> from [35mStatistics[39m:<ul><li> mean(r::<b>AbstractRange{<:Real}</b>) in Statistics at <a href="file:///Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl" target="_blank">/Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl:195</a></li> <li> mean(A::<b>AbstractArray</b>, w::<b>UnitWeights</b>; <i>dims</i>) in StatsBase at <a href="file:///Users/aoki/.julia/packages/StatsBase/XgjIN/src/weights.jl" target="_blank">/Users/aoki/.julia/packages/StatsBase/XgjIN/src/weights.jl:672</a></li> <li> mean(A::<b>AbstractArray</b>, w::<b>AbstractWeights</b>; <i>dims</i>) in StatsBase at <a href="file:///Users/aoki/.julia/packages/StatsBase/XgjIN/src/weights.jl" target="_blank">/Users/aoki/.julia/packages/StatsBase/XgjIN/src/weights.jl:665</a></li> <li> mean(A::<b>AbstractArray</b>; <i>dims</i>) in Statistics at <a href="file:///Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl" target="_blank">/Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl:174</a></li> <li> mean(A::<b>AbstractArray{T}</b>, w::<b>AbstractWeights{W, T} where T<:Real</b>, dims::<b>Int64</b>)<i> where {T<:Number, W<:Real}</i> in StatsBase at <a href="file:///Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/base/deprecated.jl" target="_blank">deprecated.jl:103</a></li> <li> mean(f::<b>Number</b>, itr::<b>Number</b>) in Statistics at <a href="file:///Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl" target="_blank">/Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl:106</a></li> <li> mean(itr) in Statistics at <a href="file:///Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl" target="_blank">/Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl:44</a></li> <li> mean(f, A::<b>AbstractArray</b>; <i>dims</i>) in Statistics at <a href="file:///Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl" target="_blank">/Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl:104</a></li> <li> mean(f, itr) in Statistics at <a href="file:///Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl" target="_blank">/Applications/Julia-1.10.app/Contents/Resources/julia/share/julia/stdlib/v1.10/Statistics/src/Statistics.jl:61</a></li> </ul>



### 配列を対象とする集計関数

`sum()`, `mean()`, `var()`, `std()`,... は，`dims=` で次元を指定できる。


```julia
z = [1 2 3; 4 5 6]
```




    2×3 Matrix{Int64}:
     1  2  3
     4  5  6




```julia
sum(z, dims=1) # 列和 結果は (1, m) 行列
```




    1×3 Matrix{Int64}:
     5  7  9




```julia
sum(z, dims=2) # 行和 結果は (n, 1) 行列
```




    2×1 Matrix{Int64}:
      6
     15



### 分散共分散行列


```julia
z = [1 2 4; 4 2 5; 5 6 7; 2 4 1; 3 5 4];
cov(z)
```




    3×3 Matrix{Float64}:
     2.5  1.5   2.5
     1.5  3.2   1.05
     2.5  1.05  4.7



### 相関係数行列


```julia
cor(z)
```




    3×3 Matrix{Float64}:
     1.0       0.53033   0.729325
     0.53033   1.0       0.270748
     0.729325  0.270748  1.0




```julia
corspearman(z)
```




    3×3 Matrix{Float64}:
     1.0       0.564288  0.820783
     0.564288  1.0       0.289474
     0.820783  0.289474  1.0




```julia
corkendall(z)
```




    3×3 Matrix{Float64}:
     1.0       0.527046  0.737865
     0.527046  1.0       0.222222
     0.737865  0.222222  1.0



### データの正規化


```julia
x = [1. 2 3; 4 5 6; 7 8 9; 10 11 12]
```




    4×3 Matrix{Float64}:
      1.0   2.0   3.0
      4.0   5.0   6.0
      7.0   8.0   9.0
     10.0  11.0  12.0




```julia
using StatsBase
a = fit(ZScoreTransform, x, dims=1)
```




    ZScoreTransform{Float64, Vector{Float64}}(3, 1, [5.5, 6.5, 7.5], [3.872983346207417, 3.872983346207417, 3.872983346207417])




```julia
b = StatsBase.transform(a, x)
```




    4×3 Matrix{Float64}:
     -1.1619    -1.1619    -1.1619
     -0.387298  -0.387298  -0.387298
      0.387298   0.387298   0.387298
      1.1619     1.1619     1.1619




```julia
mean(b, dims=1)
```




    1×3 Matrix{Float64}:
     0.0  0.0  0.0




```julia
std(b, dims=1)
```




    1×3 Matrix{Float64}:
     1.0  1.0  1.0



### 平均順位


```julia
x = [3,2,1,2,3,4,5,6,6,5,4,4,4,4,3,2]
tiedrank(x) |> println
```

    [6.0, 3.0, 1.0, 3.0, 6.0, 10.0, 13.5, 15.5, 15.5, 13.5, 10.0, 10.0, 10.0, 10.0, 6.0, 3.0]



```julia
using StatsBase
z = [1 2 4; 4 2 5; 5 6 7; 2 4 1; 3 5 4]
```




    5×3 Matrix{Int64}:
     1  2  4
     4  2  5
     5  6  7
     2  4  1
     3  5  4




```julia
[tiedrank(z[:, i]) for i in 1:size(z, 2)]
```




    3-element Vector{Vector{Float64}}:
     [1.0, 4.0, 5.0, 2.0, 3.0]
     [1.5, 1.5, 5.0, 3.0, 4.0]
     [2.5, 4.0, 5.0, 1.0, 2.5]



### カウント

条件を満たす要素が何個あるか数える。


```julia
count(isequal(2), [2, 1, 2, 1, 1, 3, 4, 2, 1])
```




    3




```julia
count([2, 1, 2, 1, 1, 3, 4, 2, 1] .== 2)  
```




    3




```julia
count(iseven, [2, 1, 3, 4, 4, 5, 6, 7, 8])
```




    5



### ユニークな要素

ユニークな要素を取り出す


```julia
unique([2, 1, 2, 1, 1, 3, 4, 2, 1]) |> println
```

    [2, 1, 3, 4]


結果をソートすることができる。


```julia
sort(unique([2, 1, 2, 1, 1, 3, 4, 2, 1])) |> println
```

    [1, 2, 3, 4]



```julia
Set([2, 1, 2, 1, 1, 3, 4, 2, 1]) |> println
```

    Set([4, 2, 3, 1])


Set() の結果は unique() の結果とは違い，直接 sort() ではソートできないので，以下のようにすればよい。


```julia
sort([x for x in Set([2, 1, 2, 1, 1, 3, 4, 2, 1])]) |> println
```

    [1, 2, 3, 4]


## ブロードキャストとベクトル化


```julia
A = [1, 2, 3, 4, 5]
B = [1 2; 3 4; 5 6; 7 8; 9 10]

broadcast(+, A, B)
```




    5×2 Matrix{Int64}:
      2   3
      5   6
      8   9
     11  12
     14  15




```julia
A .+ B
```




    5×2 Matrix{Int64}:
      2   3
      5   6
      8   9
     11  12
     14  15




```julia
sqrt.(B)
```




    5×2 Matrix{Float64}:
     1.0      1.41421
     1.73205  2.0
     2.23607  2.44949
     2.64575  2.82843
     3.0      3.16228




```julia
@. sqrt(B) + A - 1.5
```




    5×2 Matrix{Float64}:
     0.5      0.914214
     2.23205  2.5
     3.73607  3.94949
     5.14575  5.32843
     6.5      6.66228




```julia
sqrt.(B) .+ A .- 1.5
```




    5×2 Matrix{Float64}:
     0.5      0.914214
     2.23205  2.5
     3.73607  3.94949
     5.14575  5.32843
     6.5      6.66228



## 変換 `map()`


```julia
A = [1,2,3]
map(x -> x^2, A) |> println
```

    [1, 4, 9]



```julia
map(A) do x
    x += 1
end
A |> println
```

    [1, 2, 3]


## 配列Aの要素を集約(加算)


```julia
A = [1,2,3]
reduce(+, A)
```




    6




```julia
using Statistics
vars = randn(2,3,4)
reduce(+, vars, dims=3) # 3次元配列 n x n x k
```




    2×3×1 Array{Float64, 3}:
    [:, :, 1] =
     -0.474051   3.19686    0.679801
      0.753845  -0.684118  -0.808813



## フィルタリング(filter)


```julia
# 3以上の要素を抽出(フィルタリング)
A = [1, 2, 3, 4, 5]
filter(x -> x >= 3, A) |> println
```

    [3, 4, 5]



```julia
filter(isodd, A) |> println
```

    [1, 3, 5]



```julia
A[A .>= 3] |> println
```

    [3, 4, 5]



```julia
a = [2, 4, 5, 3, 2, 1, 5, 6, 4] 
deleteat!(a, findall(isequal(4), a)) |> println
```

    [2, 5, 3, 2, 1, 5, 6]



```julia
filter!(x -> x != 4, a) |> println
```

    [2, 5, 3, 2, 1, 5, 6]


## ソート   `sort(x)`, `sort!(x)`


```julia
vec1 = [3, 2, 1, 5, 4];
a = sort(vec1);
a |> println
```

    [1, 2, 3, 4, 5]


インプレース（破壊的）なソート   sort!()


```julia
vec1 = [3, 2, 1, 5, 4];
b = sort!(vec1);
b |> println
```

    [1, 2, 3, 4, 5]



```julia
vec1 |> println
```

    [1, 2, 3, 4, 5]


逆順ソート   `sort(x , rev=true)`


```julia
vec1 = [3, 2, 1, 5, 4];
a = sort(vec1, rev=true);
a |> println
```

    [5, 4, 3, 2, 1]


データフレームのソート


```julia
using DataFrames
df = DataFrame(x = [3, 1, 2, 1], y = ["b", "c", "a", "b"]);
sort(df, :x) |> println
```

    [1m4×2 DataFrame[0m
    [1m Row [0m│[1m x     [0m[1m y      [0m
         │[90m Int64 [0m[90m String [0m
    ─────┼───────────────
       1 │     1  c
       2 │     1  b
       3 │     2  a
       4 │     3  b



```julia
sort(df, [:x, :y]) |> println
```

    [1m4×2 DataFrame[0m
    [1m Row [0m│[1m x     [0m[1m y      [0m
         │[90m Int64 [0m[90m String [0m
    ─────┼───────────────
       1 │     1  b
       2 │     1  c
       3 │     2  a
       4 │     3  b



```julia
sort(df, [:x, :y], rev=true) |> println
```

    [1m4×2 DataFrame[0m
    [1m Row [0m│[1m x     [0m[1m y      [0m
         │[90m Int64 [0m[90m String [0m
    ─────┼───────────────
       1 │     3  b
       2 │     2  a
       3 │     1  c
       4 │     1  b


## 並べ替えベクトルを返す `sortperm(x)`


```julia
df = DataFrame(x = [3, 1, 2, 1], y = ["b", "c", "a", "b"]);
sortperm(df, :x) |> println
```

    [2, 4, 3, 1]



```julia
sortperm(df, [:x, :y]) |> println
```

    [4, 2, 3, 1]



```julia
sortperm(df, [:x, :y], rev=true) |> println
```

    [1, 3, 2, 4]


ソートの順番を決める  order


```julia
using DataFrames
df = DataFrame(x = [-3, -1, 0, 2, 4], y = 1:5);
sort(df, order(:x, rev=true)) |> println
```

    [1m5×2 DataFrame[0m
    [1m Row [0m│[1m x     [0m[1m y     [0m
         │[90m Int64 [0m[90m Int64 [0m
    ─────┼──────────────
       1 │     4      5
       2 │     2      4
       3 │     0      3
       4 │    -1      2
       5 │    -3      1



```julia
sort(df, order(:x, by=abs)) |> println
```

    [1m5×2 DataFrame[0m
    [1m Row [0m│[1m x     [0m[1m y     [0m
         │[90m Int64 [0m[90m Int64 [0m
    ─────┼──────────────
       1 │     0      3
       2 │    -1      2
       3 │     2      4
       4 │    -3      1
       5 │     4      5


## 要素のある位置 index, find


```julia
a = ['a', 'b', 'c', 'b', 'd', 'a']; # 要素が1個でもベクトルにしないといけない　でもないようだけど？
b = ['a', 'b', 'c'];
indexin(a, b) |> println
```

    Union{Nothing, Int64}[1, 2, 3, 2, nothing, 1]



```julia
indexin(b, a) |> println
```

    Union{Nothing, Int64}[1, 2, 3]



```julia
indexin('x', a) |> println
```

    fill(nothing)



```julia
indexin(['x'], a) |> println
```

    Union{Nothing, Int64}[nothing]



```julia
isnothing.(indexin('x', a))
```




    true




```julia
isnothing(nothing)
```




    true



最小値，最大値のある位置 R の which.max, which.min


```julia
vec2 = [3, 2, 5, 1, 6, 9, 4]
argmin(vec2), argmax(vec2)
```




    (4, 6)



`searchsortedfirst(a, x)`
第 3 引数により昇順または降順にソートされたリスト中で，第 2 引数より大きいか等しい最初の要素の位置。もし第 2 引数がリスト中のすべての要素より大きければ「リスト長 + 1」 を返す。


```julia
searchsortedfirst([1,3,5,7], 4)  # 3
```




    3




```julia
searchsortedfirst([1,3,5,7], 10) # 5
```




    5




```julia
searchsortedfirst([1,3,5,7], 3)  # 2
```




    2




```julia
searchsortedfirst([7,5,3,1], 4, rev=true) # 3
```




    3



`searchsortedlast(a, x)`
第 3 引数により昇順または降順にソートされたリスト中で，第 2 引数より小さいか等しい最後の要素の位置。もし第 2 引数がリスト中のすべての要素より小さければ 0 を返す。


```julia
searchsortedlast([1,3,5,7], -1)  # 0
```




    0




```julia
searchsortedlast([1,3,5,7], 10)  # 4
```




    4




```julia
searchsortedlast([1,3,5,7], 3)   # 2
```




    2




```julia
searchsortedlast([7,5,3,1], 4, rev=true)  # 2
```




    2



バイナリ・コンビネーション

R の `e1071::bincombinations()` に相当


```julia
all_perm(x, n) = Iterators.product((x for i = 1:n)...)
for i in all_perm([0, 1], 3)
    println(i)
end
```

    (0, 0, 0)
    (1, 0, 0)
    (0, 1, 0)
    (1, 1, 0)
    (0, 0, 1)
    (1, 0, 1)
    (0, 1, 1)
    (1, 1, 1)


組み合わせ

R の `combn()` に相当


```julia
using Combinatorics
for i in combinations(1:4, 2)
   println(i)
end
```

    [1, 2]
    [1, 3]
    [1, 4]
    [2, 3]
    [2, 4]
    [3, 4]


順列

R  の `permutations()` に相当


```julia
using Combinatorics
a = [1,2,3]
for i in 1:factorial(length(a))
    println(nthperm(a, i))
end
```

    [1, 2, 3]
    [1, 3, 2]
    [2, 1, 3]
    [2, 3, 1]
    [3, 1, 2]
    [3, 2, 1]


b の逆順列を作る　　invperm(v)


```julia
invperm([2,3,1]) |> println
```

    [3, 1, 2]


v が正しい順列ならば true を返す　　isperm(v)


```julia
isperm([3,2,1,4]), isperm([3,2,1,1,3])
```




    (true, false)



インプレースで順列を作る　　permute!(v, p)


```julia
x = [1,3,2,4,5]
permute!(x, [2,1,3,5,4]) |> println
```

    [3, 1, 2, 5, 4]


インプレースで逆順列を作る　　invpermute!(v, p)


```julia
x = [2,1,3,5,4]
invpermute!(x, [1,3,2,4,5]) |> println
```

    [2, 3, 1, 5, 4]


逆順に並べたコピーを返す　　reverse(v [, start=1 [, stop=length(v) ]] )


```julia
x = [2,1,3,5,4]
reverse(x) |> println
```

    [4, 5, 3, 1, 2]


インプレースで逆順　　reverse!(v [, start=1 [, stop=length(v) ]]) -> v


```julia
reverse!([5,6,4,3,5,3,1]) |> println
```

    [1, 3, 5, 3, 4, 6, 5]


dims で指定した次元について逆順にする　　reverse(A; dims::Integer)


```julia
z = [2 3 2 1
     3 4 2 3
     2 1 2 4
     3 2 4 6]
reverse(z, dims=1)
```




    4×4 Matrix{Int64}:
     3  2  4  6
     2  1  2  4
     3  4  2  3
     2  3  2  1




```julia
reverse(z, dims=2)
```




    4×4 Matrix{Int64}:
     1  2  3  2
     3  2  4  3
     4  2  1  2
     6  4  2  3



## 値のある場所のインデックス

一番大きい要素のインデックス，二番目に大きい要素のインデックス，...

つまり，昇順ソートするときに，順に取り出す要素の位置


```julia
d = [3, 2, 5, 1, 4];
sortperm(d) |> println
```

    [4, 2, 1, 5, 3]


`sortperm(d)` を使ってソートするのはこういうこと


```julia
d[sortperm(d)] |> println
```

    [1, 2, 3, 4, 5]


降順ソートするときに，順に取り出す要素の位置

sortperm(d) を使ってソートするのはこういうこと


```julia
rd = sortperm(d, rev=true)
d[rd] |> println
```

    [5, 4, 3, 2, 1]


破壊的ソート。d がインプレースでソートされるので，代入しなくてよい。


```julia
sort!(d)
d |> println
```

    [1, 2, 3, 4, 5]


## 文字列の繰り返し


```julia
"a" ^ 5, "123" ^ 3
```




    ("aaaaa", "123123123")



## 繰り返し `repeat()`


```julia
repeat(["a"], 5) |> println
```

    ["a", "a", "a", "a", "a"]



```julia
repeat([1,2,3], 4) |> println
```

    [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]



```julia
repeat([1, 2, 3], 3) |> println # ベクトルの繰り返し
```

    [1, 2, 3, 1, 2, 3, 1, 2, 3]



```julia
repeat([1, 2, 3], inner=3) |> println # 各要素の繰り返し
```

    [1, 1, 1, 2, 2, 2, 3, 3, 3]



```julia
repeat([1, 2, 3], inner=2, outer=3) |> println # 各要素の繰り返しの繰り返し
```

    [1, 1, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3, 1, 1, 2, 2, 3, 3]



```julia
repeat([1 2 3], inner=(1,2)) |> println
```

    [1 1 2 2 3 3]



```julia
a = [1 2 3]
```




    1×3 Matrix{Int64}:
     1  2  3




```julia
repeat(a)
```




    1×3 Matrix{Int64}:
     1  2  3




```julia
repeat(a, outer=1)
```




    1×3 Matrix{Int64}:
     1  2  3




```julia
repeat(a, outer=2)
```




    2×3 Matrix{Int64}:
     1  2  3
     1  2  3




```julia
repeat(a, inner=(1,2), outer=(4,3))
```




    4×18 Matrix{Int64}:
     1  1  2  2  3  3  1  1  2  2  3  3  1  1  2  2  3  3
     1  1  2  2  3  3  1  1  2  2  3  3  1  1  2  2  3  3
     1  1  2  2  3  3  1  1  2  2  3  3  1  1  2  2  3  3
     1  1  2  2  3  3  1  1  2  2  3  3  1  1  2  2  3  3



## R の expand.grid()


```julia
using DataFrames

arr1 = ["a", "b", "c"]
arr2 = ["d", "e", "f"]

v = vec(collect(Base.product(arr1, arr2)))
```




    9-element Vector{Tuple{String, String}}:
     ("a", "d")
     ("b", "d")
     ("c", "d")
     ("a", "e")
     ("b", "e")
     ("c", "e")
     ("a", "f")
     ("b", "f")
     ("c", "f")




```julia
columns = (:A, :B)
data = NamedTuple{columns}.(v)

df = DataFrame(data)
df |> println
```

    [1m9×2 DataFrame[0m
    [1m Row [0m│[1m A      [0m[1m B      [0m
         │[90m String [0m[90m String [0m
    ─────┼────────────────
       1 │ a       d
       2 │ b       d
       3 │ c       d
       4 │ a       e
       5 │ b       e
       6 │ c       e
       7 │ a       f
       8 │ b       f
       9 │ c       f


## 正規表現

### `match()`


```julia
regex = r"H.*w"
m = match(regex, "I love Halloween!")
```




    RegexMatch("Hallow")




```julia
isnothing(m)
```




    false




```julia
m.match      # 一致した文字列を取得
```




    "Hallow"




```julia
m.offset     # 一致した位置を取得
```




    8




```julia
m = match(r"[0-9]", "I love Halloween!")
```


```julia
isnothing(m)
```




    true



### `occursin()`


```julia
occursin("ab", "fabric"), occursin("abc", "fabric")
```




    (true, false)




```julia
occursin.("ab", ["fabric", "non"])
```




    2-element BitVector:
     1
     0



### `contains()`

`contains()` と `occursin()` は引数の順序が違うだけで，同じものである。


```julia
contains("fabric", "ab")
```




    true




```julia
contains.(["fabric", "non"], "ab")
```




    2-element BitVector:
     1
     0



### `findfirst()`


```julia
findfirst(r"ab", "hj ab jkabs jhjhk ab")
```




    4:5




```julia
findfirst("ab", "hj ab jkabs jhjhk ab")
```




    4:5



### `findlast()`


```julia
findlast("ab", "hj ab jkabs jhjhk abff iui")
```




    19:20



### `findall()`


```julia
findall(r"ab", "hj ab jkabs jhjhk abff iui")
```




    3-element Vector{UnitRange{Int64}}:
     4:5
     9:10
     19:20




```julia
findall(==(2), [3, 1, 0, 2, 4, 0, 3, 5, 4, 2])
```




    2-element Vector{Int64}:
      4
     10



### `replace()`


```julia
replace("abcdefabcdefababababa", "ab"=>"@@")
```




    "@@cdef@@cdef@@@@@@@@a"




```julia
replace("abcdefabcdefababababa", "ab"=>"@@", count=2)
```




    "@@cdef@@cdefababababa"




```julia
replace("first second", r"(\w+) (?<agroup>\w+)" => s"\g<agroup> \1")
```




    "second first"




```julia
sentence1 = "a!b?c'd:e;f,g.h"
replace(sentence1, r"[!?':;,.]" => "")
```




    "abcdefgh"



## 制御構文

### `if`-`end`, `if`-`else`-`end`, `if`-`elseif`-`else`-`end`

プログラムは通常，上から下に順序に従って実行される。しかし，場合によって（実行されないことも含めて）実行される内容が違ったりすることがある。

単純には，条件を満たすときに実行する部分は `if`-`end` で挟んで書く。

以下の例では，a が偶数のときは a を 2 で割ったものを新たに a とすることを表している。a が奇数のときは何もしないで `end` の次のプログラムを実行する。


```julia
a = 4
if a % 2 == 0
    a = a ÷ 2
end
```




    2



`a` が奇数のときに実行したいものは


```julia
a = 5
if a % 2 == 1
    a = 3 * a + 1
end
```




    16



のように書いてもよいが，`a` が偶数でなければ奇数なので，これをまとめて以下のように書く。

「もし（`if`） `a` が偶数ならば 2 で割る。そうでなければ（`else`） 3 倍して 1 を足す」 ということである。


```julia
a = 4
if a % 2 == 0
    a = a ÷ 2
else
    a = 3 * a + 1
end
```




    2



Fizz-Buzz プログラムというのは，「1 から順に数字を書いていく。ただし，3 の倍数のときには数字ではなく "Fizz"，5 の倍数のときには "Buzz"，15 の倍数のときには "FizzBuzz" と書く」のであるが，条件が 3 通りになったので，上の `if`-`else`-`end` では書けない。使うのは `if`-`elseif`-`else`-`end` である。数字 `x` を書くとき，条件により適切なものを書く部分は以下のようになる。

この例のように，`elseif` は複数個書くことができる。また，場合によっては最後の `else` を省略できる，あるいは省略しなければならないこともある。


```julia
x = 17
if x % 15 == 0
    println("FizzBuzz")
elseif x % 3 == 0
    println("Fizz")
elseif x % 5 == 0
    println("Buzz")
else
    println(x)
end
```

    17


### 三項演算子


```julia
x = 3
x > 0 ? true : false
```




    true




```julia
ifelse(x > 0, true, false)
```




    true



### for ループ

`for`-`end` で構成される，もっとも基本的な for ループは以下のようなものである。`i` を 1 から 10 まで変化させて `for` と `end` で挟まれた式を評価する。


```julia
s = 0
for i in 1:10
    s += i
    println("i = $i, s = $s")
end
println("result = $s")
```

    i = 1, s = 1
    i = 2, s = 3
    i = 3, s = 6
    i = 4, s = 10
    i = 5, s = 15
    i = 6, s = 21
    i = 7, s = 28
    i = 8, s = 36
    i = 9, s = 45
    i = 10, s = 55
    result = 55


`1:10` の部分はイテラブルといわれ，おおまかにいえば要素が順に `i` に割り当てられる集合のようなものと言えよう。集合 `Set([2, 3, 5, 7, 9, 11])` の場合には，要素には順序がないので割り当てられる順序も無作為なように見える。


```julia
s = 0
for i in Set([2, 3, 5, 7, 9, 11])
    s += i
    println("i = $i, s = $s")
end
println("result = $s")
```

    i = 5, s = 5
    i = 7, s = 12
    i = 2, s = 14
    i = 11, s = 25
    i = 9, s = 34
    i = 3, s = 37
    result = 37


ベクトル `[2, 3, 5, 7, 9, 11]` の場合には，記述されている順序に従って `i` に割り当てられる。

イテラブルは数値に限らない。


```julia
for i in ["abc", 'a', 2, 3.1]
    println("i = $i")
end

```

    i = abc
    i = a
    i = 2
    i = 3.1


処理内容によっては，イテラブルの要素そのものと同時に何番目の要素かの情報があると便利なことがある。そのような場合には `enumerate()` を使う。


```julia
for (i, name) in enumerate(["setosa", "versicolor", "virginica"])
    println("i = $i, name = $name")
end
```

    i = 1, name = setosa
    i = 2, name = versicolor
    i = 3, name = virginica


また，複数のイテラブルから対応するものを順に割り当てると便利なこともある。そのような場合には `zip()` を使う。


```julia
names = ["John", "Susan", "Kent"]
ages  = [20, 21, 26]
for (name, age) in zip( names, ages)
    println("name = $name, age = $age")
end
```

    name = John, age = 20
    name = Susan, age = 21
    name = Kent, age = 26


`for`-`end` で構成される for ループは，通常はイテラブルの要素が尽きるまでくり返されるが，条件によって途中でループから抜け出したり（`break`），処理をしないで次の要素に対する処理へ移ったり（`continue`）することができる。


```julia
for i in 1:10
    if i%2 == 0
        continue # i が偶数なら何もしないで，次の繰り返しへ
    end
    if i > 6
        break # i が 6 になったらループから抜け出す
    end
    println("i = $i")
end

```

    i = 1
    i = 3
    i = 5


### while ループ

`while`-`end` で構成される while ループは以下のようなものである。

制御変数 `i` の初期化後，while ループの先頭で制御変数が条件を満たす限り，`while`-`end` の中身を実行する。

重要なのは，`while`-`end` の中で制御変数 `i` を更新することである。さもなければ，一旦 while ループを開始すると条件は常に満たされているので永遠にループが終わらない（無限ループ）ことになる。当然，制御変数 `i` を更新するとしても，それが不適切ならば同じように無限ループに陥ることになる。


```julia
s = 0
i = 1
while i <= 10
    s += i
    println("i = $i")
    i += 1
end
println("result = $s")
```

    i = 1
    i = 2
    i = 3
    i = 4
    i = 5
    i = 6
    i = 7
    i = 8
    i = 9
    i = 10
    result = 55


for ループの場合と同じように，条件により次のループに入ったり（`continue`），ループを脱出する（`break`）こともできる。

上の while ループは，for ループの説明で使用したものと同じ働きをする。しかし，すべての while ループが for ループで書き換えられるわけではない。

### トライ，キャッチ，ファイナリー

例外処理（例外的な状況に対する処理）の仕組みである。

<pre>try
　(主処理)
catch
　(例外処理)
end

finallyを使用した例

　try
　　(主処理)
　catch
　　(例外処理)
　finally
　　(最終処理) # 例外の有無に関わらず行う処理 
　end</pre>


```julia
function sqrt2(x)
    try
        sqrt(x)
    catch
        println("x が 負の値でした。 x = $x")
        println("絶対値を取って（正の値にして）平方根を求めます。")
        sqrt(abs(x))
    end
end
sqrt2(8), sqrt2(-9)
```

    x が 負の値でした。 x = -9
    絶対値を取って（正の値にして）平方根を求めます。





    (2.8284271247461903, 3.0)




```julia
function sqrt2(x)
    try
        sqrt(x)
    catch
        println("x が 負の値でした。 x = $x")
        println("絶対値を取って（正の値にして）平方根を求めます。")
        sqrt(abs(x))
    finally
        println("----------")
    end
end
sqrt2(8) |> println
sqrt2(-9) |> println
```

    ----------
    2.8284271247461903
    x が 負の値でした。 x = -9
    絶対値を取って（正の値にして）平方根を求めます。
    ----------
    3.0


エラーのときに止める


```julia
a = -1
a >= 0 || error("error! a should be positive a = $a")
```


    error! a should be positive a = -1

    

    Stacktrace:

     [1] error(s::String)

       @ Base ./error.jl:35

     [2] top-level scope

       @ In[538]:2


同じことであるが，以下のようにも書ける。


```julia
a = -1
a < 0 && error("error! a should be positive a = $a")
```


    error! a should be positive a = -1

    

    Stacktrace:

     [1] error(s::String)

       @ Base ./error.jl:35

     [2] top-level scope

       @ In[539]:2


## 関数

関数の定義は以下のようにする。

<pre>function 関数名(引数)
    関数定義
end</pre>


```julia
function output(x)
    println("x = $x")
end

output(4)
```

    x = 4


関数定義が単一の式[^1]の場合には，代入形式の簡潔な構文がある。[^1]: `begin`-`end` による複合式の場合も含むが，複合式の場合には代入形式にする意味がない。


```julia
output2(x) = println("x = $x")

output2(6)
```

    x = 6


引数が2個以上の場合はカンマで区切って列挙する。

また，関数は戻り値を帰す場合がある。その場合は `return 戻り値` とする。


```julia
function euclid(m, n)
    while n != 0
         m, n = n, m % n
    end
    return m # 最大公約数
end

euclid(24, 60)
```




    12



戻り値は複数の場合もある。

また，関数の最後であれば `return` は省略できる。


```julia
function euclid2(m, n)
    mn = m * n
    while n != 0
         m, n = n, m % n
    end
    m, mn ÷ m # 最大公約数と最小公倍数
end

euclid2(24, 60)
```




    (12, 120)



引数が変数の場合は，関数の中で変更されても，その変更は呼び出し元には反映されない。

以下の例では，引数は関数を呼び出すときには 5 であり，関数内で 2 倍されて戻り値となるが，呼び出し後には元のままの 5 である。


```julia
function double(z)
    2z
end

a = 5
println("関数呼び出し前 a = $a")
b = double(a)
println("関数呼び出し後 a = $a")
println("関数の戻り値　 b = $b")
```

    関数呼び出し前 a = 5
    関数呼び出し後 a = 5
    関数の戻り値　 b = 10


引数がベクトルの場合は，関数の中で変更されるとその変更は呼び出し元に反映される。以下のプログラムは，ベクトルを引数に取る。関数内で x は 2 倍され，（その時点での）x が 3 倍された戻り値が返される。

戻り値は b に代入されるが，それは引数の 2×3 倍である。

また，引数は入力時のベクトルの 2 倍になっている。このように，引数が変更される関数は最後に `!` を付けるのが慣例になっている。


```julia
function double!(x)
    x .*= 2
    3x
end

a = [2, 5, 9]
println("関数呼び出し前 a = $a")
b = double!(a);
println("関数呼び出し後 a = $a")
println("関数の戻り値　 b = $b")
```

    関数呼び出し前 a = [2, 5, 9]
    関数呼び出し後 a = [4, 10, 18]
    関数の戻り値　 b = [12, 30, 54]


### 匿名関数（無名関数，λ関数，ラムダ関数）

以下の例は 引数が `x` で，引数の 1.08 倍を計算する関数定義である。


```julia
price = x -> x * 1.08
```




    #19 (generic function with 1 method)




```julia
price(100)
```




    108.0



引数は 複数指定できる。


```julia
f = (x, y) -> x + y
f(1, 2), f(100, 300)
```




    (3, 400)



`map()` 関数の第 1 引数としても使われる。


```julia
map(x -> x*1.08, 100)
```




    108.0




```julia
map(x -> x*1.08, [100, 200, 1000])
```




    3-element Vector{Float64}:
      108.0
      216.0
     1080.0



複数行になる場合は、`begin`～`end` で囲う。


```julia
nebiki = x -> begin
    price = x * 0.9
    return price * 1.08
end

nebiki(1000)
```




    972.0000000000001



### 動的関数定義


```julia
x = 1; y = 2
arg = "x"
a = Meta.parse("func2($arg) = x + y")
eval(a)
func2(5)
```




    7


