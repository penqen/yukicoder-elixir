# Yukicoder + Elixir　競技プログラミング練習

Elixirで競技プログラミングを練習中。  
Yukicoderの提出コードやそれに至るまでのサンプルコードなど。

## ディレクトリ構成

基本的に、問題数が多くなるので100桁ごとにフォルダで分けてグルーピングしてます。  
ファイル名は、p問題番号.ex と p問題番号_test.exs （テスト確認用）

```tree
.
├── lib
│   ├── 100
│   │   ├── p1.ex
│   │   ├── p2.ex

...

├── test
    ├── 100
    │   ├── p1_test.exs
```  

## 実行環境 ( 動作環境 )

ローカル環境を基本汚したくないため、`Docker` (`Docker Compose`)を使って、
仮想コンテナせて上でプログラムを走らせます。

- テストケースの確認やシビアな問題のベンチマークもついでに走らせる

```sh
sh> docker-compose run --rm elixir-test mix test test/100/p8_test.exs

Creating yukicoder-elixir_elixir-test_run ... done
Compiling 49 files (.ex)
Generated yukicoder app
.....

Finished in 0.1 seconds
5 doctests, 0 failures

Randomized with seed 507750
```

- main関数の確認

```sh
sh> docker-compose run --rm elixir-test iex -S mix

iex> P8.main
# 標準入力
3
5 10
40 6
# 標準出力
Win
Win
Lose

iex> Main.main
# 標準入力
3
5 10
Win # 標準出力
40 6
Win # 標準出力
100 8
Lose # 標準出力
```

## Todo

- [ ] テストケースを自動でとってきてパパッと確認したい。
