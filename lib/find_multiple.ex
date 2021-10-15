defmodule FindMultiple do
  def main(args \\ []) do
    [a, b, c | _tail] = args  |> Enum.map(fn x ->
      {xi, _rem} = Integer.parse(x)
      xi
    end)
    IO.inspect(a)
    exec(a, c, b)
  end

  defp exec(a, b, c) do
    if  a <= c && c <= b do
      -1
    else
      c * 2
    end
  end
end
