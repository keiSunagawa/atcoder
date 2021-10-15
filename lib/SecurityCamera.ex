# https://atcoder.jp/contests/abc220/tasks/abc220_h
defmodule Camera do
  defstruct index: 1, state: 0

  def has_next(camera) do
    camera.state < 1
  end

  def next(camera) do
    n = camera.state+1
    %Camera{index: camera.index, state: n}
  end

  def check_secur_load(camera, loads) do
    if camera.state == 1 do
      Enum.filter(loads, fn {a, b} ->  camera.index == a || camera.index == b end)
    else
      []
    end
  end
end

defmodule Cameras do
  defstruct xs: []

  def next2(xs) do
    [h | t] = xs
    if Camera.has_next(h) do
       [Camera.next(h) | t]
    else
       [%{h | state: 0} | Cameras.next2(t)]
    end
  end

  def has_next(cameras) do
    Enum.any?(cameras.xs, &(Camera.has_next(&1)))
  end
  # 末尾再帰ではない,,
  def next(cameras) do
    %Cameras{xs: Cameras.next2(cameras.xs)}
  end

  def check_secur_load(cameras, loads) do
    Enum.flat_map(cameras.xs, fn c ->
      Camera.check_secur_load(c, loads)
    end) |> Enum.uniq
  end
  def exhaustive(cameras, loads, acc \\ []) do
    res = Cameras.check_secur_load(cameras, loads)
    # IO.inspect({cameras, res})
    nacc = if rem(Enum.count(res), 2) == 0, do: [{cameras, res} | acc], else: acc
    if Cameras.has_next(cameras) do
      exhaustive(Cameras.next(cameras), loads, nacc)
    else
      nacc
    end
  end
end

defmodule SecurityCamera do
    def main(args \\ []) do
    [n, _m | tail] = args  |> Enum.map(fn x ->
      {xi, _rem} = Integer.parse(x)
      xi
    end)
    IO.inspect(n)
    loads = make_loads(tail)

    cameras = Enum.map(1..n, fn x -> %Camera{index: x, state: 0} end)
    cross = %Cameras{xs: cameras}
    res = Cameras.exhaustive(cross, loads)
    Enum.count(res)
  end

  defp make_loads(xs) do
    [fst | t] = xs
    List.foldl(t, [{fst}], fn x, acc ->
      [is | t] = acc
      case is do
        {i} ->[{i, x} | t]
        {_i, _n} ->[{x} | [is | t]]
      end
    end)
  end
end
