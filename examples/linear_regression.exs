defmodule LinearRegression do
  use Genex

  # Solutions are lists of [m, b]
  def encoding, do: Chromosome.integer_value(size: 2, min: 0, max: 12)
  # Fitness is the sum of squared errors
  def fitness_function(c) do
    {m, b} = List.to_tuple(c.genes)
    {xlist, ylist} = Enum.unzip(dataset())
    mean =
      xlist
      |> Enum.map(fn x -> m * x + b end)
      |> Enum.sum()
      |> Kernel./(length(xlist))
    ylist
    |> Enum.map(fn x -> mean - x end)
    |> Enum.map(fn x -> x * x end)
    |> Enum.sum()
  end

  def terminate?(p), do: p.generation == 1000

  # Data Points to run regression on
  defp dataset do
    [
      {1, 2},
      {2.42, 5.4},
      {5.70, 12.95},
      {10.01, 20.1},
      {19.91, 38.34}
    ]
  end
end

import Genex.Config

[minimize?: true]
|> use_crossover(:blend, alpha: 0.5)
|> use_mutation(:gaussian)
|> LinearRegression.run()