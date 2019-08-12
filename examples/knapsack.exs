defmodule Knapsack do
  use Genex, crossover_type: :two_point,
             uniform_crossover_rate: 0.5,
             parent_selection: :roulette

  def encoding, do: Chromosome.binary(size: 7)

  def fitness_function(c) do
    profit =
      c.genes
      |> Enum.zip(profits())
      |> Enum.reduce(0, fn {g, p}, acc -> acc + g*p end)
    penalty =
      c.genes
      |> Enum.zip(weights())
      |> Enum.reduce(0, fn {g, w}, acc -> acc + g*w end)
      |> Kernel.-(length(profits()))
      |> Kernel.abs()
      |> Kernel.*(Enum.sum(weights()))
    profit - penalty
  end

  def terminate?(p), do: p.generation == 1000

  def mutation_rate(_), do: 0.25

  defp profits, do: [6, 5, 8, 9, 6, 7, 3]
  defp weights, do: [2, 3, 6, 7, 5, 9, 4]
end

soln = Knapsack.run()